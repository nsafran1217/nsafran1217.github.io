need both 32 and 64 bit hppa cross toolchains.




mkinitrd -o /boot/initrd-7.0.0-028ef9c96e96-parisc -R / 7.0.0-028ef9c96e96-parisc




# Context


tar cJf ~/desktop/linux-v7-parisc.tar.xz  --exclude='.o' --exclude='.o.' --exclude='.a' --exclude='.ko' --exclude='..cmd' --exclude='.bin' --exclude='.gz' arch/parisc mm include kernel drivers/Kconfig drivers/Makefile drivers/char/Kconfig drivers/char/Makefile drivers/char/agp drivers/gpu/drm/ttm drivers/gpu/drm/radeon drivers/parisc





git checkout -- . && git apply combined-patch.patch && hppa-build.sh &&  scp ../../release/linux-7.0.0-028ef9c96e96-parisc-dirty.tar.gz root@c8000:~/kerns

cd ~/kerns && rm -rf boot lib && tar xf linux-7.0.0-028ef9c96e96-parisc-dirty.tar.gz && cp -r lib/modules/7.0.0-028ef9c96e96-parisc-dirty/ /lib/modules/ && cp boot/* /boot/ && mkinitrd -o /boot/initrd-7.0.0-028ef9c96e96-parisc-dirty -R / 7.0.0-028ef9c96e96-parisc-dirty && reboot


TODO:
Serial Console
Get NFS_ROOT support built into kernel
Maybe build all c8000 devices in so we dont need initrd





Hi List,

i've spent quite some time this evening debugging why the Fire GL
doesn't work in my C8000. As reading debug output didn't give me
much insights, i decided to throw some Hardware at the Problem and
connect a Logic Analyzer to the C8000. For that i switched to an old
PCI Radeon 7000 which shows the same ring test failure.

I captured a few traces:

First, from the card in a x86 PC where it's working:

https://stackframe.org/radeon.png

We can clearly see the radeon fetches the Ring descriptor via
DMA here. Note the DEADBEEF in the trace which is the value
written to the scratch register during the ring test.

On C8000, we can see reading the DMA descriptor fails, radeon
reads all zero:

https://stackframe.org/c8000_radeon.png

I had already a flush_cache_all() for testing in WREG32(), but it looks
like this wasn't enough. Adding one to radeon_ring_write() makes the
radeon happy:

https://stackframe.org/c8000_fixed.png

My assumption was that the zx1 chipset takes care about cache coherency,
but it looks like that's not happening. Does that problem ring any
bells for someone? Otherwise i'll continue investigating tomorrow.
(Almost midnight here)

dmesg looks better now, althought i don't consider adding
flush_cache_all() as a fix ;-)

[   21.186924] Linux agpgart interface v0.103
[   21.236890] quicksilver: IO PDIR shared with sba_iommu
[   21.343142]  (null): AGP aperture is 512M @ 0x60000000
[   21.397054] [drm] radeon kernel modesetting enabled.
[   21.457024] radeon 0000:60:04.0: remove_conflicting_pci_framebuffers: bar 0: \
0xffffffffb0000000 -> 0xffffffffb7ffffff [   21.586863] radeon 0000:60:04.0: \
remove_conflicting_pci_framebuffers: bar 2: 0xffffffffb80c0000 -> 0xffffffffb80cffff \
[   21.719672] [drm] initializing kernel modesetting (RV100 0x1002:0x5159 \
0x1014:0x029A 0x00). [   21.856909] __ioremap: ffffffffb80c0000 -> 0000000000050000
[   21.966904] __ioremap: ffffffffb0000000 -> 0000000010240000
[   22.066905] __ioremap: ffffffffb8080000 -> 00000000040a0000
[   22.136898] radeon 0000:60:04.0: Invalid PCI ROM header signature: expecting \
0xaa55, got 0x0000 [   22.276907] __ioremap: ffffffffb8080000 -> 0000000008120000
[   22.439336] radeon 0000:60:04.0: VRAM: 128M 0xFFFFFFFFB0000000 - \
0xFFFFFFFFB7FFFFFF (8M used) [   22.536865] radeon 0000:60:04.0: GTT: 512M \
0xFFFFFFFF90000000 - 0xFFFFFFFFAFFFFFFF [   22.626946] [drm] Detected VRAM RAM=128M, \
BAR=128M [   22.686876] [drm] RAM width 32bits DDR
[   22.736874] [TTM] Zone  kernel: Available graphics memory: 2046222
KiB
[   22.806868] [TTM] Initializing pool allocator
[   22.866971] [drm] radeon: 8M of VRAM memory ready
[   22.916877] [drm] radeon: 512M of GTT memory ready.
[   22.976922] [drm] GART: num cpu pages 131072, num gpu pages 131072
[   23.161879] [drm] PCI GART of 512M enabled (table at 0x00000000400C0000).
[   23.236987] kmap: 000000413ee4f000
[   23.276887] radeon 0000:60:04.0: WB disabled
[   23.336865] radeon 0000:60:04.0: fence driver on ring 0 use gpu addr \
0xffffffff90000000 and cpu addr 0x000000413ee4f000 [   23.466867] [drm] Supports \
vblank timestamp caching Rev 2 (21.10.2013).
[   23.536871] [drm] Driver supports precise vblank timestamp query.
[   23.616942] [drm] radeon: irq initialized.
[   23.666932] [drm] Loading R100 Microcode
[   23.756861] [drm] radeon: ring at 0xFFFFFFFF90001000
(debug dropped)
[   27.206908] [drm] ring test succeeded in 0 usecs
(debug dropped)
[   30.696921] [drm] ib test succeeded in 0 usecs
[   30.754178] [drm] No TV DAC info found in BIOS
[   30.806921] [drm] Radeon Display Connectors
[   30.856862] [drm] Connector 0:
[   30.886880] [drm]   VGA-1
[   30.916861] [drm]   DDC: 0x60 0x60 0x60 0x60 0x60 0x60 0x60 0x60
[   30.996861] [drm]   Encoders:
[   31.026877] [drm]     CRT1: INTERNAL_DAC1
[   31.076861] [drm] Connector 1:
[   31.116866] [drm]   DVI-I-1
[   31.146877] [drm]   HPD2
[   31.176860] [drm]   DDC: 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c 0x6c
[   31.246877] [drm]   Encoders:
[   31.286865] [drm]     CRT2: INTERNAL_DAC2
[   31.336860] [drm]     DFP1: INTERNAL_TMDS1
[   31.476904] __ioremap: ffffffffb0040000 -> 0000000010700000
[   31.580409] [drm] fb mappable at 0xFFFFFFFFB0040000
[   31.636856] [drm] vram apper at 0xFFFFFFFFB0000000
[   31.696854] [drm] size 786432
[   31.726855] [drm] fb depth is 8
[   31.766854] [drm]    pitch is 1024
[   32.006860] Console: switching to colour frame buffer device 128x48
[   32.119230] radeon 0000:60:04.0: fb0: radeondrmfb frame buffer device
[   32.197017] [drm] Initialized radeon 2.50.0 20080528 for 0000:60:04.0
on minor 0

Regards
Sven



On Sat, Sep 28, 2019 at 11:44:36PM +0200, Sven Schnelle wrote:
> Hi List,
> 
> i've spent quite some time this evening debugging why the Fire GL
> doesn't work in my C8000. As reading debug output didn't give me
> much insights, i decided to throw some Hardware at the Problem and
> connect a Logic Analyzer to the C8000. For that i switched to an old
> PCI Radeon 7000 which shows the same ring test failure.

below patch (with debug print left in) got PCI radeon working for me, when
I played with it last time.  The added fdc is a real fix, while the change
in parisc_agp_mask_memory is just a hack. The big problem there is to get
virtual address where the memory is mapped to in user space...

Thomas.


diff --git a/drivers/char/agp/parisc-agp.c b/drivers/char/agp/parisc-agp.c
index 15f2e7025b78..756bc4a265d9 100644
--- a/drivers/char/agp/parisc-agp.c
+++ b/drivers/char/agp/parisc-agp.c
@@ -20,6 +20,7 @@
 #include <linux/agp_backend.h>
 #include <linux/log2.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 
 #include <asm/parisc-device.h>
 #include <asm/ropes.h>
@@ -162,6 +163,16 @@ parisc_agp_insert_memory(struct agp_memory *mem, off_t pg_start, int type)
 			info->gatt[j] =
 				parisc_agp_mask_memory(agp_bridge,
 					paddr, type);
+			asm volatile("fdc %%r0(%0)" : : "r" (&info->gatt[j]));
+#if 0
+#if 0
+			printk("i %x j %lx page %p va %lx  paddr %lx gatt %lx\n",
+			       i, j, mem->pages[i], __va(paddr), paddr, info->gatt[j]);
+#else
+			printk("i %x j %lx page %p va %lx  paddr %lx\n",
+			       i, j, mem->pages[i], __va(paddr), paddr);
+#endif
+#endif
 		}
 	}
 
@@ -184,7 +195,7 @@ parisc_agp_remove_memory(struct agp_memory *mem, off_t pg_start, int type)
 	io_pg_start = info->io_pages_per_kpage * pg_start;
 	io_pg_count = info->io_pages_per_kpage * mem->page_count;
 	for (i = io_pg_start; i < io_pg_count + io_pg_start; i++) {
-		info->gatt[i] = agp_bridge->scratch_page;
+		// info->gatt[i] = agp_bridge->scratch_page;
 	}
 
 	agp_bridge->driver->tlb_flush(mem);
@@ -195,7 +206,22 @@ static unsigned long
 parisc_agp_mask_memory(struct agp_bridge_data *bridge, dma_addr_t addr,
 		       int type)
 {
-	return SBA_PDIR_VALID_BIT | addr;
+#if 1
+	u64 pa;
+	register unsigned ci; /* coherent index */
+	
+	pa = addr & IOVP_MASK;
+	mtsp(0,1);
+	asm("lci 0(%%sr1, %1), %0" : "=r" (ci) : "r" (__va(pa)));
+	
+	pa |= (ci >> PAGE_SHIFT) & 0xff;  /* move CI (8 bits) into lowest byte */
+
+	pa |= SBA_PDIR_VALID_BIT;	/* set "valid" bit */
+
+	return cpu_to_le64(pa);
+#else
+	return cpu_to_le64(SBA_PDIR_VALID_BIT | addr);
+#endif
 }
 
 static void




On 2019-10-02 10:19 a.m., Thomas Bogendoerfer wrote:
> On Sat, Sep 28, 2019 at 11:44:36PM +0200, Sven Schnelle wrote:
>> Hi List,
>>
>> i've spent quite some time this evening debugging why the Fire GL
>> doesn't work in my C8000. As reading debug output didn't give me
>> much insights, i decided to throw some Hardware at the Problem and
>> connect a Logic Analyzer to the C8000. For that i switched to an old
>> PCI Radeon 7000 which shows the same ring test failure.
> below patch (with debug print left in) got PCI radeon working for me, when
> I played with it last time.  The added fdc is a real fix, while the change
> in parisc_agp_mask_memory is just a hack. The big problem there is to get
> virtual address where the memory is mapped to in user space...
>
> Thomas.
>
>
> diff --git a/drivers/char/agp/parisc-agp.c b/drivers/char/agp/parisc-agp.c
> index 15f2e7025b78..756bc4a265d9 100644
> --- a/drivers/char/agp/parisc-agp.c
> +++ b/drivers/char/agp/parisc-agp.c
> @@ -20,6 +20,7 @@
>  #include <linux/agp_backend.h>
>  #include <linux/log2.h>
>  #include <linux/slab.h>
> +#include <linux/pagemap.h>
>  
>  #include <asm/parisc-device.h>
>  #include <asm/ropes.h>
> @@ -162,6 +163,16 @@ parisc_agp_insert_memory(struct agp_memory *mem, off_t pg_start, int type)
>  			info->gatt[j] =
>  				parisc_agp_mask_memory(agp_bridge,
>  					paddr, type);
> +			asm volatile("fdc %%r0(%0)" : : "r" (&info->gatt[j]));
> +#if 0
> +#if 0
> +			printk("i %x j %lx page %p va %lx  paddr %lx gatt %lx\n",
> +			       i, j, mem->pages[i], __va(paddr), paddr, info->gatt[j]);
> +#else
> +			printk("i %x j %lx page %p va %lx  paddr %lx\n",
> +			       i, j, mem->pages[i], __va(paddr), paddr);
> +#endif
> +#endif
>  		}
>  	}
>  
> @@ -184,7 +195,7 @@ parisc_agp_remove_memory(struct agp_memory *mem, off_t pg_start, int type)
>  	io_pg_start = info->io_pages_per_kpage * pg_start;
>  	io_pg_count = info->io_pages_per_kpage * mem->page_count;
>  	for (i = io_pg_start; i < io_pg_count + io_pg_start; i++) {
> -		info->gatt[i] = agp_bridge->scratch_page;
> +		// info->gatt[i] = agp_bridge->scratch_page;
>  	}
>  
>  	agp_bridge->driver->tlb_flush(mem);
> @@ -195,7 +206,22 @@ static unsigned long
>  parisc_agp_mask_memory(struct agp_bridge_data *bridge, dma_addr_t addr,
>  		       int type)
>  {
> -	return SBA_PDIR_VALID_BIT | addr;
> +#if 1
> +	u64 pa;
> +	register unsigned ci; /* coherent index */
> +	
> +	pa = addr & IOVP_MASK;
> +	mtsp(0,1);
> +	asm("lci 0(%%sr1, %1), %0" : "=r" (ci) : "r" (__va(pa)));
I believe you can remove the mtsp and just use "lci 0(%1), %0" to load the coherence index.   The space
registers sr4 to sr7 are always 0 in kernel.

> +	
> +	pa |= (ci >> PAGE_SHIFT) & 0xff;  /* move CI (8 bits) into lowest byte */
> +
> +	pa |= SBA_PDIR_VALID_BIT;	/* set "valid" bit */
> +
> +	return cpu_to_le64(pa);
> +#else
> +	return cpu_to_le64(SBA_PDIR_VALID_BIT | addr);
> +#endif
>  }
>  
>  static void
>

Dave




On Wed, Oct 02, 2019 at 04:37:41PM -0400, John David Anglin wrote:
> On 2019-10-02 10:19 a.m., Thomas Bogendoerfer wrote:
> > +	pa = addr & IOVP_MASK;
> > +	mtsp(0,1);
> > +	asm("lci 0(%%sr1, %1), %0" : "=r" (ci) : "r" (__va(pa)));
> I believe you can remove the mtsp and just use "lci 0(%1), %0" to load the coherence index.  The space
> registers sr4 to sr7 are always 0 in kernel.

ok, good to know.

while reading this I realized what the other hacks were for, which I didn't
include in my first mail. 

diff --git a/drivers/gpu/drm/ttm/ttm_agp_backend.c b/drivers/gpu/drm/ttm/ttm_agp_backend.c
index 028ab6007873..e84c7652eb1b 100644
--- a/drivers/gpu/drm/ttm/ttm_agp_backend.c
+++ b/drivers/gpu/drm/ttm/ttm_agp_backend.c
@@ -66,7 +67,8 @@ static int ttm_agp_bind(struct ttm_tt *ttm, struct ttm_mem_reg *bo_mem)
 		if (!page)
 			page = ttm->dummy_read_page;
 
-		mem->pages[mem->page_count++] = page;
+		mem->pages[(ttm->num_pages - 1) - mem->page_count] = page;
+		mem->page_count++;
 	}
 	agp_be->mem = mem;
 
diff --git a/drivers/gpu/drm/ttm/ttm_bo_util.c b/drivers/gpu/drm/ttm/ttm_bo_util.c
index d0459b392e5e..4bb301cab128 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_util.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_util.c
@@ -571,8 +571,14 @@ static int ttm_bo_kmap_ttm(struct ttm_buffer_object *bo,
 		 */
 		prot = ttm_io_prot(mem->placement, PAGE_KERNEL);
 		map->bo_kmap_type = ttm_bo_map_vmap;
+		printk("vmap %p\n", ttm->pages[start_page]);
+#if 0
 		map->virtual = vmap(ttm->pages + start_page, num_pages,
 				    0, prot);
+#else
+		map->virtual = kmap(ttm->pages[start_page]);
+#endif
+		
 	}
 	return (!map->virtual) ? -ENOMEM : 0;
 }

 
This is needed to be able to get the virtual address with __va(pa).

Thomas.




On 04.10.19 14:06, Thomas Bogendoerfer wrote:
> On Wed, Oct 02, 2019 at 04:37:41PM -0400, John David Anglin wrote:
> > On 2019-10-02 10:19 a.m., Thomas Bogendoerfer wrote:
> > > +	pa = addr & IOVP_MASK;
> > > +	mtsp(0,1);
> > > +	asm("lci 0(%%sr1, %1), %0" : "=r" (ci) : "r" (__va(pa)));
> > I believe you can remove the mtsp and just use "lci 0(%1), %0" to load the \
> > coherence index.   The space registers sr4 to sr7 are always 0 in kernel.
> 
> ok, good to know.
> 
> while reading this I realized what the other hacks were for, which I didn't
> include in my first mail.
> 
> diff --git a/drivers/gpu/drm/ttm/ttm_agp_backend.c \
> b/drivers/gpu/drm/ttm/ttm_agp_backend.c index 028ab6007873..e84c7652eb1b 100644
> --- a/drivers/gpu/drm/ttm/ttm_agp_backend.c
> +++ b/drivers/gpu/drm/ttm/ttm_agp_backend.c
> @@ -66,7 +67,8 @@ static int ttm_agp_bind(struct ttm_tt *ttm, struct ttm_mem_reg \
> *bo_mem)  if (!page)
> 			page = ttm->dummy_read_page;
> 
> -		mem->pages[mem->page_count++] = page;
> +		mem->pages[(ttm->num_pages - 1) - mem->page_count] = page;
> +		mem->page_count++;
> 	}
> 	agp_be->mem = mem;
> 
> diff --git a/drivers/gpu/drm/ttm/ttm_bo_util.c b/drivers/gpu/drm/ttm/ttm_bo_util.c
> index d0459b392e5e..4bb301cab128 100644
> --- a/drivers/gpu/drm/ttm/ttm_bo_util.c
> +++ b/drivers/gpu/drm/ttm/ttm_bo_util.c
> @@ -571,8 +571,14 @@ static int ttm_bo_kmap_ttm(struct ttm_buffer_object *bo,
> 		 */
> 		prot = ttm_io_prot(mem->placement, PAGE_KERNEL);
> 		map->bo_kmap_type = ttm_bo_map_vmap;
> +		printk("vmap %p\n", ttm->pages[start_page]);
> +#if 0
> 		map->virtual = vmap(ttm->pages + start_page, num_pages,
> 				    0, prot);
> +#else
> +		map->virtual = kmap(ttm->pages[start_page]);
> +#endif
> +
> 	}
> 	return (!map->virtual) ? -ENOMEM : 0;
> }
> 
> 
> This is needed to be able to get the virtual address with __va(pa).

Can you make a documented patch out of all that?
I'd like to include it at least into a test/hack branch, e.g.
https://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux.git/commit/?h=radeon-test&id=0ef942c21d37078ae6406b3e7075f3dbe6417a04


Helge
