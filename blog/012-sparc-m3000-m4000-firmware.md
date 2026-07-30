# Upgrading firmware and clearing faults on M3000/M4000
*Published: 29-Jul-2026 - Last Updated: 29-Jul-2026*

Old firmware version (At least older than XCP 1116) do not allow the customer to reset certain faulted FRUs in the SPARC Enterprise systems. Certain bugs in the serial code could cause the CPU to be faulted, basically bricking the system.
Older version of OpenBSD would trigger this fault, but it appears to have since been fixed. OpenBSD 7.6 works fine on my M3000.

They fix this on the M3000 by only using the firmware console rather than attaching the sun su driver.

This is how to update the firmware to a new enough version which allows you to clear the fault without Oracle, 
and how to clear the fault if you run into it.

[And if your XSCF is bricked, click here](011-sparc-m4000-xscf-rescue.html)

### Updating firmware

Retrieve the firmware files:

[M4000/M5000 XSCF Firmware](https://archive.org/details/sun-xscf-firmware-ffxcp1124)

[M3000 XSCF Firmware](https://archive.org/details/ikxcp-1124.tar)

The file name is FFXCP1124 for the M4000/M5000 and IKXCP1124 for the M3000. **Its very important to use the correct file.**

I used an FTP server that supported anonymous login.

    getflashimage -v ftp://FTP_IP/path_to_file/IKXCP1124.tar.gz 

Press y to delete the existing copy.

Then after its downloaded, run the upgrade:

    flashupdate -c update -m xcp -s 1124


References:  
[https://docs.oracle.com/cd/E19580-01/821-2797-10/21ch8p.html#50450510_57010](https://docs.oracle.com/cd/E19580-01/821-2797-10/21ch8p.html#50450510_57010)  
[https://mysolarisnotes.blogspot.com/2016/02/firmware-upgrade-procedure-for-m-series.html](https://mysolarisnotes.blogspot.com/2016/02/firmware-upgrade-procedure-for-m-series.html)

## Clearing the Fault
TL;DR:  `clearfault -v /MBU_A`

When the system is faulted, you are no able to start the domain:


    XSCF> poweron -d 0
    DomainIDs to power on:00
    Continue? [y|n] :y
    00 :Not powering on :Poweron canceled due to missing component.

And the MBU_A is Faulted:

    XSCF> showstatus
    *   MBU_A Status:Faulted;
    *       CPU Status:Deconfigured;
    *       MEM#0A Status:Deconfigured;
    *       MEM#1A Status:Deconfigured;
    *       MEM#2A Status:Deconfigured;
    *       MEM#3A Status:Deconfigured;


This is what clearing the fault looks like:

    XSCF> clearfault -v /MBU_A
    This command must only be used at the request of a product support engineer.
    Continue? [y|n]: y
    clearfault: Fault cannot be cleared for this FRU.
    FRU will be marked to clear fault on next circuit breaker off and on.
    Continue? [y|n]: y
    Fault will be cleared after circuit breaker off and on
    XSCF>

Then remove power from the system and plug it back in.