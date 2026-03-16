# SGI Altix 3700
*Last Updated: 13-Mar-2026*

I purchased this Altix 3700 and an [Altix 350](/computers/sgi/altix350.html) from a recycler, just before they were scrapped.  
While I was able to save the NUMAlink cables and the systems themselves, the racks were unfortunately already gone.
Along with them, there was a UV1000 and an Altix 4700, but their racks and blade chassis had also been scrapped. Only the blades remained.  
The L2 controllers were gone as well.

My Altix 3700 (and ALtix 350) came from Duquesne University in Pittsburgh, Pennsylvania. They were used for research in the Chemistry department.  
I'd estimate the original purchase price for the 3700 was around $300,000.  
I found two articles that were published when the computers were purchased:

* [HPC Wire](https://www.hpcwire.com/2004/07/16/duquesne-u-selects-sgi-for-state-of-the-art-research)
* [Duequese University News](https://digital.library.duq.edu/digital/api/collection/utimes/id/1161/download)

The Altix 3000 was SGI's first Itanium based supercomputer. Its design is similar to the Origin 3000, which used MIPS processors and ran IRIX.

My Altix 3700 has 8 C-Bricks, 4 R-Bricks, and 1 iX-Brick.

Each C-Brick has 4x 1.3 Ghz Intel Itanium2 Madison processors and 4GB of RAM. Internally, each C-brick is 2 nodes connected through an internal router.  
Each Altix 3000 system requires at least 1 iX-brick which provides the base IO for the system using the IO9 card, and provides additional PCI-X slots.

Currently, 2 of my R-bricks are broken, so I'm running in a less than ideal state, however, NUMAlink is robust enough that it still works after moving some cables around.

<img align="right" src="/img/sgi/3700-pwr.png"></img>
In this state, it draws ~4.2 KW of power! It heats up the basement pretty quick!

### Goals

My goals for the Altix are listed on the [Altix 350 page](/computers/sgi/altix350.html)


<br></br>

---

Honestly, the Altix 3700 is a beast of burden. If anyone has interest in taking it off my hands, please get in touch with me.


## Pictures

<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/3700-front.jpg"><img src="/img/sgi/3700-front.jpg" alt="3700"></img></a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/altix3700-rear.jpg"><img src="/img/sgi/altix3700-rear.jpg" alt="3700 rear"></img></a>
                    Lots of NUMAlink cables...
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/altix3700.jpg"><img src="/img/sgi/altix3700.jpg" alt="350 "></img></a>
                    I need a 42U rack to fit it all, but the Sun racks worked out for mounting without the original rails
                </div>
            </td>
        </tr>
    </tbody>
</table>
