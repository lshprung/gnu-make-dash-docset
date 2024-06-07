SRC_ICON_FILE = $(SOURCE_DIR)/icon.png

MANUAL_URL  = http://www.gnu.org/software/make/manual/make.html_node.tar.gz
MANUAL_FILE = tmp/make.html_node.tar.gz

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INDEX_FILE): $(wildcard $(SOURCE_DIR)/src/*.sh) $(wildcard $(SCRIPTS_DIR)/*.sh) $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index-pages.sh $@ $(DOCUMENTS_DIR)/*.html
ifneq ($(NO_CSS),yes)
	$(SOURCE_DIR)/src/set-stylesheet.sh "yes" $(DOCUMENTS_DIR)/*.html
else
	$(SOURCE_DIR)/src/set-stylesheet.sh "no" $(DOCUMENTS_DIR)/*.html
endif
	$(SOURCE_DIR)/src/index-terms.sh "Entry" $@ $(DOCUMENTS_DIR)/Concept-Index.html
	$(SOURCE_DIR)/src/index-terms.sh "Directive" $@ $(DOCUMENTS_DIR)/Name-Index.html
