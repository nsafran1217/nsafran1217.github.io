# Octane
*Last Updated: 02-May-2025*

The Octane was SGI's successor to the Indigo2, offering impressive graphics capabilities
and a modular design. It supports dual CPUs and various expansion cards through its
proprietary XIO bus. At the core of its architecture is the Crossbar switch, enabling
high-speed communication between the CPU and expansion cards. The system board and XIO
cards connect to a front plane via delicate compression connectors with gold fingers
that press against the PCB—these are extremely fragile and should never be touched, as
even slight contact can cause damage.

I have two Octanes, though only one is fully functional. Both are later models featuring
the updated SGI logo and "Cherokee" power supplies. My working Octane has a system board
with dual 300 MHz R12000 CPUs, 2GB of RAM, and ESI/SE graphics. It runs IRIX 6.5.30 on
an 18GB hard disk.

The non-working system has a single 300 MHz R12000 CPU, 1GB of RAM, and EMXI/MXE
graphics. Its issue appears to be with the graphics board, as it triggers a kernel panic
as soon as X tries to initialize. I attempted running it without the TRAMs (which
effectively downgrades it to an SSE), but that didn't help. I even swapped the
compression connector from an Octane Personal Video card, since the one on the MXE board
looked slightly dirty, but that also made no difference.

The performance leap from my Indigo2 to the Octane is substantial. The Octane compiles
software much faster and feels significantly more responsive in use.
                
## Pictures

<table class="image-showcase">
    <tbody>
        <tr>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/octane.jpg"><img src="/img/sgi/octane.jpg" alt="Octane"></img></a>
                </div>
            </td>
            <td>
                <div class="image-showcase">
                    <a href="/img/sgi/octane-hinv.jpg"><img src="/img/sgi/octane-hinv.jpg" alt="hinv"></img></a>
                </div>
            </td>
        </tr>
    </tbody>
</table>
