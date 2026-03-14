# Adding support for SGI Altix back into modern Linux kernels
*Published: 8-Mar-2026 - Last Updated: 8-Mar-2026*

Support for the SGI Altix SN2 Itanium based computers was removed for Linux 5.4. Linux did not boot on Altix since about v4.0, and SN2 support had been abandonded for a few years at that point since SGI went bankrupt and sold to Rackable and Itanium turned out to be a flop. The infrastructure to support different machine types in IA64 was also greatly simplified, which makes adding SN2 back a little more complicated than just reverseing the commit.

## The plan
I am not knowledable enough or skilled enough to do this, so I will be using Claude to add SN2 back into the kernel. 