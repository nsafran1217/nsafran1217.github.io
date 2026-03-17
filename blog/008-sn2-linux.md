# Adding support for SGI Altix back into Linux
*Published: 16-Mar-2026 - Last Updated: 16-Mar-2026*

An alternate title for this could be "Using an LLM to support vintage computers", as I never would have been able to do this without extensive use of Claude Opus. 
I kind of feel guilty for taking any credit, as the LLM did much of the heavy lifting. 
I think this project is a good example of using an LLM to keep an old computer alive
after support for it had been broken for over 10 years.

### Background

The SGI Altix is a ccNUMA SSI (Single System Image) supercomputer designed and manufactured by Silicon Graphics. 
The first version, the Altix 3000 was released in 2003 and was the first computer to support running Linux with more than 64 CPUs in a single system image. 
After releasing the "2nd generation" Itanium based Altix machines, the 450 and 4000, SGI moved to x86-64 processors for the Altix XE, Altix ICE, and Altix UV.

Read the [Wikipedia page for more information](https://en.wikipedia.org/wiki/SGI_Altix).

Altix (also called SN2 {scalable node 2}) was 
[removed from the Linux kernel for v5.4](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=76f0f227cffb570bc5ce343b1750f14907371d80) in 2019 
in preparation for the removal of ia64. During this process, the infrastructure 
for supporting different machine types at runtime was removed.  
This makes adding SN2 support back in more difficult than just reversing the patch. 
I suppose you could undo everything and re-add the machine vector infrastructure, but in my opinion,
this option seemed too invasive and likely to cause bugs.

*Since we don't re-add the machvec infrastructure, support for SN2 is decided at compile time, not at runtime.*
*Meaning a kernel compiled for SN2 will not run on a generic ia64 machine, and vice versa.*


### Motivation
I don't know, it sounded fun/interesting. Altix had been abandoned since about v3.10, and was fully broken after v4.0. 
I originally stopped at Linux v4.19.325, but I really wanted to work on getting the radeon driver working on Altix. 
I convinced myself that I needed a modern Linux distro to do this, and some folks in the T2 community suggested 
adding SN2 support back would be easier than building T2 with an older kernel.

### Preamble
I knew that I could not do this. I am not a kernel dev, I am not proficient at git, 
I am a beginner at C/C++. All my C/C++ experience comes from embedded projects on Ardiuno or ESP32, so jumping to the Linux kernel
would be too much for me.

However, it's 2026, and I have access to Claude.ai. I had used claude opus for a [different C project](https://github.com/nsafran1217/Pertec-Interface-Tape-Controller/tree/HostUSBOnly)
 a few weeks before starting this and was impressed with its output. I had tried to use ChatGPT and Copilot for help with getting radeon
 working about a year ago, but never really got anywhere with it. I couldn't give it enough context (at least with the free version).

I don't claim to be good at using LLM tools, or programming, or anything. This is just a description of how
I got modern Linux working on SN2 again.

### The Process
So how will we do this? I figured we should start with v5.4 and what it will take to add SN2 back as it was removed; 
basically just reversing the removal patch. This mostly worked after fixing a few small changes in the kernel API. 
But reversing the patch touched a ton of files unrelated to SN2. I used claude and did this for v5.4 and 5.5, but 
I knew this wasn't a good way to do this.

---

So I started a new project and chat in claude and sent this as the prompt:

> We need to cleanly re-add support for SN2 to the linux kernel post 5.4. We need to do this without major changes to the existing ia64 code since during the removal a lot of major changes happened. Reversing these changes may bring back bugs or bad code especially as we try to bring SN2 back into newer kernels.
> 
> Attached is 5.4-clean.tar.xz. This is clean 5.4 tree with no changes. Use this to test the patches you generate.
> sn2-reverse.patch is the patch which removed sn2 and made major changes to the ia64 code.
> sn2-v5.4-split-patches-v3.tar.xz is a corrected patch set which cleanly adds sn2 back into v5.4. This should be your reference. We should change these as needed.
> 
> Read the two .md files in the project for more context: sn2-readdition-analysis.md and sn2-split-patches-README.md 
> 
> Keep notes in a PLAN.md file during this process.
> 
> Remember that the goal is to touch non SN2 specific code and build files as little as possible. I do not want to re-implement the machvec infrastructure that was removed in 5.4. It was removed for a good reason.
> 
> If you need additional files, let me know.
> Lets go over your planned changes before executing on them.

And it generated a [plan](img/blog/008-PLAN-v5.4.md) and generated the patches. And after a few build issues and one DMA issue on boot, it works. 
All without reimplementing machvec and touching all arch/ia64 files. This gave me the confidence to continue moving up in versions.

So I started working through the versions,  5.4 -> 5.5 -> 5.10 -> 5.15 -> 6.1 -> 6.2 -> 6.3 -> 6.4 -> 6.6,  
and then jumped to 6.16 with the [Linux v6.16-eipc2 patches](https://github.com/linux-ia64/linux-ia64/releases/tag/v6.16-epic2).

I kept track of the patches in this repo: [https://github.com/nsafran1217/sn2-kernel-tools/tree/main/diff](https://github.com/nsafran1217/sn2-kernel-tools/tree/main/diff).  
Also contained in the repo is some build scripts, some notes on bisecting issues, and my kernel configs I used for test. 
Most of the individual version directories have a readme or a fixes.md outlining the changes from the previous version.  
Not all of the patches have all of the fixes that were found during this process. For example, after v4.0, the serial console 
started behaving strangely. This was fixed with a [small patch](https://github.com/nsafran1217/sn2-kernel-tools/blob/main/diff/sn2-serial-console-bug.patch), 
but I did not confirm if all versions have the fix.

In general, my [fork of linux](https://github.com/nsafran1217/linux-sn2/tree/v6.16-sn2) has all the patches and should be used to generate patch files if needed.

---

I used a [standardized prompt](https://github.com/nsafran1217/sn2-kernel-tools/blob/main/diff/prompts.md) to start the forward porting process. 
I would provide a tar file of the clean tree, a tar file of the previous patched version, and the patch for the previous version.  
Claude would then apply the patch to the clean version, fix any rejected hunks, and look at the file for any 
changes which would prevent it from building. Obviosuly it won't catch everything since it can't compile this, 
so I would send it any issues after, instructing it to keep track of the changes and provide individual 
patch files for the fixes. At the end, it would combine the patches and confirm is applies cleanly to the clean tree.

This process worked great. Some of the versions would be done in 30 minutes. I'm sure an experience kernel dev 
could have also finished these versions in 30 minutes, but for someone with my skill level they would have taken a long time.  

#### Recurring issues
I had one difficult issue keep coming up during the process related to loading modules. This specific bug was introduced in v5.2, 
but I didn't catch it then because I didn't have any USB devices plugged in. After plugging in a keyboard and mouse 
to test modules, the issue happened almost every boot.  
Initial chats with claude did not help find this issue, so I bisected the kernel until I found the commit which introduced the bug.  
Once I had the commit and gave that to claude, it was able to determine a possible cause for the issue, and a fix. 
The cause is documented [here.](https://github.com/nsafran1217/sn2-kernel-tools/blob/main/diff/sn2-5.2-ModuleLoading/5.2-module-fixes.md#root-cause-vm_flush_reset_perms-causes-extra-shub-tlb-flushes)

After jumping to v6.16 from 6.6, the issue came back as the overrides we were using 
were no longer possible. Claude did recognize it would come back, though it recommended building modules into the kernel as a fix. 
After telling it to fix it, claude was able to implement [a fix](https://github.com/torvalds/linux/commit/875bba42b8743ce56c1625b1e9bf9dbf2a03f4fb) 
that is SN2 specific and hopefully continues to work 
for many more versions. Description [here](c:\Users\Nathan\Downloads\build-issues.md).

The real root cause is an unfinished implementation in `arch/ia64/include/asm/tlbflush.h` for `flush_tlb_kernel_range`, where they just flush all.

    static inline void flush_tlb_kernel_range(unsigned long start,
                                              unsigned long end)
    {
            flush_tlb_all();        /* XXX fix me */
    }

*24 years later, it was never fixed.*

Also during the jump to v6.16, a major bug was introduced which prevented the kernel from loading any binaries. This turned out to be a fix that 
was already introduced in other architectures, but was missed in ia64 since it was removed from Linux. 
HP Integrity and Ski were unaffected, but SN2 did not get lucky. This patch has been [applied to the linux-ia64 branch.](https://github.com/linux-ia64/linux-ia64/commit/a33ae1fea116653cea50f184c5c667cb64e5c17a)

The `sgiioc4` driver, which is IDE, was removed for the 5.15 patch since legacy IDE was removed in 5.14.  
Claude was able to [rewrite the driver](https://github.com/torvalds/linux/commit/12ab3946928b87c8b4844297d28b862079b49121) 
for `libata` so we continue to support all the original Altix hardware.

### Conclusion

At this point, I just have to continue pushing the version forward until we reach current mainline linux, 
and then maybe the patch will be merged into the linux-ia64 fork and SN2 will be a "supported" machine type once again.

NOT FINISHED YET