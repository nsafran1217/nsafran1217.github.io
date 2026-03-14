# This Website's Design
*Published: 22-May-2025 - Last Updated: 22-May-2025*

When I originally made a website, I used Publii, which is a WSYIWYG static site generator. Publii worked fine, but I wanted a bit more control over the layout and organization of the site.

I had a few goals for the site: Make it static so I can host it on GitHub Pages, no Javascript so older browsers can at least load the site, and for it to be somewhat easy to update with new content.
<a href="https://github.com/nsafran1217/cde-website">GitHub for the website "source"</a>

### Inspiration
[cosam.org](http://www.cosam.org/) was my inspiration for the layout of the site, with a sidebar that changed depending on the page.  
[4dwm.com](https://www.4dwm.com/) inspired me to make the site look like a CDE/HP VUE/4DWM desktop. 

Making this website ended up being a lot of work since I have no experience with web design, except for one class I took in 10th grade making websites in Adobe Dreamweaver CS3 (which was very outdated by then).
Originally, it was going to look much closer to cosam.org with a simpler theme. I was planning on using [https://simplecss.org/](https://simplecss.org/) for the styling, but I got inspired when I saw 4dwm.com.

### Details
The first draft of the site was all HTML with a small amount of Javascript to load the navbar on each page, but that didn't meet my goal for no JS. I then came across [xslt](https://www.w3schools.com/xml/xsl_intro.asp), which allows you to use a template file to convert an XML file into an HTML file.

With some help from ChatGPT, I started tweaking the template to insert the navbar template on each site. The xslt template also let me generate multiple "Windows" on the site relatively easily. 

XSLT templates are in `/src/templates`. All the XML and MD files are in `/src/content`. 

`make-website.sh` calls `gen-blog.sh`, which converts the markdown into xml, then creates the `index.html` page for the blog list. 

`gen-articles.py` converts all the xml files into html with xsltproc. ChatGPT made this script and is over complicated. One day I'll replace it with a shell script.

`gen-index.py` is currently a mess. The goal was to get an excerpt from each blog entry to have on the home page. It kind of works, but is very complicated. Also written by ChatGPT.

I need to come back to this and try to integrate it into the main github pages repo. Currently, I manually copy the contents of OUTPUT into the github pages repo to update the site.

### Conclusion
I'm happy with how the website looks on modern browsers, but old browsers struggle a lot with most of the css formatting used to make the "windows". I'm not sure if there's a solution to that, but at least the text loads on old browsers.
