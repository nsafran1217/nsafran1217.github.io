# Setting up Solaris 8 on Ultra 10
*Published: 31-May-2025 - Last Updated: 31-May-2025*

Some notes about setting up a build environment on Solaris 8, specifically my Ultra 10.

### OS
I don't have notes for the OS install. Solaris 8. 2003 release.

### Packages
I installed all these from the sunfreeware archives:

    autoconf-2.60-sol8-sparc-local     libgcc-3.4.1-sol8-sparc-local      synergy-1.3.1-sol8-sparc-local
    automake-1.7.1-sol8-sparc-local    libiconv-1.11-sol8-sparc-local     tar-1.26-sol8-sparc-local
    bash-3.2-sol8-sparc-local          libintl-3.4.0-sol8-sparc-local     vim-7.0-sol8-sparc-local
    binutils-2.21.1a-sol8-sparc-local  libtool-1.5-sol8-sparc-local       wget-1.10.2-sol8-sparc-local
    gcc-3.4.6-sol8-sparc-local         m4-1.4.7-sol8-sparc-local          xv-3.10a-sol8-sparc-local
    gettext-0.14.1-sol8-sparc-local    make-3.81-sol8-sparc-local         zlib-1.2.3-sol8-sparc-local

`pkgadd -d filename`

Make symlink from libintl-3.4.0 to libintl.so.8:  
`ln -s libintl.so.3.4.0 /usr/local/lib/libintl.so.8`

Lots of software was installed from the 4 CDs that the OS comes on, including OpenGL from the Supplemental CD.

### GCC 4.6.4
Starting with the packages above. Make sure you use GNU tar to extract. I put `/usr/local/bin` first in `$PATH`.

To add /usr/local/lib to the system library search path:
`crle -l /usr/lib:/usr/lib/secure:/usr/local/lib`  

We want 32 bit ABI for the following.
`export ABI=32`

All were just `./configure; make; make install`. Easy.
1. gmp-4.3.2
2. mpfr-2.4.2
3. mpc-1.0.1  


We provide the paths to as and ld so that gcc can find /usr/local/lib/gcc/sparc-sun-solaris2.8/3.4.6/sparcv9/crt1.o. Also, unset the ABI so we get multilib support.

    unset ABI
    ./configure --prefix=/usr/local/gcc-4.6.4 --enable-languages=c,c++ --disable-nls --enable-threads=posix --with-gnu-ld --with-gnu-as --with-as=/usr/local/bin/as  --with-ld=/usr/local/bin/ld 

`make`

Quick hack needed in `sparc-sun-solaris2.8/libstdc++-v3/include/ext/concurrence.h`

On line 345, change `__GTHREAD_COND_INIT` to `__GTHREAD_COND_INITzzz` so that conditional evaluates false.

And just above that #if, add this

    #ifndef __GTHREAD_COND_INIT_FUNCTION
    #define __GTHREAD_COND_INIT_FUNCTION(p) pthread_cond_init((p), NULL)
    #endif


This ended up taking about 12 hours to compile, if not more. Maybe it would be faster if I had a SCSI disk rather than IDE in the system.

You may have luck with a slightly newer or older GCC. This process worked fine on Solaris 9, but was less smooth on Solaris 8.