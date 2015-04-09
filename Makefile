.DELETE_ON_ERROR:

LIB_DIR = ./lib
DIST_DIR = ./dist

export PATH := ./node_modules/.bin:$(PATH)
LIB_SCRIPTS := $(shell find $(LIB_DIR) -name '*.js')

# Creating release artifacts
.PHONY: dist
dist: $(DIST_DIR)/hashed.js $(DIST_DIR)/hashed.min.js

$(DIST_DIR)/hashed.js: $(LIB_SCRIPTS) node_modules/.time
	@mkdir -p $(DIST_DIR)
	@webpack --devtool=inline-source-map --output-library-target=umd --output-library=hashed $(LIB_DIR)/index.js $@;

$(DIST_DIR)/hashed.min.js: $(LIB_SCRIPTS) node_modules/.time
	@mkdir -p $(DIST_DIR)
	@webpack --optimize-minimize --output-library-target=umd --output-library=hashed $(LIB_DIR)/index.js $@;

.PHONY: clean
clean:
	@rm -rf $(DIST_DIR)

# Install Node based dependencies
node_modules/.time: package.json
	@npm prune
	@npm install
	@touch $@

help:
	@echo ""
	@echo "make		- builds hashed.js and hashed.min.js"
	@echo "make publish	- publish build artifacts"
	@echo "make clean	- remove build artifacts"
	@echo ""

# Publish a new release
# (assumes `npm version && git push --tags origin` has been run first)
.PHONY: publish
publish: clean dist
	@npm publish
