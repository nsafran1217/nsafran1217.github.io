# SPARCStation IPX
*Last Updated: 02-May-2025*

I really enjoy the lunchbox form factor of the IPX. I purchased this SPARCStation IPX on
ebay as untested, but it did say it powered on. My system came with a dummy load
installed where the hard disk would be, so I'm assuming it never had a hard disk and net
booted Sun OS when it was in service.

I installed a 2.1 GB Hard disk and purchased a SCSI cable for it. Of course, the NVRAM
battery was dead. I repaired it by bypassing the internal battery and installing an
external battery holder as described on this page. 

<a href="http://www.tns-soft.com/nvram_redux.html" target="_blank"
        rel="noopener noreferrer">Sun NVRAM Repair</a>

The system currently has 40MB of RAM and is running SunOS 4.1.4, the last release of the
BSD based operating system by Sun. The GUI on SunOS is pretty simplistic compared to the
later versions of Solaris, but it works. I compiled some modern tools for it including
bash, tar, gzip, and others. Its definitely the slowest workstation I have, but I enjoy
messing around with it.

<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/ipxanddisk.jpg">
                        <img src="/img/sun/ipxanddisk.jpg" alt="IPX with disk"></img>
                    </a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/ipx-bat.jpg">
                        <img src="/img/sun/ipx-bat.jpg" alt="Battery Mod"></img>
                    </a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/sunos4.jpg">
                        <img src="/img/sun/sunos4.jpg" alt="Sun OS 4.1.4"></img>
                    </a>
                </div>
            </td>
        </tr>
    </tbody>
</table>

## External Hard Disk

I really like the form factor, so I purchased an external hard disk on eBay to go with
it. This disk was sold as *not working, does not power up*. When it arrived, I opened up
the PSU and saw what I expected—leaking capacitors. I ordered replacements on DigiKey
for the four large capacitors and replaced them. Luckily, that was the only issue with
the power supply. 
    
<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/ipx-psu1.jpg">
                        <img src="/img/sun/ipx-psu1.jpg" alt="PSU Damage"></img>
                    </a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/ipx-psu2.jpg">
                        <img src="/img/sun/ipx-psu2.jpg" alt="PSU Repaired"></img>
                    </a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sun/fullheigh-disk.jpg">
                        <img src="/img/sun/fullheigh-disk.jpg" alt="Big disk VS SSD"></img>
                    </a>
                </div>
            </td>
        </tr>
    </tbody>
</table>
