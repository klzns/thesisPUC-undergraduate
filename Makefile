##############################################################################
#
# Makefile for LaTeX files
# Original Makefile from http://www.math.psu.edu/elkin/math/497a/Makefile
# First modification by Matti Airas <Matti.Airas@hut.fi>
# Second modification by Thomas Lewiner <lewiner@gmail.com>
# $Id: Makefile,v 1.11 2005/09/27 15:44:33 tlewiner Exp $
#
##############################################################################


######################### Programs ################################

LATEX	    = latex -src-specials -interaction=nonstopmode
BIBTEX	  = bibtex
MAKEINDEX = makeindex
XDVI	    = xdvi -gamma 4
DVIPS	    = dvips
DVIPDF    = dvipdfm
L2H	      = latex2html -split 0
TTH	      = tth #-a -e2
GH	      = gv
XPDF	    = xpdf
RM        = rm -f


########################## Sources ################################

# BEGIN DEPENDENCIES

SRC       := Exple.tex Exple_uk.tex ThesisPUC.tex      
CLASSES   := ThesisPUC.cls ThesisPUC_uk.cls  
STYLES    := atbeginend.sty chngpage.sty fancyhdr.sty indentfirst.sty inputenc.sty setspace.sty subfigure.sty titlesec.sty tocloft.sty   
INPUTS    :=    
BIBFILE   := Exple.bib  
BIBSTYLES := ThesisPUC.bst ThesisPUC_uk.bst
INPUTENCS := noaccent.def
EPSPICS   := ctor4_none.eps puc.ps  

# END DEPENDENCIES


DVI	 = $(SRC:%.tex=%.dvi)
PSF	 = $(SRC:%.tex=%.ps)
PDF	 = $(SRC:%.tex=%.pdf)
HTM  = $(SRC:%.tex=%_htm)
HTML = $(SRC:%.tex=%.html)


####################### Dependencies ##############################


ifeq ($(MAKECMDGOALS),depend)

SRC     := $(shell egrep -l '^[^%]*\\begin\{document\}' *.tex)

CLASSES := $(shell perl -ne '($$_)=/^[^%]*\\documentclass[^{]*\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.cls "}' $(SRC))
CLASSES := $(sort $(foreach class,$(CLASSES), $(shell if [ -f $(class) ] ; then echo $(class) ; else echo class $(class) not in folder >&2 ; fi ;) ) )

STYLES  := $(shell perl -ne '($$_)=/^[^%]*\\usepackage[^{]*\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.sty "}' $(SRC)) $(shell perl -ne '($$_)=/^[^%]*\\RequirePackage[^{]*\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.sty "}' $(CLASSES))
STYLES  := $(sort $(foreach style,$(STYLES), $(shell if [ -f $(style) ] ; then echo $(style) ; else echo style $(style) not in folder >&2 ; fi ;) ) )

BIBFILE := $(shell perl -ne '($$_)=/^[^%]*\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib "}' $(SRC))
BIBFILE := $(sort $(foreach bibfile,$(BIBFILE), $(shell if [ -f $(bibfile) ] ; then echo $(bibfile) ; else echo bibfile $(bibfile) not in folder >&2 ; fi ;) ) )

BIBSTYLES := $(shell perl -ne '($$_)=/^[^%]*\\bibliographystyle[^{]*\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bst "}' $(SRC) $(INPUTS) $(CLASSES) $(STYLES))
BIBSTYLES := $(sort $(foreach bibstyle,$(BIBSTYLES), $(shell if [ -f $(bibstyle) ] ; then echo $(bibstyle) ; else echo bibstyle $(bibstyle) not in folder >&2 ; fi ;) ) )

INPUTS  := $(shell perl -ne '($$_)=/^[^%]*\\input\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.tex "}' $(SRC) $(CLASSES) $(STYLES) $(BIBSTYLES) )
INPUTS  := $(sort $(foreach input,$(INPUTS), $(shell if [ -f $(input) ] ; then echo $(input) ; else echo input file $(input) not in folder >&2 ; fi ;) ) )

INPUTENCS := $(shell perl -ne '($$_)=/^[^%]*\\inputencoding\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.def "}' $(SRC) $(CLASSES) $(STYLES) $(BIBSTYLES) )
INPUTENCS := $(sort $(foreach inputenc,$(INPUTENCS), $(shell if [ -f $(inputenc) ] ; then echo $(inputenc) ; else echo inputenc $(inputenc) not in folder >&2 ; fi ;) ) )

EPSPICS := \
  $(shell perl -ne '($$_)=/^[^%]*\\includegraphics[^{}]*\{([^@\#]*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b "}' $(SRC) $(INPUTS) $(CLASSES) $(STYLES) $(BIBSTYLES) ) \
  $(shell perl -ne '($$_)=/^[^%]*\\[tvsingleubo]+image[{[].*\{([^{}]*?)\}/;@_=split /,/;foreach $$b (@_) {print "figs/$$b "}' $(SRC) $(INPUTS) ) \
  $(shell perl -ne '($$_)=/^[^%]*\\watermark[^{}]*\{([^{}]*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b "}' $(SRC) $(INPUTS) ) \
  $(shell perl -ne '($$_)=/^[^%]*\\logouni[^{}]*\{([^{}]*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b "}' $(SRC) $(INPUTS) )
EPSPICS := $(sort $(foreach fig,$(EPSPICS), $(shell if [ -f $(fig) ] ; then echo $(fig) ; else if [ -f $(fig).eps ] ;  then echo $(fig).eps ; else if [ -f $(fig).ps ] ;  then echo $(fig).ps ; else echo figure $(fig) not in folder >&2 ; fi ; fi ; fi ;) ) )

endif


######################### Messages ################################

RERUN     = "(!|(There were undefined references|Rerun to get (cross-references|the bars) right))"
RERUNBIB  = "No file.*\.bbl|Citation.*undefined"
MAKEIDX   = "^[^%]*\\makeindex"
MPRINT    = "^[^%]*print"
USETHUMBS = "^[^%]*thumbpdf"
OUTDATED  = echo "EPS-file is out-of-date!" && false


########################## Macros #################################

define run-latex
	if test -r $(<:%.tex=%.toc); then cp $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); fi && \
	if test -r $(<:%.tex=%.idx); then cp $(<:%.tex=%.idx) $(<:%.tex=%.idx.bak); fi && \
	$(LATEX) $< > /dev/null ; true
endef


define rerun-latex
	if cmp -s $(<:%.dvi=%.tex) $(<:%.dvi=%.tex.bak) ; \
	  then rm $(<:%.dvi=%.tex.bak) ; \
	  else \
	    touch -r $(<:%.dvi=%.tex) $(<:%.dvi=%.tex.bak) ; \
	    mv $(<:%.dvi=%.tex.bak) $(<:%.dvi=%.tex) ; \
	    $(run-latex) ; \
	    touch -r $(<:%.dvi=%.tex) $< ; \
	fi
endef


define run-complete
	$(run-latex)
	( egrep -q $(MAKEIDX) $< > /dev/null && \
    ! (cmp -s $(<:%.tex=%.idx) $(<:%.tex=%.idx.bak)) ) && ( \
    $(MAKEINDEX) $(<:%.tex=%) 2>&1 | egrep -i "(lines|error)" ; $(run-latex) ) ; true
	( for file in $(BIBFILE) ; do if [ $file -nt $(<:%.tex=%.bbl) ] ; then \
    $(BIBTEX) $(<:%.tex=%) | egrep -i "(Database|error)" ; $(run-latex) ; break ; fi; done ; ) ; true
  ( egrep -q $(RERUNBIB) $(<:%.tex=%.log) > /dev/null && \
    $(BIBTEX) $(<:%.tex=%) | egrep -i "(Database|error)" ; $(run-latex) ) ; true
	egrep -q $(RERUN) $(<:%.tex=%.log) > /dev/null && $(run-latex) ; true
	egrep -q $(RERUN) $(<:%.tex=%.log) > /dev/null && $(run-latex) ; true
	if cmp -s $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak) ; then true ; else $(run-latex) ; fi
	$(RM) $(<:%.tex=%.toc.bak) $(<:%.tex=%.idx.bak)
endef


define show-warnings
	if test -e $(<:%.tex=%.blg) ; then \
    egrep -B1 -A3 -i "line " $(<:%.tex=%.blg) ; \
	  egrep -i "Warning-" $(<:%.tex=%.blg) ; \
  fi ; true
	if test -e $(<:%.tex=%.log) ; then \
    egrep -i "Overful" $(<:%.tex=%.log) ; \
    egrep -i "Warning" $(<:%.tex=%.log) ; \
    egrep -i "(Reference|Citation).*undefined" $(<:%.tex=%.log) ; \
    egrep -A3 -i "^!" $(<:%.tex=%.log) ; \
  fi ; true
endef

define show-stats
	if test -e $(<:%.tex=%.ilg) ; then \
    echo -n "Index  : " ; egrep -i "Generating" $(<:%.tex=%.ilg) ; \
  fi ; true
	if test -e $(<:%.tex=%.blg) ; then \
    echo -n "BibTeX : " ; egrep -i "entries" $(<:%.tex=%.blg) ; \
  fi ; true
	if test -e $(<:%.tex=%.log) ; then \
	  echo -n "LaTeX  : " ; egrep -i "written" $(<:%.tex=%.log) ; \
  fi ; true
	if test -e $(<:%.tex=%.aux) ; then \
    echo -n "         " ; \
    echo -n $(shell egrep -c "contentsline {chapter}" $(<:%.tex=%.aux)) ; echo -n " chapters, " ; \
    echo -n $(shell egrep -c "contentsline {section}" $(<:%.tex=%.aux)) ; echo -n " sections and, " ; \
    echo -n $(shell egrep -c "contentsline {subsection}" $(<:%.tex=%.aux)) ; echo " subsections." ; \
  fi ; true
endef


####################### File Targets ##############################

dvi	 : $(DVI)

ps	 : $(PSF) 

pdf	 : $(PDF) 

htm	 : $(HTM)

html : $(HTML)

DIRNAME = $(notdir ${PWD})
TARNAME = ../$(shell echo $(DIRNAME) | tr [:upper:] [:lower:]).tgz
tar  : $(TARNAME)


###################### default targets ############################

all 	  :
	make depend
	@for i in $(DVI) ; do if egrep -q -i $(RERUN) $${i/.dvi/.log} ; then $(RM) $$i ; fi ; done ; true
	make dvi

everything :
	make depend
	@for i in $(DVI) ; do if egrep -q -i $(RERUN) $${i/.dvi/.log} ; then $(RM) $$i ; fi ; done ; true
	make dvi
	@for i in $(PSF) $(PDF) $(HTML) $(HTM) ; do if test -r $$i ; then make $$i ; fi ; done ; true
	make tar
	make cvs

.PHONY	: all everything depend warns stats show-depend clean dvi ps pdf htm html show showps showpdf tar cvs


##################### Programs Targets ############################

show	: $(DVI)
	@for i in $(DVI) ; do $(XDVI) $$i ; done

showps	: $(PSF)
	@for i in $(PSF) ; do $(GH) $$i ; done

showpdf	: $(PDF)
	@for i in $(PDF) ; do $(XPDF) $$i ; done

clean	:
	$(RM) .\#* *~ $(DVI) $(PSF) $(PDF) $(HTM) $(HTML) \
  $(DVI:%.dvi=%.aux) $(DVI:%.dvi=%.log) $(DVI:%.dvi=%.out) \
  $(DVI:%.dvi=%.bbl) $(DVI:%.dvi=%.blg) $(DVI:%.dvi=%.brf) \
  $(DVI:%.dvi=%.lof) $(DVI:%.dvi=%.lot) $(DVI:%.dvi=%.toc) \
  $(DVI:%.dvi=%.idx) $(DVI:%.dvi=%.ilg) $(DVI:%.dvi=%.ind)

cvs :
	cvs ci -m "backup $(shell date -u '+%A, %d %b %Y, %H:%M')"


####################### Info Targets ##############################

warns	: $(SRC)
	  @$(show-warnings)

stats	: $(SRC)
	  @$(show-stats)

show-depend :
	  @echo "# sources   : " $(SRC)
	  @echo "# classes   : " $(CLASSES)
	  @echo "# styles    : " $(STYLES)
	  @echo "# inputs    : " $(INPUTS)
	  @echo "# biblios   : " $(BIBFILE)
	  @echo "# bibstyles : " $(BIBSTYLES)
	  @echo "# encodings : " $(INPUTENCS)
	  @echo "# images    : " $(EPSPICS)

depend :
	  @rm -f Makefile.bak*
	  @csplit Makefile -s -f Makefile.bak "/^\# BEGIN DEPENDENCIES/2" "/^\# END DEPENDENCIES/-1"
	  @rm -f Makefile.bak01
	  @echo > Makefile.bak01
	  @echo "SRC       := $(SRC)      "  > Makefile.bak01
	  @echo "CLASSES   := $(CLASSES)  " >> Makefile.bak01
	  @echo "STYLES    := $(STYLES)   " >> Makefile.bak01
	  @echo "INPUTS    := $(INPUTS)   " >> Makefile.bak01
	  @echo "BIBFILE   := $(BIBFILE)  " >> Makefile.bak01
	  @echo "BIBSTYLES := $(BIBSTYLES)" >> Makefile.bak01
	  @echo "INPUTENCS := $(INPUTENCS)" >> Makefile.bak01
	  @echo "EPSPICS   := $(EPSPICS)  " >> Makefile.bak01
	  @cat Makefile.bak00 Makefile.bak01 Makefile.bak02 > Makefile.bak
	  @rm -f Makefile.bak0*
	  @mv Makefile.bak Makefile
	  @make show-depend


###################### File generation ############################

$(DVI)	: %.dvi : %.tex $(INPUTS) $(DEP) $(BIBFILE) $(INPUTENCS) $(EPSPICS) $(CLASSES) $(STYLES) $(BIBSTYLES)
	@$(run-complete)
	@$(show-warnings)
	@echo ; true
	@$(show-stats)

$(PSF)	: %.ps : %.dvi
	@sed -e "s/[[]dvipdfm[]]/[dvips]/g" $(<:%.dvi=%.tex) > $(<:%.dvi=%.tex.bak)
	@$(rerun-latex)
	@$(DVIPS) $< -o $@

$(PDF)  : %.pdf : %.dvi
	@sed -e "s/[[]dvips[]]/[dvipdfm]/g" $(<:%.dvi=%.tex) > $(<:%.dvi=%.tex.bak)
	@$(rerun-latex)
	@$(DVIPDF) -o $@ $<

$(HTML)	:	%.html : %.tex $(DEP)
	@$(TTH) $<

$(HTM)	:	%_htm : %.tex $(DEP) $(BIBFILE)
	mkdir -p $@
	@$(L2H) -dir $@ $(SRC)
	touch -r $< $@

$(TARNAME) : $(SRC) $(DVI:%.dvi=%.bbl) $(DVI:%.dvi=%.pdf) $(CLASSES) $(STYLES) $(INPUTS) $(BIBFILE) $(BIBSTYLES) $(INPUTENCS) $(EPSPICS) Makefile figs/*.[^e][^p][^s]
	tar -C.. -c -v -z --exclude=CVS -f $@ $(foreach file,$^,$(DIRNAME)/$(file)) > /dev/null

