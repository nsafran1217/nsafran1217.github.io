# Installing HP-UX 11.11 on a C360
*Published: 27-May-2025 - Last Updated: 02-Jun-2025*

I recently purchase an HP Visualize C360. This is a 64 Bit PA RISC system. I was unable to get 11.00 installed as I could not find the "HP-UX 11.00 Core OS Options CDs" disc.  
So lets just install 11.11 (aka 11i v1)

### Install Media
From the [Tenox OS Archive](http://tenox.pdp-11.ru/):

* `os/hpux/OS/11.11/2004-12 MCOE, TCOE, Apps/HP-UX 11.11 (2004-12) - TCOE - Core OS, Install and Recovery - CD1.rar` - *Boot from this one*
* `os/hpux/OS/11.11/2004-12 MCOE, TCOE, Apps/HP-UX 11.11 (2004-12) - TCOE - Core OS, Install and Recovery - CD2.rar`
* `os/hpux/OS/11.11/2004-12 MCOE, TCOE, Apps/HP-UX 11.11 (2004-12) - TCOE - Core OS, Install and Recovery - CD3.rar`
* `os/hpux/OS/11.11/2004-12 MCOE, TCOE, Apps/HP-UX 11.11 (2004-12) - Support Plus - Diagnostics and Tested Patch bundles.iso` - *Patches after install*

I connected an external SCSI CDROM (512 byte sectors, not sure if thats required) to the single ended fast wide 68 pin scsi port. My drive ID was set to 1, but it shows up as 4 on the workstation for some reason. The SEArch command will tell you what devices you have.

To Boot: `boot fwscsi.4.0`
### Install notes

* I chose the guided install and let it configure partitioning by itself. 
* I picked HP-UX 11i TCOE-64bit for the environment. I'm not sure if there's any downsides to choosing a 64 bit system.
* During software selection, I marked:
    * JAVAOOB
    * SwPkgBuilder
    * B5725AA (IgniteUX)
    * Ignite-UX-11-11
    * Ignite-UX-11-00
* Its incredible how slow the install for HP-UX is.

### Post install, install patches

* Login and run sam. Add your user. Then, open software management, Install software to local host
* With the support cd inserted, mount it: `mount /dev/dsk/c0t4d0 /SD_CDROM/`
* In the add source dialog, point at /SD_CDROM/GOLDQPK11i
* Mark both for install, click Actions->Install.

![software](/img/blog/002-software.png)

Tip for installing from ISOs:  
I mounted the Applications DVD ISO on my NFS server, and bind mounted it into my NFS export. Then, I can point `swinstall` at this location.  

    $ sudo mount -o loop /data/nfs/mirrors/osarchive/hpux/OS/11.11/2004-12\ MCOE\,\ TCOE\,\ Apps/HP-UX\ 11.11\ \(2004-12\)\ -\ TCOE\ -\ Core\ OS\,\ Install\ and\ Recovery\ -\ DVD.iso /mnt/iso
    $ sudo mount --bind /mnt/iso /data/nfs/iso

### 2009 GOLDQPK Install

I think the final GOLD pack was in 2009. This is also in Tenox's osarchive. I recommend using this file: `os/hpux/OS/11.11/HP-UX 11.11 Support Plus 2009-12.tar.lz`  
Extract it and point swinstall at GOLDQPK11i_B.11.11.0912.483.depot


### misc
I was having issues with my stty setting over telnet. I added this to my .bash_profile: `stty intr ^C erase ^H`  
Also, bash is my shell for my user.


## C compilers
The builtin cc only works for compiling the kernel. I'm going to install HP ansic and whatever version of GCC I can find. I believe GCC is only built for 32bit ABI, which is okay.

### ansic (HP aCC)
You can download ansic from from osarchive.org:  
`os/hpux/OS/11.11/ansic/B9007AA_B.11.11.20_HP-UX_B.11.11_32_64.depot.lz`

1. Run `swinstall` and open `B9007AA_B.11.11.20_HP-UX_B.11.11_32_64.depot`
2. Mark everything for install. Go to Actions->Install, and let it do its thing.


### GCC Toolchain

I'm going to install GCC 4.2.3 from this archive: http://ftp.netbsd.org/pub/pkgsrc/misc/tnn/  
This person used it to build pkgsrc a few years ago: https://vanalboom.org/node/17.html

Just untar it in `/` and add `/usr/local/gcc4/bin` to your PATH and make the headers.

    /usr/local/gcc4/libexec/gcc/hppa2.0w-hp-hpux11.11/4.2.3/install-tools/mkheaders 


### Various tools, in order
`export PATH=/usr/local/bin:/usr/local/gcc4/bin:$PATH`

*I picked these version numbers randomly*  
*Assume gcc unless otherwise specified*

make-1.79: `export CC=cc; ./configure; make` *you can probably go straight to 3.80+ here instead of 3.79*  
m4-1.4.16: `./configure; make`  
autoconf-2.69: `./configure; make`  
automake-1.6.3: `./configure; make`  
automake-1.8.5: `./configure; make`

If you get this error:  `/usr/ccs/bin/ld: Unrecognized argument: +init`  
Make sure `PHSS_39749 (s700_800 11.11 ld(1) and linker tools cumulative patch)` is installed. It is included in the 2009 Support Plus depot.  

That fixes HP's ld so it actually works.

### GCC 4.8.5

`export PATH=/usr/local/bin:/usr/local/gcc4/bin:$PATH`

I build some tools first:

1. tar-1.27.1
2. gawk-3.1.8
3. sed-4.2.2
4. grep-2.6.3
5. make-3.82
6. binutils-2.23.2: configure like this: `./configure --prefix=/usr/local/gcc-4.8.5 --disable-nls`

*I tried binutils 2.25.1 first, but it did not work correctly. It kept telling me the archive files were for 64 Bit ABI. `ar` may have been broken. 2.23.2 seems to work well*

GCC build reqs:

`export CC=gcc`  
Add binutils to PATH:  
`export PATH=/usr/local/gcc-4.8.5/bin:$PATH`  

gmp should detect `ABI=2.0n`. If not, `export ABI=2.0n`.

1. gmp-6.1.2
2. mpfr-3.1.6
3. mpc-1.0.3

I skipped `make check`. I'm lazy.

    ./configure --prefix=/usr/local/gcc-4.8.5 --enable-languages=c,c++ --disable-nls --enable-threads=posix --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --with-gnu-as --with-as=/usr/local/gcc-4.8.5/bin/as --without-gnu-ld

This compile took over 12 hours on the C360.

I ended up recompiling because I did `--without-gnu-as` the first time and that doesn't work; you want gnu as.  
I did the second compile on my C8000 with a dual core 1.1 GHz PA, and it completed in 4 ish hours.

My PATH order was:  
`export PATH=/usr/local/gcc-4.8.5/bin:/usr/local/gcc4/bin:/usr/local/bin:$PATH`

DONE. You now have GCC 4.8.5 in /usr/local/gcc-4.8.5 with GNU as V2.23.2.



## Software building
Lets try out the audio on this C360 and build mikmod and play some mod files. We'll start our attempts with ansic.

* libmikmod-3.1.10
* mikmod-3.2.7

libmikmod built wihtout issues.  
mikmod is having issues with HP's curses. I'm going to try to build ncurses.

* ncurses-5.2

Built with ./configure and installed into /usr/local

mikmod: `./configure CPPFLAGS="-I/usr/local/include -I/usr/local/include/ncurses" LDFLAGS="-L/usr/local/lib"`  
Then I get this error:  

    usr/ccs/bin/ld: Unsatisfied symbols:
        __getmaxy (code)
        __getmaxx (code)

Now, on line 162 in `src/mwindow.c`, we run into an issue since its assuming we have the broken HP-UX curses. Just change the name of the variable in `#if defined(__hpux)` to make it not define those macros.

*And, success!*  We have sound output on the C360! Eventually, I want to figure out if a new mikmod works out of the box without changes.

*I failed to make ncurses 6.5 work because the the test program for mikmod wont build with aCC. I need GCC for that to work I believe. Leave notes here for future work with GCC.*

ncurses-6.5  
Fetched from gnu and it built without any issues. Build non wide character support:  
`./configure --prefix=/usr/local --with-shared --with-normal --with-termlib --disable-widec`



## Adding a second disk
I quickly ran low on disk space with a 9GB disk, so I added a second one to put /home and /usr/local on.

In SAM, Disks and File systems, I selected the disk, Actions->Configure. I added this to a new Volume Group, vg01.

Next, I went to Logical Volumes and created 2 new LVs, both 1GB each, to allow room to grow the LVs in the future.
Next, I went to file systems and mounted the new LVs in temporary locations. I copied all the data to the new filesystem. `cd /home; tar cpf - . | (cd /home2 && tar xpf -)`

Then, unmounted the old ones, mounted the new ones in the correct locations, and made sure the new LVs didn't automount and the new ones did. My LVs look like this now:

![LVM](/img/blog/002-lv.png)

I also added my NFS server to auto mount at startup in Filesystems.