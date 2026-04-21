# Installing T2 Linux 26.3 on SGI Altix
*Published: 20-Apr-2026 - Last Updated: 20-Apr-2026*

ROUGH FIRST DRAFT



### Create the ISO
Download the script from here and follow it's instructions

[https://github.com/nsafran1217/sn2-kernel-tools/tree/main/T2-SN2](https://github.com/nsafran1217/sn2-kernel-tools/tree/main/T2-SN2)

### Installation

Boot the DVD as you would any other disk on an Altix. The serial console is already defined for you in the grub boot entry.  
*note that the timeout doesn't work on grub2 on Altix, so you need to press enter*

The boot will take a while... Be patient.  It will likely get stuck at some points when starting services.  
It will hang on ldconfig.service/start for a while. 5+ minutes   
Also don't panic if you see a stack trace or two.  
If you get a kernel panic, reboot and try again. Its a little unstable.   


Once booted, login with username=`root`, password=`password`

Clear off the disk you want to install to before starting the installer.
```
fdisk /dev/sdX
g
w
```
If you get a message that the kernel still uses the old partition, reboot and start the installer.


Run `stone install` to start the T2 installer.

Select `Edit partition table of` whatever disk you want  
Select `Classsic Partitions`
Erasing all data  
Choose how big to make `/`. the rest will be swap  
I use ext4  

After this, you should see the partitions are mounted, if they are not, exit stone and use fdisk to write a new gpt partition table to the disk, and reboot.

Select `Install the system`  

Select `Start Package Manager`  
This will install all the packages. It will take a while.  

It needs to copy 7.7GB

---

Create a user

pick a timezone

pick a local (C)

Yes configure grub

When installing grub, select "edit grub.cfg" and add the following to the `linux` line:  
```
rootwait modprobe.blacklist=amdgpu,radeon console=ttySG0,38400n8 systemd.unit=multi-user.target
```
I also remove the whole if block so the console goes to the serial console, and remove the `resume=` option

---

select Continue

Create a ssh host keypair

Continue

And you can quit and reboot. If you ever want the setup menu again, just run `stone`

---

After first boot, fix some issues. This version of T2 shipped with a bad SVN database.

```
cd /usr/src/t2-src
sqlite3 .svn/wc.db "delete from ACTUAL_NODE"
t2 up
```

Now you can install applications with `t2 inst`. I recommend not installing optional dependencies.

for example:

```
tw inst btop
t2 inst fastfetch
```


### GPU

After first boot, load your graphics drivers if you have a card installed. Either modprobe radeon or modprobe amdgpu.
If it loads, you should see the VGA console change resolution

run stone, goto x11 config.
run the first option. For me it selected the wrong driver,
I had to change radeon to amdgpu in /etc/X11/xorg.conf

run this command before starting X:  
```
export LD_PRELOAD="/usr/lib/libgallium-26.0.1.so /usr/lib/libGLX_mesa.so.0 /usr/lib/libEGL_mesa.so.0.0.0"
```
startx

After this, remove the blacklist grom /boot/grub/grub.cfg for both drivers and reboot. Make sure the system comes up.
You should probably add a fallback option in grub that has the blacklist if you have problems.


After rebooting, you can try plasma.
export LD_PRELOAD="/usr/lib/libgallium-26.0.1.so /usr/lib/libGLX_mesa.so.0 /usr/lib/libEGL_mesa.so.0.0.0"


startx /usr/bin/startplasma-x11
