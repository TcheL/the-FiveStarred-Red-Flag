file := note

all : full view

cc : clean clear

full :
	latexmk -pdfxe -synctex=1 -interaction=nonstopmode $(file)

view :
	evince $(file).pdf &

backup : $(file).tex $(file).pdf
	tar -zpcv -f Backup.tar.gz $(file).tex $(file).pdf

clean :
	-rm -f $(addprefix $(file), .aux .blg .bbl .fdb_latexmk .fls .idx .ind \
    .ilg .log .synctex.gz .tex.bak .toc .out .xdv)

clear :
	-rm -f $(file).pdf

# vim:ft=make:noet
