# Installing T2 Linux 26.6 on SGI Altix, with GPU
*Published: 17-May-2026 - Last Updated: 21-Jul-2026*

Below are instructions for installing T2 Linux on an SGI Altix with a custom kernel that includes Altix support and patches to enable PCI GPUs to work.


### Create the ISO
Download the script from here and follow it's instructions. The vanilla T2 iso will not boot on Altix.

[https://github.com/nsafran1217/sn2-kernel-tools/tree/main/T2-SN2](https://github.com/nsafran1217/sn2-kernel-tools/tree/main/T2-SN2)

### Installation

Boot the DVD or hard drive as you would any other disk on an Altix. The serial console is already defined for you in the grub boot entry.  
*note that the timeout doesn't work on grub2 on Altix, so you need to press enter*

After pressing enter, the screen will be blank while the kernel loads. Give it time.   
The boot will take a while... Be patient.  It will likely get stuck at some points when starting services.  
It will hang on ldconfig.service/start for a while.   
Don't panic if you see a stack trace or two.  
If you get a kernel panic, reboot and try again. It appears unstable, 
but that might be my CD-ROM drive  

* Once booted, login with username=`root`, password=`password`
* Run `stone install` to start the T2 installer.
* Select `Edit partition table of` whatever disk you want  
* Select `Classsic Partitions`
* Erasing all data  
* Choose how big to make `/`. the rest will be swap  
I use ext4 for my root filesystem.

After this, you should see the partitions are mounted.

* Select `Install the system`  
* Select `Start Package Manager`  

This will install all the packages. It will take a while.  
It needs to copy ~8 GB

---

* Create a user and passwword
* Select your timezone
* Select a locale (C or English)
* Yes configure grub

When installing grub, select "edit grub.cfg" and add the following to the `linux` line:  

    rootwait modprobe.blacklist=amdgpu,radeon systemd.unit=multi-user.target

---

* select Continue
* Create a ssh host keypair
* select Continue

Quit and reboot the system.  
If you ever want the setup menu again, just run `stone`

---

*If you're running Version 26.3, after first boot, fix some issues. T2-26.3 shipped with a bad SVN database. This is not needed on any other version.*


    cd /usr/src/t2-src
    sqlite3 .svn/wc.db "delete from ACTUAL_NODE"


* Run `t2 up`
* Now you can install applications with `t2 inst`.

for example:

    t2 inst btop
    t2 inst fastfetch

Package list is here: [https://t2linux.com/packages/](https://t2linux.com/packages/)

## GPU Setup

See [this post](/blog/009-sn2-gpu.html) for tested GPUs and PCI-e bridges.

The GPU **MUST** be installed in the top PCI slot. There must not be any card installed in the slot directly below it. Follow the instructions for installing T2 on Altix. 

After first boot, load your graphics drivers if you have a card installed. 
Depending which card you have, you will either run `modprobe radeon` or `modprobe amdgpu`.  
Watch your serial console while loading. If its successful, the VGA console should change resolution.

* run `stone`
* select x11 config.  
* select Run XcfgT2 (the T2 LiveCD auto configuration)

*For me it selected the wrong driver, and I had to manually change it.*  
Edit `/etc/X11/xorg.conf` and confirm the correct driver, either `radeon` or `amdgpu`, is listed in `Section "Device"`

And launch X: `startx`

This will load TWM. Confirm that you have 3D acceration:  
`glxinfo | grep render`

You should see `Direct rendering: Yes` and your GPU driver as the renderer.

After this, remove the modprobe.blacklist from `/boot/grub/grub.cfg` for both drivers and reboot. Make sure the system comes up.  
You should probably add a fallback option in grub that has the blacklist if you have problems.

After rebooting, you can try plasma.  Make sure LD_PRELOAD is set before starting plasma or you will only have software acceleration.

    startx /usr/bin/startplasma-x11

## Known Issues

* Wayland does not work well
* The login manager does not work (it uses wayland)
* The GPU driver sometimes crashes under very heavy load
* SN2 devices (IOC4) must be built into the kernel. They do not work as modules.
