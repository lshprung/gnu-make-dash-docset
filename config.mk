SRC_ICON_FILE = $(SOURCE_DIR)/icon.png

MANUAL_URL  = http://www.gnu.org/software/make/manual/make.html_node.tar.gz
MANUAL_FILE = tmp/make.html_node.tar.gz

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INDEX_FILE): $(SOURCE_DIR)/src/index-pages.py $(SCRIPTS_DIR)/set-stylesheet.py $(SCRIPTS_DIR)/gnu/index-terms-colon.py $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index-pages.py $@ $(DOCUMENTS_DIR)/*.html
ifneq ($(NO_CSS),yes)
	$(SCRIPTS_DIR)/set-stylesheet.py "yes" $(DOCUMENTS_DIR)/*.html
else
	$(SCRIPTS_DIR)/set-stylesheet.py "no" $(DOCUMENTS_DIR)/*.html
endif
	$(SCRIPTS_DIR)/gnu/index-terms-colon.py Entry $@ $(DOCUMENTS_DIR)/Concept-Index.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.py Directive $@ $(DOCUMENTS_DIR)/Name-Index.html
