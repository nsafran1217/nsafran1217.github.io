# Sun Microsystems
*Last Updated: 28-May-2025*

<img src="/img/sun/sun.png" height="120px" class="fullwidth"></img>

Sun Microsystems was my first exposure to Unix workstations. Back in 2017, I posted a
wanted ad on craigslist and somebody actually responded! I went to their damp basement
and picked up 4 rusty workstations, 4 keyboards, and 3 mice, and 1 monitor for $100. 2
keyboards and 1 mouse were not salvageable.

Unfortunately, the monitor was broken. At that time, CRTs were still being given away for
free, so I just got rid of it. Today, I would attempt to fix it.

I'm still looking for a pre-SPARC Sun system, and maybe an Ultra 2 with dual processors.
I find the S-BUS systems more interesting than the later PCI systems.

## Featured Systems:

<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/computers/sun/ipx.html">
                        <img src="/img/sun/ipx.jpg"  alt="IPX"></img>
                    </a>
                    <a href="/computers/sun/ipx.html">SPARCStation IPX</a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/computers/sun/ultra1.html">
                        <img src="/img/sun/ultra1s.jpg" alt="Ultra 1"></img>
                    </a>
                    <a href="/computers/sun/ultra1.html">Ultra 1</a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/computers/sun/sparc5.html">
                        <img src="/img/sun/sparc5.jpg" alt="SPARCStation 5"></img>
                    </a>
                    <a href="/computers/sun/sparc5.html">SPARCStation 5</a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/computers/sun/ultra10.html">
                        <img src="/img/sun/ultra10-logo.jpg" alt="Ultra 10"></img>
                    </a>
                    <a href="/computers/sun/ultra10.html">Ultra 10</a>
                </div>
            </td>
        </tr>
    </tbody>
</table>

### All Systems
Will update eventually with all specs

<table class="specs">
    <tbody>
        <tr>
            <th>Model</th>
            <th>Processor</th>
            <th>RAM</th>
            <th>Graphics</th>
            <th>Disk</th>
            <th>OS</th>
            <th>Notes</th>
        </tr>
        <tr>
            <td>SPARCStation IPX</td>
            <td>SPARC 40 MHz</td>
            <td>40 MB</td>
            <td>CG6</td>
            <td>2.1 GB</td>
            <td>SunOS 4.1.4</td>
            <td>Case in rough shape</td>
        </tr>
        <tr>
            <td>SPARCStation 10</td>
            <td>SuperSPARC 40 MHz</td>
            <td>48 MB</td>
            <td>CG6</td>
            <td>2.1 GB</td>
            <td>SunOS 4.?</td>
            <td></td>
        </tr>
        <tr>
            <td>SPARCStation 5</td>
            <td>MicroSPARC-II 85 MHz</td>
            <td>32 MB</td>
            <td>Internal CG6</td>
            <td>4.2 GB</td>
            <td>Solaris 2.6</td>
            <td></td>
        </tr>
        <tr>
            <td>Ultra 1</td>
            <td>UltraSPARC 143 MHz</td>
            <td>256 MB</td>
            <td>??</td>
            <td>2x 36 GB 15k</td>
            <td>Solaris 8/OpenBSD 6.9</td>
            <td></td>
        </tr>
        <tr>
            <td>Ultra 1</td>
            <td>UltraSPARC 167 MHz</td>
            <td>192 MB</td>
            <td>??</td>
            <td>36 GB 15k</td>
            <td>Solaris 8</td>
            <td></td>
        </tr>
        <tr>
            <td>Ultra 10</td>
            <td>UltraSPARC IIi 333 MHz</td>
            <td>256 MB</td>
            <td>Creator 3D</td>
            <td>80 GB IDE</td>
            <td>Solaris 8</td>
            <td>SunPCI</td>
        </tr>
        <tr>
            <td>SunBlade 150</td>
            <td>UltraSPARC IIe 650 MHz</td>
            <td>256 MB</td>
            <td>PGX64</td>
            <td>2x 80 GB IDE</td>
            <td>Solaris 9/NetBSD 10</td>
            <td></td>
        </tr>
        <tr>
            <td>SunFire v100</td>
            <td>UltraSPARC IIe 650 MHz</td>
            <td>512 MB</td>
            <td>None</td>
            <td>80 GB IDE</td>
            <td>Solaris 10</td>
            <td></td>
        </tr>
        <tr>
            <td>SunFire v240</td>
            <td>2x UltraSPARC IIIi 1.5 GHz</td>
            <td>4 GB</td>
            <td>None</td>
            <td>2x 73 GB SCSI</td>
            <td>Solaris 10</td>
            <td></td>
        </tr>
    </tbody>
</table>


## Info and Links

<p>
    <a href="http://ftp.lanet.lv/ftp/sun-info/sun-patches/" target="_blank"
        rel="noopener noreferrer">Sun Patches</a>
    <br></br>
    <a href="http://download.nust.na/pub3/solaris/sparc/" target="_blank"
        rel="noopener noreferrer">Sun Packages</a>
    <br></br>
    <a href="http://www.lib.ru/TXT/faqsunnvram.txt" target="_blank"
        rel="noopener noreferrer">NVRAM FAQ</a>
    <br></br>
    <a href="http://ftp.icm.edu.pl/packages/sun-patches/all_signed/" target="_blank"
        rel="noopener noreferrer">More Sun Patches</a>
    <br></br>
    <a href="https://www.ibiblio.org/pub/packages/solaris/sparc/" target="_blank"
        rel="noopener noreferrer">More Solaris Packages</a>
    <br></br>
    <a href="http://vtda.org/bits/software/Sun/SunPCI/" target="_blank"
        rel="noopener noreferrer">SunPCI Packages</a>
</p>
### Enabling NFSv2 on Ubuntu 22.04

I had issues mounting an NFS export on a Ubuntu 22.04 server on some older OSes like
HP-UX and Tru64. I had to enable NFSv2 to allow these systems to mount the NFS export.

In `/etc/default/nfs-kernel-server`  
, change `RPCNFSDOPTS`  
to include version 2, like this:  

`RPCNFSDOPTS="--nfs-version 2,3,4 --debug --syslog"`


Then, in `/etc/nfs.conf`  
, in `[nfsd]`  
, add `vers2=y`


Then restart nfs:  
`sudo systemctl restart nfs-kernel-server`


I have my directory exported like this:


`/nfs 10.35.0.0/24(rw,no_root_squash,insecure)`

