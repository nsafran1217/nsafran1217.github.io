# Recovering a corrupt XSCF on a SPARC Enterprise server
*Published: 21-Jul-2026 - Last Updated: 21-Jul-2026*

I recently recieved a Fujitsu SPARC Enterprise M4000 server, however, the XSCF failed to boot properly with the following error:

    ***** WARNING *****
    XSCF initialization terminate,
    because there is no XSCF-Firmware in this XSCF board.
    Please install XSCF-Firmware.

    *** SCF_INIT was set FACTORY mode automatically. ***

    login: default
    login: cannot run /scf/bin/bash: No such file or directory.

*Without the XSCF, we cannot even turn on the server.*

Thankfully, someone uploaded the firmware for the M4000/M5000 to archive.org:  
[https://archive.org/details/sun-xscf-firmware-ffxcp1124](https://archive.org/details/sun-xscf-firmware-ffxcp1124)

I was given the M3000 XSCF firmware by someone and uploaded it to archive.org:  
[https://archive.org/details/ikxcp-1124.tar](https://archive.org/details/ikxcp-1124.tar)

The file name is FFXCP1124 for the M4000/M5000 and IKXCP1124 for the M3000. **Its very important to use the correct file.**


I fed the firmware to claude and asked it to find a recovery path, and it did!  
That saved me a lot of time digging through the rootfs image to find the recovery mechanism.

### The recovery process

The hint here in the output is `*** SCF_INIT was set FACTORY mode automatically. ***`. This gives us a path back in.

When in factory mode, the root user's login shell is changed from `/bin/false` to `/bin/sh`.

We can login as user `root` with password `scfroot`

    (none) login: root
    Password:
    login[111]: root login  on `console'

    BusyBox v1.00 (2010.06.15-08:05+0000) Built-in shell (ash)
    Enter 'help' for a list of built-in commands.

    XSCF>

Get the first interface's MAC address and connect it to your network:

    XSCF> ifconfig -a
    eth0      Link encap:Ethernet  HWaddr 00:E0:0C:00:00:FD
              BROADCAST MULTICAST  MTU:1500  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
              Base address:0xe000
    .......

Now, you need an FTP server setup with root permitted to login.  
*The FTP credentials are hard coded and cannot be changed.*

The FTP username is `root` and the password is `scfroot`. 

At least on debian with vsftp, you can permit root login by removing `root` from `/etc/ftpusers` and restarting the service. 
You'll also need to change root's password.  
I recommend testing on another computer that root successfully logs in.

Place the correct firmware file in the FTP directory (FFXCP1124.tar.gz or IKXCP1124.tar.gz) and run the following command on the XSCF:


`/root/standalone_flashup interface_MAC my_ip gateway_ip subnet_mask ftp_server_ip /FTPpath/to/FFXCP1124.tar.gz`

Example:  

`/root/standalone_flashup 00:E0:0C:00:00:FD 10.40.0.143 10.40.0.1 255.255.255.0 10.40.0.120 /nfs/drop/FFXCP1124.tar.gz`

And thats it! The firmware will be replaced with the upladed version and the XSCF will reboot a few times. 
From there, you can login with the username `default` and follow the prompts to get logged in.


/root/standalone_flashup is just a shell script, so if you're curious, you can extract it from the firmware packages linked above to find out more about how it works.


## Full process:



    XSCF uboot  01100001  (Feb  3 2011 - 14:43:12)


    XSCF uboot  01100001  (Feb  3 2011 - 14:43:12)

    SCF board boot factor = a080
    memory test ..
    Memory compare test
    ................finish
        DDR Real size: 256 MB
        DDR: 224 MB

    Hit any key to stop autoboot:  0
    ## Booting image at ff800000 ...
       Image Name:   XSCF kernel 01120000 2.6.11.12-s
       Image Type:   PowerPC Linux Kernel Image (gzip compressed)
       Data Size:    1459019 Bytes =  1.4 MB
       Load Address: 00000000
       Entry Point:  00000000
       Verifying Checksum ... OK
       Uncompressing Kernel Image ... OK
    ## Loading RAMDisk Image at ff980000 ...
       Image Name:   XSCF rootfs 01120000 ,2015/07/02
       Image Type:   PowerPC Linux RAMDisk Image (gzip compressed)
       Data Size:    5658385 Bytes =  5.4 MB
       Load Address: 00000000
       Entry Point:  00000000
       Verifying Checksum ... OK
       Loading Ramdisk to 0ba9a000, end 0bfff711 ... OK
    Linux version 2.6.11.12-sec (gcc version 3.4.4) #1 Thu Jul 2 11:27:05 JST 2015
    new message buffer at 0f700000 size 1048576
    log_buf_len: 1048576
    mpc85xx_cds_setup_arch
    Built 1 zonelists
    Kernel command line: root=/dev/ram rw console=ttyS0,9600 init=/sbin/init_change_root panic=1 mem=224M
    OpenPIC Version 1.2 (1 CPUs and 44 IRQ sources) at fbe79000
    PID hash table entries: 1024 (order: 10, 16384 bytes)
    Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
    Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
    Memory: 218496k available (2192k kernel code, 672k data, 320k init, 0k highmem)
    Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
    Freeing initrd memory: 5525k freed
    RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
    i2c-algo-cpm: CPM2 I2C algorithm module version 0.1 (Mar 22, 2005)
    FCC ENET Version 0.3
    TCP established hash table entries: 8192 (order: 4, 65536 bytes)
    TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
    ip_tables: (C) 2000-2002 Netfilter core team
    arp_tables: (C) 2002 David S. Miller
    VFS: Mounted root (ext2 filesystem).
    Freeing unused kernel memory: 320k init
    switching initrd filesystem, ramdisk to tmpfs
    SCF Linux Boot Script 2006/03/04 for ROM boot environment
    fsl-sec2 hardware crypt accelerator model3a ver 0.02 enabled

    XSCF initial process start (pid=106)


    login: load /scf/modules/lites_ldrv.ko  --  complete
    load /scf/modules/drvscftrace.ko  --  complete
    load /scf/modules/sec2_rsa.ko  --  complete
    load /scf/modules/sec2_md5.ko  --  complete
    load /scf/modules/sec2_des.ko  --  complete
    load /scf/modules/sec2_arc4.ko  --  complete
    load /scf/modules/sec2_aes.ko  --  complete
    load /scf/modules/sec2_sha256.ko  --  complete
    load /scf/modules/sec2_sha1.ko  --  complete
    load /scf/modules/hw_random.ko  --  complete
    load /scf/modules/scsi_mod.ko  --  complete
    load /scf/modules/sd_mod.ko  --  complete
    load /scf/modules/usbcore.ko  --  complete
    load /scf/modules/ohci-hcd.ko  --  complete
    load /scf/modules/usb-storage.ko  --  complete
    load /scf/modules/drvbootfmem.ko  --  complete
    load /scf/modules/drvmbc.ko  --  complete


    ***** WARNING *****
    XSCF initialization terminate,
    because there is no XSCF-Firmware in this XSCF board.
    Please install XSCF-Firmware.

    *** SCF_INIT was set FACTORY mode automatically. ***


    root
    Password:
    Login incorrect
    (none) login: root
    Password:
    login[111]: root login  on `console'



    BusyBox v1.00 (2010.06.15-08:05+0000) Built-in shell (ash)
    Enter 'help' for a list of built-in commands.

    XSCF> ifconfig -a
    eth0      Link encap:Ethernet  HWaddr 00:E0:0C:00:00:FD
              BROADCAST MULTICAST  MTU:1500  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
              Base address:0xe000

    eth1      Link encap:Ethernet  HWaddr 55:55:55:55:72:6F
              BROADCAST MULTICAST  MTU:1500  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
              Base address:0xc000

    eth2      Link encap:Ethernet  HWaddr 00:E0:0C:80:00:FD
              BROADCAST MULTICAST  MTU:1500  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
              Base address:0x8400

    lo        Link encap:Local Loopback
              LOOPBACK  MTU:16436  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

    XSCF> /root/standalone_flashup -h
    standalone_flashup my_mac my_ip gate_ip netmask svr_ip xcpfile
                    [-u ftp_server_user -p ftp_server password]
            my_mac:         MAC address of my SCF board
            my_ip:          IP address of my SCF board
            gate_ip:        IP address of gateway
            netmask:        subnet mask value
            svr_ip:         ftp server IP address
    xcpfile:        loading XCP tar.gz filename

    caution! ftp server account/password is a fixed value

    XSCF> /root/standalone_flashup 00:E0:0C:00:00:FD 10.40.0.143 10.40.0.1 255.255.255.0 10.40.0.120 /nfs/drop/FFXCP1124.tar.gz
    eth0: PHY is Intel LXT972A (1378e2)
    eth0      Link encap:Ethernet  HWaddr 00:E0:0C:00:00:FD
              inet addr:10.40.0.143  Bcast:10.255.255.255  Mask:255.255.255.0
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:13 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:1079 (1.0 KiB)  TX bytes:0 (0.0 B)
              Base address:0xe000

    lo        Link encap:Local Loopback
              inet addr:127.0.0.1  Mask:255.0.0.0
              UP LOOPBACK RUNNING  MTU:16436  Metric:1
              RX packets:0 errors:0 dropped:0 overruns:0 frame:0
              TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    10.40.0.0       *               255.255.255.0   U     0      0        0 eth0
    default         10.40.0.1       0.0.0.0         UG    0      0        0 eth0
    network setting is OK ?y
    NAND driver loading
    Using /scf/modules/drvnand.ko
    erace all NAND devices
            erase /dev/mtd0...
            erase /dev/mtd1...
            erase /dev/mtd2...
            erase /dev/mtd3...
            erase /dev/mtd4...
            erase /dev/mtd5...
            erase /dev/mtd6...
            erase /dev/mtd7...
            erase /dev/mtd8...
            erase /dev/mtd9...
            erase /dev/mtd10...
            erase /dev/mtd11...
            erase /dev/mtd12...
            erase /dev/mtd13...
    mounting NAND decices
            /hcp0/linux...
            /hcp0/scfprog...
            /hcp0/gendata...
            /hcp0/remcscm...
            /hcpcommon/setup...
            /hcpcommon/obp...
            /hcpcommon/tmp...
            /hcp1/linux...
            /hcp1/scfprog...
            /hcp1/gendata...
            /hcp1/remcscm...
            /hcpcommon/var...
            /hcpcommon/scflog1...
            /hcpcommon/scflog2...
    ftp server: 10.40.0.120
    ftp server name OK ?y
    -rwxr-xr-x    1 root     root     47481420 Jan  1 13:18 /tmp/FFXCP1124.tar.gz
    -rw-rw-rw- 0/0      2048 2018-07-06 03:09:35 hcpinfo_0003_1124
    -rw-rw-rw- 0/0   1455293 2016-01-29 02:06:24 kernel_0003_01120001.gz
    -rw-rw-rw- 0/0   5580016 2018-07-05 12:13:22 root_0003_01120004.gz
    -rw-rw-rw- 0/0     77579 2011-02-04 00:47:05 uboot_0003_01100001.gz
    -rw-rw-rw- 0/0  20784568 2018-07-05 12:13:49 linux_0003_01120004.gz
    -rw-rw-rw- 0/0  15699664 2018-07-05 12:14:19 scfprog_0003_01120004.gz
    -rw-rw-rw- 0/0   3783238 2012-10-25 10:14:55 gendata_0003_01110004.gz
    -rw-rw-rw- 0/0    523514 2015-07-02 07:21:00 remcscm_0003_01120000.gz
    -rw-rw-rw- 0/0    619128 2012-08-31 00:34:46 obp_0003_02320000.gz
    -rw-rw-rw- 0/0        93 2018-07-06 03:09:57 sign_0003_1124
    XCP archive file is OK ?y
            /hcp0/linux:    linux
    extracting XCP:linux_0003_01120004.gz archive start
    linux_0003_01120004.gz
    extracting XCP:linux_0003_01120004.gz archive end
            /hcp0/scfprog:  scfprog
    extracting XCP:scfprog_0003_01120004.gz archive start
    scfprog_0003_01120004.gz
    extracting XCP:scfprog_0003_01120004.gz archive end
            /hcp0/gendata:  gendata
    extracting XCP:gendata_0003_01110004.gz archive start
    gendata_0003_01110004.gz
    extracting XCP:gendata_0003_01110004.gz archive end
            /hcp0/remcscm:  remcscm
    extracting XCP:remcscm_0003_01120000.gz archive start
    remcscm_0003_01120000.gz
    extracting XCP:remcscm_0003_01120000.gz archive end
            /hcp1/linux:    linux
    extracting XCP:linux_0003_01120004.gz archive start
    linux_0003_01120004.gz
    extracting XCP:linux_0003_01120004.gz archive end
            /hcp1/scfprog:  scfprog
    extracting XCP:scfprog_0003_01120004.gz archive start
    scfprog_0003_01120004.gz
    extracting XCP:scfprog_0003_01120004.gz archive end
            /hcp1/gendata:  gendata
    extracting XCP:gendata_0003_01110004.gz archive start
    gendata_0003_01110004.gz
    extracting XCP:gendata_0003_01110004.gz archive end
            /hcp1/remcscm:  remcscm
    extracting XCP:remcscm_0003_01120000.gz archive start
    remcscm_0003_01120000.gz
    extracting XCP:remcscm_0003_01120000.gz archive end
            /hcpcommon/setup:       setup
            /hcpcommon/obp: obp
            /hcpcommon/var: var
            /hcpcommon/scflog1:     scflog1
            /hcpcommon/scflog2:     scflog2
            /hcpcommon/tmp: tmp
    NOR driver loading
    Using /scf/modules/drvbootfmem.ko
    insmod: cannot insert `/scf/modules/drvbootfmem.ko': File exists (-1): File exists
            kernel:
    extracting XCP:kernel_0003_01120001.gz archive start
    kernel_0003_01120001.gz
    extracting XCP:kernel_0003_01120001.gz archive end
            kernel:device 0
            kernel:device 1
            root:
    extracting XCP:root_0003_01120004.gz archive start
    root_0003_01120004.gz
    extracting XCP:root_0003_01120004.gz archive end
            root:device 0
            root:device 1
            uboot:
    extracting XCP:uboot_0003_01100001.gz archive start
    uboot_0003_01100001.gz
    extracting XCP:uboot_0003_01100001.gz archive end
            uboot:device 0
            uboot:device 1
    unmounting NAND decices
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
            /hcpcommon/tmp...
    nvram page 0 cleared
    nvram page 1 cleared
    nvram page 2 cleared
    nvram page 3 cleared
    nvram page 4 cleared
    nvram page 5 cleared
    nvram page 6 cleared
    nvram page 7 cleared

    install completed, please restart SCF


    XSCF> reboot
    The system is going down NOW !!
    Sending SIGTERM to all processes.
    Please stand by while rebooting the system.(15)
    Restarting system.


