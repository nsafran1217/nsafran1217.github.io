# SGI Altix 350
*Last Updated: 13-Mar-2026*

I purchased this Altix 3700 and an [Altix 3700](/computers/sgi/altix3700.html) from a recycler, just before they were scrapped.  
While I was able to save the NUMAlink cables and the systems themselves, the racks were unfortunately already gone.
Along with them, there was a UV1000 and an Altix 4700, but their racks and blade chassis had also been scrapped. Only the blades remained.  
The L2 controllers were gone as well.

My Altix 3700 (and Altix 350) came from Duquesne University in Pittsburgh, Pennsylvania. They were used for research in the Chemistry department.  
I'd estimate the original purchase price for the 350 was around $100,000.  
I found two articles that were published when the computers were purchased:

* [HPC Wire](https://www.hpcwire.com/2004/07/16/duquesne-u-selects-sgi-for-state-of-the-art-research)
* [Duequese University News](https://digital.library.duq.edu/digital/api/collection/utimes/id/1161/download)

My Altix 350 system consists of 8 compute bricks and 1 N4LR router. When I purchased the lot, I got 16 bricks, but some had small issues like failed power supplies or failed memory. 
I have no need for a full 16 brick system, so I sold some bricks for parts and plan to keep 8. 

Currently the N4LR router is broken with a bad power supply. I will document the process of replacing it when I get around to it.

The Altix 350 is much more usable than the Altix 3000 series since each brick takes standard AC power in and the Base IO is in one of the compute bricks.  
This is the primary system I use when working on getting SN2 support back into the linux kernel.

### Goals

My primary goals with system are:  
1. Add support for SN2 back into the Linux kernel ([mostly done](/blog/008-sn2-linux.html))  
2. Create an easy to install iso of [T2-SDE Linux](https://t2linux.com/)  
3. Get the `radeon` driver working with a PCI (or maybe even PCI-E) graphics card  
4. Play Minecraft on a $300,000 supercomputer from 2004  
5. Maybe try to get the ATI FireGL cards working on Prism (if someone gives me access to theirs)  

PCI Graphics cards were never supported on Altix. Some people in the SGUG discord have gotten un-accelerated 2D to work with old ATI cards, but no one has gotten the radeon driver to load.  
If you wanted video output on an Altix, you had to buy a Prism brick, which had an AGP ATI FireGL Pro and a custom, closed source Linux driver to run it. I believe these cards are only supported on Redhat 5 or SLES 9 with the SGI ProPack installed.


## Pictures

<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/350-front.jpg"><img src="/img/sgi/350-front.jpg" alt="3700"></img></a>
                </div>
                Current Setup
            </td>
            <td>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/altix350.jpg"><img src="/img/sgi/altix350.jpg" alt="350 "></img></a>
                </div>
                All the equipment I got
            </td>
        </tr>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/350-node-bottom.jpg"><img src="/img/sgi/350-node-bottom.jpg" alt="3700"></img></a>
                </div>
                Bottom of CPU node board
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/350-node-nocpu.jpg"><img src="/img/sgi/350-node-nocpu.jpg" alt="3700 rear"></img></a>
                </div>
                CPU Node board without CPUs
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/350-nonode.jpg"><img src="/img/sgi/350-nonode.jpg" alt="350 "></img></a>
                </div>
                Case without node board
            </td>
        </tr>
    </tbody>
</table>

