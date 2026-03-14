# Configuring an HP Integrity rx2800 i2
*Published: 11-Nov-2025 - Last Updated: 11-Nov-2025*

I recently picked up an HP Integrity rx2800 i2 server in a lot of server equipment. This is the newest Itanium server I own. In this article I will walk through configuring the system including setting up RAID array on the integrated p410i controller and installing HP-UX 11.31, along with installing setting up a GCC toolchain (eventually).

### First powerup
When I first powered on the server, all the warning lights for the RAM, were lit. It looks like somebody took RAM out of the server and reinstalled the RAM riser in the wrong slot. Following the diagrams on the lid, I moved the RAM into a valid configuration. Currently I have 64GB of RAM, which is way more than I need.

The RAM test on these machines takes a long time. The POST on this system takes over 5 minutes.

### iLO password

I followed [these instructions](https://portal-iam-ext-pro.it.hpe.com/hpesc/public/docDisplay?docId=c02728748&docLocale=en_US) to reset the iLO password. 
Note that the username is Administrator on this version of iLO/MP, not Admin like the older servers.  
Make sure you set a password for Administrator before the timer 15 minute timer runs out.

### Configuring a RAID array on the p410i
There's no graphical menu on this system like the rx2660, so you need to drop to the EFI shell to load the array configration tool. The [HP Integrity rx2800 i2 Server User Service Guide](https://community.hpe.com/hpeb/attachments/hpeb/itrc-275/13000/1/rx2800-Maint.pdf) is a great reference.

* Drop to to EFI shell by pressing S at the boot menu.
* Find out the Driver ID and CTRL ID (Page 147 of the PDF linked above)
* * Run `drivers`  and find the SAS Host Bus Adapter. The ID is the left most column. My controller name was `Smart Array SAS Driver v3.24 ` and it was ID `9C`
* * Run `drvcfg` and take note of the Ctrl ID of your Drv. In my case it was [9A]. The output looks like this:
```
Shell> drvcfg 9C
Configurable Components
  Drv[9C]  Ctrl[9A]  Lang[eng]
```
* * Now run the graphical array tool with the command `drvcfg -s 9C 9A`

Note that I could not get the array config tool to accept my changes when viewing the serial console over a telnet iLO session. I had to use the remote serial console on a Windows XP machine. I'm sure connecting a VGA monitor and keyboard would have worked as well.

The manual I linked also has instructions for changing the mode from RAID to HBA on the controller, but I wanted RAID 1 so I did not need adjust my settings.. 

### Installing HP-UX 11.31 (11i v3)

I used HP-UX 11.31 DC-OE from Tenox's OS Archive:

`os/hpux/OS/11.31/Update 13 (2014-03)/DC-OE_11i_v3_DVD_BA931-10018.rar`  
`os/hpux/OS/11.31/Update 13 (2014-03)/DC-OE_11i_v3_DVD_BA931-10019.rar`  
`os/hpux/OS/11.31/Update 13 (2014-03)/SE_Apps_11i_v3_DVD_BA960-40016.rar`

Note that these are large ISOs and you will need dual layer DVDs to burn them. 

### Installation
The installer will autoboot with the disc in the drive.  
It takes a LONG time to go anywhere after it says `AUTOBOOTING...`  

You can choose the default. I do want to configure the disk partitioning.

I selected some additional software like CDE, Graphics, EnergySaver, HP 9000 containers, and some others.  
I also increase some of the partition sizes, but we can do all of that after install in `sam`

HP-UX installs take a LONG time. I think this install took about 3 hours

## Next Steps
Next I want to setup a modern GCC toolchain, but I have set this project aside for now. I will return at a later date. I'd also like to finally play with Integrity VM.
