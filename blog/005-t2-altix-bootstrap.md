# Bootstraping T2 SDE Linux on SGI Altix From SLES
*Published: 10-Jun-2025 - Last Updated: 13-Mar-2026*

T2 SDE is a source based linux distribution and package manager that runs on many different architectures. It is one of the last Linux distros that support IA64, and has been ported to some MIPS SGI machines as well.

In my opinion, T2 is the best option in 2025 for a modern Linux on SGI Altix. 

# Overview
To get T2 on an Altix, you can either build the disk on another system, or you can bootstrap from the Atlix. I'm going to bootstrap from SLES11 SP3, with Linux kernel versions 3.14.79 and 4.19.325. I'll explain why those 2 versions and the changes needed to get them running later.

The steps are roughly:  

1. Create T2 root disk tarball from T2 ISO
2. Use IA64 cross compiler to compile Linux kernel
3. Boot SLES11 SP3 DVD into rescue mode and setup networking
4. Format destination disk
5. Copy T2 onto disk
6. `chroot` into T2
7. Configure T2
8. Configure EFI partition

### T2 root disk from ISO

[Script to generate root FS from ISO](https://gist.github.com/johnny-mnemonic/debbe04cb11532ff894297b18f5d0180)


    sudo ./t2trap.bash ia64 t2-24.12-ia64-base-desktop-glibc-gcc-itanium2.iso full
    cd ia64
    sudo tar cf ../t2-ia64full.tar .
    



## Cross compile Linux Kernel
### Kernel Versions:
I am a beginer when it comes to customizing the Linux kernel. These are my observations. This may change if I fix more issues in the later kernel.
#### 3.14.79:
The last working kernel with a simple patch to fix a compile issue. This kernel works well over the serial console, but I can't get SSH or NFS working on it. `svn up` also fails on this version. I assume there are compatibility issues with the binaries included with T2 and the kernel. I recommend using this for initial setup since the serial console works well.

#### 4.19.325
With 1 additional patch, this kernel works well. The biggest issue is with the serial console. It seems to drop input, or not echo your input back until you send another character. SSH, NFS, and other tools work correctly on this kernel. I recommend using this kernel version.

### 3.14.79 Patch:
All you need to do is change `u64` to `unsigned long` in the `sn_dma_flush` function in `arch/ia64/sn/pci/pcibr/pcibr_dma.c`:

    diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    index 1e863b277ac9..6b632c290af2 100644
    --- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    +++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    @@ -235,7 +235,7 @@ pcibr_dma_unmap(struct pci_dev *hwdev, dma_addr_t dma_handle, int direction)
      * unlike the PIC Device(x) Write Request Buffer Flush register.
      */

    -void sn_dma_flush(u64 addr)
    +void sn_dma_flush(unsigned long addr)
     {
            nasid_t nasid;
            int is_tio;

### 4.19.325 Patch:
You need to make the patch above, as well as adding one line in arch/ia64/sn/kernel/io_init.c. `res->flags &= ~IORESOURCE_UNSET;`. Below is a combined patch.   


    diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    index 1e863b277ac9..6b632c290af2 100644
    --- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    +++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
    @@ -235,7 +235,7 @@ pcibr_dma_unmap(struct pci_dev *hwdev, dma_addr_t dma_handle, int direction)
      * unlike the PIC Device(x) Write Request Buffer Flush register.
      */

    -void sn_dma_flush(u64 addr)
    +void sn_dma_flush(unsigned long addr)
     {
            nasid_t nasid;
            int is_tio;
    
    diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
    index d63809a6adfa..2446ffa0957a 100644
    --- a/arch/ia64/sn/kernel/io_init.c
    +++ b/arch/ia64/sn/kernel/io_init.c
    @@ -195,6 +195,9 @@ sn_io_slot_fixup(struct pci_dev *dev)
     		if (res->parent && res->parent->child)
     			release_resource(res);
    
    +		/* Ensure resource is marked as assigned so parent lookups succeed */
    +		res->flags &= ~IORESOURCE_UNSET;
    +
     		if (res->flags & IORESOURCE_IO)
     			insert_resource(&ioport_resource, res);
     		else

### Kernel Config

Here is my kernel config. It is very bare bones, however, I will update it as needed. I'm still debugging some issues.
Link: [https://gist.github.com/nsafran1217/e9a5732999334a5df8c50b2ce314a92b#file-sn2-config](https://gist.github.com/nsafran1217/e9a5732999334a5df8c50b2ce314a92b#file-sn2-config)


### Cross Compiling

Download the cross toolchain from here: [https://ftp.machine-hall.org/pub/toolchains/x86_64/](https://ftp.machine-hall.org/pub/toolchains/x86_64/)    
Thanks to [Johnny Mnemonic for this](https://github.com/johnny-mnemonic)

I used gcc-14.2 on Ubuntu 24.04. You need this gcc first in your PATH.

Put my config in the linux source tree and run this:  
`make ARCH=ia64 CROSS_COMPILE=ia64-linux- olddefconfig`

If you need to modify the config, you can use menuconfig:  
`make ARCH=ia64 CROSS_COMPILE=ia64-linux- menuconfig`

And this command to make it:  
`make -j$(nproc) ARCH=ia64 CROSS_COMPILE=ia64-linux- tar-pkg scripts/kconfig/conf  --syncconfig Kconfig`


Additional References:

http://epic-slack.org/#!articles/2024-12-15-building-your-own-kernel.md

https://github.com/linux-ia64/linux-stable-rc/blob/__mirror/.github/workflows/mirror.yml#L124



## Booting SLES11
Im going to assume you know how to get to the EFI console on an SGI Altix.  
Read this if you don't: [007-5640-001: Chapter 2. Software Planning and Installation](https://techpubs.jurassic.nl/library/manuals/5000/007-5640-001/sgi_html/ch02.html)

Boot from the DVD. Your filesystem device may be different:  
`fs0:\> efi\boot\bootia64.efi`  
Arrow key down to rescue system and add the correct boot flags:  
`boot: console=ttySG0,38400n8`

### Networking in rescue mode
`ifconfig eth0 <ip address> netmask <netmask value>`  
`route add default gw <route value> dev eth0`  
Edit `resolv.conf` and add a nameserver if you need DNS.

I mount my NFS server, but you can get the files to the system however you want:  
`mkdir /nfs`  
`mount -o nolock nfs_server:/nfs /nfs`

### Partitioning

I only have one disk installed while doing this, so my disk is /dev/sda. Please confirm with lsblk that you are working on the correct disk. I made a 2GB EFI partition and 98GB root. You can change these or add swap if you want. We are going to format root as XFS since SLES11 has XFS support.

    Rescue:~ # parted /dev/sda
    GNU Parted 2.3
    Using /dev/sda
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) mklabel gpt
    Warning: The existing disk label on /dev/sda will be destroyed and all data on
    this disk will be lost. Do you want to continue?
    Yes/No? yes
    (parted) unit GB
    (parted) mkpart
    Partition name?  []?
    File system type?  [ext2]? fat32
    Start? 0
    End? 2GB
    (parted) mkpart
    Partition name?  []?
    File system type?  [ext2]? xfs
    Start? 2GB
    End? 100GB
    (parted) set 1 esp on
    (parted) quit
    Information: You may need to update /etc/fstab.


### Formatting
`mkfs.vfat /dev/sda1`  
`mkfs.xfs /dev/sda2`

### mount
`mkdir /mnt/t2`  
`mount /dev/sda2 /mnt/t2`

---
### Copying T2 to root disk
Lets extract the T2 root tar into the new disk.

`cd /mnt/t2`  
`tar xf /nfs/altix/t2/t2-ia64full.tar`

Grab your kernels. I copy the tars in /mnt/t2/root. I'm going to setup both versions.

    cd /mnt/t2/root
    tar xf linux-4.19.325-NS-SN2-ia64.tar
    tar xf linux-4.19.325-NS-SN2-ia64.tar
    cp boot/* /mnt/t2/boot
    cp -r lib /mnt/t2/

---
### chroot to T2
So I have NFS available in T2:  
`mkdir /mnt/t2/nfs`  
`mount --bind /nfs /mnt/t2/nfs`  
`mount --make-slave /mnt/t2/nfs`  

    mount --types proc /proc /mnt/t2/proc
    mount --rbind /sys /mnt/t2/sys
    mount --make-rslave /mnt/t2/sys
    mount --rbind /dev /mnt/t2/dev
    mount --make-rslave /mnt/t2/dev
    mount --bind /run /mnt/t2/run
    mount --make-slave /mnt/t2/run

    chroot /mnt/t2/ /bin/bash
    source /etc/profile

### Initial T2 configuration
run `passwd` to set a root password  
edit `/etc/resolv.conf` and setup DNS  

In `/etc/inittab`, we need to add the SGI ttySG0 device as a console, otherwise, you won't be able to login via the L2 console.

Add this line. I added it around line 62 near the other virtual consoles. Re-number the other virtual consoles if needed.  
`0:12345:respawn:/sbin/agetty --noclear 38400 ttySG0 linux`  
My file has this under Virtual Consoles:

    0:12345:respawn:/sbin/agetty --noclear 38400 ttySG0 linux
    1:12345:respawn:/sbin/agetty -L -J -i -I '\012\015' tty1 linux
    2:12345:respawn:/sbin/agetty -f /etc/issue.ansi tty2 linux
    3:12345:respawn:/sbin/agetty -f /etc/issue.ansi tty3 linux
    4:12345:respawn:/sbin/agetty -f /etc/issue.ansi tty4 linux
    5:12345:respawn:/sbin/agetty -f /etc/issue.ansi tty5 linux
    6:12345:respawn:/sbin/agetty -f /etc/issue.ansi tty6 linux

### EFI elilo setup
I couldn't get grub working, so we'll stay with elilo.

    mkdir /boot/efi
    mount /dev/sda1 /boot/efi
    mkdir /boot/efi/EFI

[Download elilo-3.16-all.tar.gz](https://sourceforge.net/projects/elilo/files/elilo/elilo-3.16/)
Extract it, copy elilo-3.16-ia64.efi to /boot/efi/EFI/


We don't have efivars, so we need to manually setup the EFI partition for now.

    cd /boot
    mkdir /boot/efi/EFI/boot
    cp vmlinux-4.19.325-NS-SN2 efi/EFI/boot/
    cp vmlinux-3.14.79-NS-SN2 efi/EFI/boot/
    vi /boot/efi/EFI/elilo.conf

`/boot/efi/elilo.conf`:

    # boot=/dev/sda1
    delay=30
    timeout=30
    default=t2-419
    append="console=ttySG0,38400n8"
    relocatable
    prompt

    image=/EFI/boot/vmlinux-4.19.325-NS-SN2
            label=t2-419
            root=/dev/sda2
            read-only
    image=/EFI/boot/vmlinux-3.14.79-NS-SN2
            label=t2-314
            root=/dev/sda2
            read-only


### Reboot, we are ready to boot
Exit the chroot, and reboot.

At the efi prompt, boot elilo-3.16-ia64.efi from the disk.  
Type `t2-314` to boot the older kernel to do initial setup.

You should be booted up! If you see it finish booting but never get a login prompt, check your agetty configuration in `/etc/inittab`.

You can used `stone` to do initial setup tasks. After networking is setup, reboot into t2-419 and SSH to the system.

Now we can start installing packages from the t2 sources.

    cd /usr/src/t2-src
    svn up

    t2 install htop
    t2 install sudo


[Here's the list of packages in T2](https://t2sde.org/packages/)  
Note that not all work on Itanium

## Future work

* I want to get graphics output working via a PCI video card. 
* I want to install Java (I think Java 6 is the latest that works on IA64)
* I want to play Minecraft on an Altix


