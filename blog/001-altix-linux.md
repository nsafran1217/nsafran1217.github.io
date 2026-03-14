# Modern Linux on SGI Altix
*Published: 22-May-2025 - Last Updated: 23-May-2025*

I recently purchased two SGI Altixes, [an Altix 350 and Altix 3700.](/computers/sgi/altix.html)
The IA64 Altix computers came with a RHEL based distro, then switched to SuSE Enterprise Linux Server (SLES). The latest officially supported is SLES 11, which I installed fine on both atlixes.  
SLES works okay, but I've found that using it is difficult as there don't seem to be any archives of packages for it avaliable.

I know others have gotten Debian to install on the Altix, but I was looking for a more modern OS. 
I first attempted to install Gentoo, which did work, but since Gentoo removed IA 64 support, I dont think its worth documenting this process. 
My rough notes are here:  [Getting circa 2022 Gentoo IA64 on an SGI Altix 350](https://gist.github.com/nsafran1217/c51affd600a221dfd1e22941ad069cb3)

### T2 SDE Linux
I was pointed at  [T2 SDE Linux](https://www.t2sde.org/), which is a source based distro that supports IA64, by one of the devs working on out of branch Linux kernel support for IA64.

I bootstrapped T2 from my Gentoo install, but I think it should be possible to do it from a SLED 11 install as well.

UNDER CONSTRUCTION: I will clean up these notes next time I install on the Altix 3700. I also need to figure out elilo on T2.

[Very rough notes.](https://gist.github.com/nsafran1217/d9dda0427704fd5ff18ab06df0cbb2eb)
