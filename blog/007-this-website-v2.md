# This Website's Design Version 2
*Published: 15-Mar-2026 - Last Updated: 15-Mar-2026*

I have redesigned the build process for this website. With the new build system, I can now write all website content in markdown files. These markdown files are then converted to xml files, which are still processed with `xsltproc`.  
Writing in markdown is much easier than writing HTML, so maybe this will encourage me to make more pages and keep everything up to date.

Then to build the site, all i have to do it run `make`. Only the changed files are rebuilt, and I don't have to manually copy the output to the website repo.

This setup was inspired by [Nuclear's Blog](http://nuclear.mutantstargoat.com/blog/)

I still need to go through and convert the projects pages to markdown, but the Makefile has support for processing xml files as well. I will probably remove that line from the Makefile 
once I convert those pages.

Adding additional sections will be as easy as making a new folder and adding it to the source file list in the Makefile.  
The navigation menu is still manually defined in nav.xml, but maybe in the future that can be automated as well.

Any additional changes to the build system will be made to the github.io repository here: [https://github.com/nsafran1217/nsafran1217.github.io](https://github.com/nsafran1217/nsafran1217.github.io)  
More details are listed on the repo's README.md


[Original Design Description](000-this-website.html)
