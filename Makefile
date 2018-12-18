.PHONY: all clean coverpictures

all: book.pdf cover.pdf

coverpictures: front.png back.png

PAPERSIZE=`cat PAPERSIZE`
COVERSIZE=`cat COVERSIZE`
BASEURL=`cat BASEURL`

generated/%.embed.pdf: static/%.rst
	mkdir -p generated
	pandoc $^ -o $@ -H templates/preamble.tex

generated/%.pdf: generated/%.embed.pdf
	pdfjam --outfile $@ --papersize $(PAPERSIZE) $^

book.pdf: generated/tittelside.pdf generated/kolofon.pdf generated/forord.pdf manuscript.pdf
	pdftk $^ cat output $@

manuscript.pdf: bin/makeBook.pl BASEURL PAPERSIZE
	mkdir -p generated/webdump
	./bin/makeBook.pl generated/webdump $(BASEURL) $(PAPERSIZE)
	pdftk  generated/webdump/*.pdf cat output $@

generated/back.pdf: generated/reverse.main.pdf generated/reverse.tekst.pdf
	pdftk generated/reverse.main.pdf stamp generated/reverse.tekst.pdf output $@

generated/reverse.pdf: generated/back.pdf generated/isbn_barcode.pdf
	pdftk generated/back.pdf stamp generated/isbn_barcode.pdf  output $@

generated/reverse.tekst.pdf:
	gs -o $@ -sDEVICE=pdfwrite -g4411x6660 -c "/Helvetica-Bold findfont 24 scalefont setfont" -c "0 .8 0 0 setcmykcolor" -c "12 12 moveto" -c "(Utgiver EFN) show" -c "showpage"

generated/spine.pdf:
	gs -o $@ -sDEVICE=pdfwrite -g115x6660 -c "<</PageOffset [250 0]>> setpagedevice"

generated/front.embed.svg: assets/front.svg assets/DejaVuMathTeXGyre.ttf
	cd assets; svg-embed-font front.svg
	mv assets/front.embed.svg generated/front.embed.svg

generated/front.embed.pdf: generated/front.embed.svg
	inkscape $^ --export-pdf=$@
	pdfcrop --margin '29 29 29 29' $@ $@

generated/%.pdf: generated/%.svg
	inkscape $^ --export-pdf=$@

generated/reverse.main.embed.pdf: assets/reverse.main.embed.svg
	inkscape $^ --export-pdf=$@

generated/%.pdf: generated/%.embed.pdf
	pdfjam --outfile $@ --papersize $(PAPERSIZE) $^

generated/isbn_barcode.pdf: static/isbn_barcode.pdf
	gs -o $@ -sDEVICE=pdfwrite -g4411x6660 -c "<</PageOffset [250 0]>> setpagedevice" -f static/isbn_barcode.pdf

generated/cover.pdf: generated/reverse.pdf generated/spine.pdf generated/front.pdf
	pdfjam $^ --landscape --nup 3x1 --outfile $@

cover.pdf: generated/cover.pdf
	pdfjam $^ --papersize $(COVERSIZE) --outfile $@

%.png: generated/%.pdf
	convert $^ -resize 1838x2775 $@

.SUFFIXES: .rst .pdf

clean:
	$(RM) generated/webdump/*
	rmdir generated/webdump
	$(RM) manuscript.pdf generated/*

distclean: clean
	$(RM) book.pdf cover.pdf back.png front.png
