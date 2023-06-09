DOCSET_NAME = GNU_Make

DOCSET_DIR    = $(DOCSET_NAME).docset
CONTENTS_DIR  = $(DOCSET_DIR)/Contents
RESOURCES_DIR = $(CONTENTS_DIR)/Resources
DOCUMENTS_DIR = $(RESOURCES_DIR)/Documents

INFO_PLIST_FILE = $(CONTENTS_DIR)/Info.plist
INDEX_FILE      = $(RESOURCES_DIR)/docSet.dsidx
ICON_FILE       = $(DOCSET_DIR)/icon.png
ARCHIVE_FILE    = $(DOCSET_NAME).tgz

SRC_ICON = src/icon.png

MANUAL_URL  = http://www.gnu.org/software/make/manual/make.html_node.tar.gz
MANUAL_FILE = tmp/make.html_node.tar.gz

ERROR_DOCSET_NAME = $(error DOCSET_NAME is unset)
WARNING_MANUAL_URL = $(warning MANUAL_URL is unset)
ERROR_MANUAL_FILE = $(error MANUAL_FILE is unset)
.phony: err warn

ifndef DOCSET_NAME
err: ; $(ERROR_DOCSET_NAME)
endif

ifndef MANUAL_FILE
err: ; $(ERROR_MANUAL_FILE)
endif

ifndef MANUAL_URL
warn: 
	$(WARNING_MANUAL_URL)
	$(MAKE) all
endif

DOCSET = $(INFO_PLIST_FILE) $(INDEX_FILE)
ifdef SRC_ICON
DOCSET += $(ICON_FILE)
endif

all: $(DOCSET)

archive: $(ARCHIVE_FILE)

clean:
	rm -rf $(DOCSET_DIR) $(ARCHIVE_FILE)

tmp:
	mkdir -p $@

$(ARCHIVE_FILE): $(DOCSET)
	tar --exclude='.DS_Store' -czf $@ $(DOCSET_DIR)

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCSET_DIR):
	mkdir -p $@

$(CONTENTS_DIR): $(DOCSET_DIR)
	mkdir -p $@

$(RESOURCES_DIR): $(CONTENTS_DIR)
	mkdir -p $@

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INFO_PLIST_FILE): src/Info.plist $(CONTENTS_DIR)
	cp src/Info.plist $@

$(INDEX_FILE): src/index-pages.sh $(DOCUMENTS_DIR)
	rm -f $@
	src/index-pages.sh $@ $(DOCUMENTS_DIR)/*.html
ifndef NO_CSS
	src/set-stylesheet.sh "yes" $(DOCUMENTS_DIR)/*.html
else
	src/set-stylesheet.sh "no" $(DOCUMENTS_DIR)/*.html
endif
	src/index-terms.sh "Entry" $@ $(DOCUMENTS_DIR)/Concept-Index.html
	src/index-terms.sh "Directive" $@ $(DOCUMENTS_DIR)/Name-Index.html

$(ICON_FILE): src/icon.png $(DOCSET_DIR)
	cp $(SRC_ICON) $@