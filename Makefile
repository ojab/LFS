BASEDIR=~/lfs-editors-guide
CHUNK_QUIET=1
PDF_OUTPUT=LFS-EDITORS-GUIDE.pdf
NOCHUNKS_OUTPUT=LFS-EDITORS-GUIDE.html
LFSTRUNK=../BOOK
LFSXSL=$(LFSTRUNK)/stylesheets

lfs:
	xsltproc --xinclude --nonet -stringparam chunk.quietly $(CHUNK_QUIET) \
	-stringparam base.dir $(BASEDIR)/ $(LFSXSL)/lfs-chunked.xsl index.xml

	if [ ! -e $(BASEDIR)/stylesheets ]; then \
	  mkdir -p $(BASEDIR)/stylesheets; \
	fi;
	cp ../BOOK/$(LFSXSL)/lfs-xsl/*.css $(BASEDIR)/stylesheets

	if [ ! -e $(BASEDIR)/images ]; then \
	  mkdir -p $(BASEDIR)/images; \
	fi;
	cp $(LFSTRUNK)/images/*.png \
	  $(BASEDIR)/images
	cd $(BASEDIR)/; sed -i -e "s@../stylesheets@stylesheets@g" \
	  *.html
	cd $(BASEDIR)/; sed -i -e "s@../images@images@g" \
	  *.html

	for filename in `find $(BASEDIR) -name "*.html"`; do \
	  tidy -config tidy.conf $$filename; \
	  true; \
	done;

	for filename in `find $(BASEDIR) -name "*.html"`; do \
	  sed -i -e "s@text/html@application/xhtml+xml@g" $$filename; \
	done;

pdf:
	xsltproc --xinclude --nonet --output $(BASEDIR)/lfs-pdf.fo \
		$(LFSXSL)/lfs-pdf.xsl index.xml
	sed -i -e "s/inherit/all/" $(BASEDIR)/lfs-pdf.fo
	fop $(BASEDIR)/lfs-pdf.fo $(BASEDIR)/$(PDF_OUTPUT)
	rm $(BASEDIR)/lfs-pdf.fo

nochunks:
	xsltproc --xinclude --nonet -stringparam profile.condition html \
	--output $(BASEDIR)/$(NOCHUNKS_OUTPUT) \
	  $(LFSXSL)/lfs-nochunks.xsl index.xml

	tidy -config tidy.conf $(BASEDIR)/$(NOCHUNKS_OUTPUT) || true

	sed -i -e "s@text/html@application/xhtml+xml@g"  \
	  $(BASEDIR)/$(NOCHUNKS_OUTPUT)

validate:
	xmllint --noout --nonet --xinclude --postvalid index.xml
