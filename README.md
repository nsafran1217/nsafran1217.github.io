# CDE Themed website

This project has been greatly simplified. All pages are written as either a .md file or a .xml file.

Currently, `projects` are still .xml files, but the Makefile handles both cases cleanly.

## Usage
Run `make`

## Formatting Details
All .md pages must begin with an H1 header (one #), and on the next line, a published date, e.g. `*Published: 22-May-2025 - Last Updated: 22-May-2025*`

Any H2 headings (two ##) will insert a "window break". The H2 heading will be the title of the new window.

Tables should be in HTML formatting, not markdown.

## Dependencies
* [markdown](https://daringfireball.net/projects/markdown/syntax) (`apt install markdown`)
* xsltproc (`apt install xsltproc`)

## Implementation Details
The Makefile uses 4 scripts to create the site.  
`gen-page.sh` - Take a .md filename as an argument. Selects the correct theme, converts to HTML, adds the header `src/templates/header.x` and the footer `src/templates/footer.x`. H2 headings are replaced a bottom of window, then a top of window. The heading is the window title.
The theme, window titles are set. The generated xml file is then processed with `xsltproc` and the xml file is deleted.

`gen-blog-index.sh` - Create the blog/index.html file. Uses src/templates/blog_index_head.x, then maually constructs a table. Runs `xsltproc` at the end

`gen-home-page.sh` - Generates a "blog spotlight" of the last 7 blog entries. Then runs gen-page.sh on index_stage.md and deletes the temporary file.

`gen-sitemap.sh` - Creates sitemap.xml based on file mod time.

`articles.xslt` - All markdown files are first converted to xml, then processes with `xstlproc` and the template `articles.xslt`. The template selects the correct css theme and adds `nav.xml` to the resultant html files. This file controls the look of all pages.

`nav.xml` -  This is the navigation sidebar on each page. Edit this file directly to change the navigation


## TODO:  
- Convert `projects` to md and remove xml build from makefile
- add google search bar on page somewhere, somehow
- finish blog articles

## Future Enhancements 
- Generate nav.xml at build time