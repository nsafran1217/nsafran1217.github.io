# Fixing the Radeon driver on SGI Altix
*Published: 18-Apr-2026 - Last Updated: 18-Apr-2026*

For [over 15 years](https://nekonomicon.irixnet.org/forum/3/16723530/1.html), people have been trying to use GPUs with acceleration
on Silicon Graphics Altix 350s, however, no one has ever been able to get it to work.

Finally, we have a fix. You can now use modern ATi/AMD PCI-e GPUs on SGI Altix 350s with easy to find
 PLX based PCI to PCI-e adapter boards. The `radeon` driver WORKS with full 3d acceleration on the most 
 recent Linux kernel on T2 Linux.

 ### Getting it working
 To do this, you're going to need one of the following OS's installed on your Altix. Any OS's not listed have not been tested
* T2 26.3 +
* Epic-Slack
* SLES 11*
* SLES 9*

*\*your GPU must be supported in that kernel version*

I recommend a modern OS like T2 or Epic-Slack

#### Kernel Patches
I have pre-built kernels avaliable for the following versions, or you can take a patch file and compile your own kernel.

## What needed fixed?
The SGI Altix SN2 is a very strange architecture. The PCI riser was never intended to support a GPU. 
When SGI wanted to add a GPU to the system, they developed the TIOCA AGP Riser for the Prism. 
The TIOCA has support for 1024 GART entries built into its ASIC, and the proprietary ATi `fglrx` driver has calls 
for SN2 specifc DMA flush routines after every read and write the GPU makes.

There were two main issues with bringing up a PCI GPU, plus one additional issue using one behind a PCI bridge.

1. The firmware does not properly setup the PCI bridge's prefetchable memory window
2. The SN2 architecture does not support write combining for PIO tranfers
3. Heavy DMA reads preformed by the GPU on memory which is cached overloads the FSB table tracking modified cache lines.

### 1. PCI Bridge prefetchable memory window
The SN2 firmware has no mechanism in the EFI firmware to deal with PCI bridges and properly program the PLX bridge prefetchable memory window. We must manually program the PLX bridge. There are two options: 
1. Create a small script that runs before modprobe radeon does.
2. Load a kernel module which programs the bridge.

### 2. PIO write combining
Must be uncached

### 3. DMA on cached memory
Must be uncached
