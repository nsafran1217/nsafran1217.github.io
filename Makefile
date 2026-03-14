TEMPLATES = src/templates/header.x src/templates/footer.x src/templates/article.xslt src/templates/blog_index_head.x

# Get all md and xml files, with some exclusions
src_md = $(shell find . -mindepth 2 -name '*.md' -not -path './src/*' )
src_xml = $(shell find . -name '*.xml' -not -path './src/*' -not -path './sitemap.xml' -not -path './blog/index.xml')

posts   = index.html $(src_md:.md=.html) $(src_xml:.xml=.html)

all: $(posts) sitemap.xml


# Generate all pages stored as .md
%.html: %.md $(TEMPLATES)
	./src/gen-page.sh $<

# Generate all pages stored as .xml
%.html: %.xml $(TEMPLATES)
	xsltproc -o $@ src/templates/article.xslt $<

# Generate blog index page
blog/index.html: $(wildcard blog/*.md) $(TEMPLATES)
	./src/gen-blog-index.sh

# Generate home page
index.html: index.md $(wildcard blog/*.md) $(TEMPLATES)
	./src/gen-home-page.sh


# make sitemap
sitemap.xml: $(posts)
	./src/gen-sitemap.sh