# Fixing the Radeon driver on SGI Altix
*Published: 18-Apr-2026 - Last Updated: 18-Apr-2026*

For [over 15 years](https://nekonomicon.irixnet.org/forum/3/16723530/1.html), people have been trying to use GPUs with acceleration
on Silicon Graphics Altix 350s, however, no one has ever been able to get it to work. Finally, we have a fix. 
You can now use modern ATi/AMD PCI-e GPUs on SGI Altix 350s with easy to find 
PLX based PCI to PCI-e adapter boards. The `radeon` and `amdgpu` drivers WORKS with full 3d acceleration on the most 
recent Linux kernel on T2 Linux.

### Tested OSs and Kernels
To do this, you're going to need one of the following OS's installed on your Altix. Any OS's not listed have not been tested. 
Since these are kernel driver changes, any OS should work.

- T2 26.3 +
- Epic-Slack
- SLES 11*
- SLES 9*

*\*your GPU must be supported in that kernel version*  

I recommend a modern OS like T2 or Epic-Slack.

#### Tested GPUs
All were used with a PCI to PCI-e adapter with the PLX 8111/8112 bridge chip. They are readily avaliable 
on ebay for about $30 USD. They have a full size PCI-E slot. 
The only other adapter availabe is one made by startech. This adapter has NOT been tested 
and WILL NOT work without modifications to the plx_bridge_fixup.c file.

- AMD Radeon R5 430 (Best tested so far) - Cheap, easy to find with low profile bracket
- AMD Radeon HD 7570 (Dell OEM) - Cheap, easy to find with low profile bracket

## Setup
The GPU **MUST** be installed in the top PCI slot. There must not be any card installed in the slot directly below it.  
You should have a working install of Linux. This is written assuming T2, but the general steps are the same.  
See instructions for setting up T2 on Altix here.

TODO: Put instructions, compile some kernels for SN2 and host on Github.


## What needed fixed?
The SGI Altix SN2 is a very strange architecture. The PCI riser was never intended to support a GPU.
When SGI wanted to add a GPU to the system, they developed the TIOCA AGP Riser for the Prism.
The TIOCA has support for 1024 GART entries built into its ASIC, and the proprietary ATi `fglrx` driver has calls
for SN2 specific DMA flush routines after every read and write the GPU makes.

Note that AI was used in fixing this issue. What follows is a summary of the fixes. I will link the AI generated analysis docs further down the page.

There were two main issues with bringing up a PCI GPU, one issue using it behind a PCI bridge, and one additional issue with `amdgpu`.

1. The firmware does not properly setup the PCI bridge's prefetchable memory window
2. The SN2 architecture does not support write combining for PIO transfers
3. Heavy DMA reads performed by the GPU on memory which is cached overloads the FSB table tracking modified cache lines
4. UVD ring test fails on AMDGPU due to overloading the system with PIO writes

### 1. PCI Bridge prefetchable memory window
The SN2 firmware has no mechanism in the EFI firmware to deal with PCI bridges and properly program the PLX bridge prefetchable memory window. 
We must manually program the PLX bridge.  
During testing, I ran these two commands to program the window:

    setpci -s 0002:00:02.0 24.W=0x1000
    setpci -s 0002:00:02.0 26.W=0x1ff0

This fix allowed the radeon driver to load.  
To make this seamless and hopefully support GPUs or other PCI-E cards with different window sizes, I made a small fixup function
which runs during boot and automatically programs the window into the PLX based on detected BARs.
The kernel config option for this is `CONFIG_SN2_PLX_GPU=y`. It's available to select under `SN Devices` in `menuconfig`.

### 2. PIO writes must be uncached
When the driver tried to write to the GPU with PIO, the data never reached the GPU because the writes were write-combined.
The ia64 CPU's write-combine buffers accumulate stores destined for PIO space, but the SHub and NUMAlink fabric do not provide
the completion signals the CPU's WC drain logic expects. The result: writes pile up in CPU-internal buffers and never propagate to the device.
This manifested as a 15-second hang followed by an RCU stall any time userspace touched mmapped VRAM:

    rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
    task:modetest  state:R  running task

The CPU was actively executing stores but none of them reached the GPU.
Changing the TTM buffer objects to `pgprot_noncached()` fixed the issue and was a major stepping stone.
This matches exactly what the SGI Altix Porting Guide (007-4520-007, PCI-X Memory Resource Address, Page 67) 
says: user mappings of PCI device memory must use `pgprot_noncached()`.
At this point, we had X working, `glxgears` working and full 3D rendering working. However,
any significant 3D rendering caused the system to lock up and MCA.

### 3. DMA on cached memory
To fix heavy 3D rendering, I needed more information than the AI added instrumentation provided, so I used the `errdmp`
command included on the SGI internal support tools CD. This command can dump status about every chip and ASIC in the system.
It's a very powerful tool. Combined with AI, analysis of the dumps was much easier.

When launching Minecraft, the system would lock up, then MCA 20 seconds later. When running `errdmp` during this lockup,
we found the following info: `SH_PI_FIRST_ERROR=0x01 (FSB_PROTO_ERR)`. The FSB was in error. Drilling further into the dump:

- `DETAIL_1 cmd=0x01 (RDEXC)` — the failing transaction was a **Read-Exclusive directory intervention**
- `DETAIL_2 source chiplet = MD` — it originated in the Memory Directory chiplet, not the PIC
- `BUS1_DEV2_REG = 0x12040000`, bit 16 (COHERENT) = 0 — so this wasn't about DMA *writes* being coherent
- The error address was always in the TTM buffer object region, inside the GPU's Direct32 DMA range

Combining all that told the real story: the GPU was DMA-**reading** GTT pages that the CPU had just touched. 
Because the kernel zeros pages and fills indirect buffers through the WB identity map, every one of those pages had **Modified** cache lines 
sitting in a CPU's L2. Every GPU DMA read of a Modified line triggered an RDEXC directory intervention from the MD chiplet, 
routed MD → PI → FSB → CPU. Under Minecraft-level load this saturated the FSB transaction table, the protocol error fired, and the box MCA'd.

The obvious "just mark those pages uncached" fix doesn't actually work on ia64. Unlike x86, 
ia64 has no per-page PAT — the kernel identity map (region 7) is *always* WB, and `set_pages_array_uc()` is a no-op. 
You cannot change a physical page's cache attribute from the kernel side. The only way to avoid Modified lines is to flush them yourself.

The fix was two lines of logic in `ttm_pool_alloc_page()`: right after `alloc_pages_node()` returns freshly-zeroed WB pages, 
call `sn_flush_all_caches()` to issue `fc.i` across the page and write the dirty lines back to memory. 
By the time the GPU ever sees the page, it's clean, and no directory intervention is needed. Minecraft no longer MCAs the box.

### 4. UVD writes overload PIO
This issue caused the system to lock up when loading `amdgpu` unless you loaded it like this: `modprobe amdgpu ip_block_mask=0xffffff7f`, which disables UVD.
The root cause was raw pointer stores to an iomem-kmap'd VRAM BO that get compiler-optimized/merged in ways that overwhelm SN2's PIO write pipeline, triggering `PIO_TO_ERR` in the SHub.
The fix: convert those stores to `writel()` and type the pointer as `u32 __iomem *`. This forces each store to be a discrete, 
non-mergeable volatile write, matching what SN2's PIO pipeline can handle (and what `radeon` has always done).

