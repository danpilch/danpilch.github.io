SERVICE_VERSION ?= $(shell git rev-parse --short HEAD)
SERVICE_NAME := cv-generator
CONTAINER_VERSION := v5
DATE := $(shell date '+%Y-%m-%d')

# Utility functions
check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = $(if $(value $1),, \
	$(error undefined '$1' variable: $2))

help: HELP_SCRIPT = \
	if (/^([a-zA-Z0-9-\.\/]+).*?: description\s*=\s*(.+)/) { \
		printf "\033[34m%-40s\033[0m %s\n", $$1, $$2 \
	} elsif(/^\#\#\#\s*(.+)/) { \
		printf "\033[33m>> %s\033[0m\n", $$1 \
	}

.PHONY: help
help:
	@perl -ne '$(HELP_SCRIPT)' $(MAKEFILE_LIST)

### Build Targets

# 'all' will build PDF, TXT
all: build

.PHONY: build
build: description = Build PDF, DOCX, and TXT via Docker
build: clean
	# Build PDF
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:v6 \
            	typst compile resume.typ danpilch-resume-${DATE}.pdf
	
	# Run clean at the end
	$(MAKE) clean

DATE=$(shell date +%Y-%m-%d)
TIME=$(shell date +%H%M%S)
TAG="resume-$(DATE)-$(TIME)"

.PHONY: release
release: description = Create a GitHub release for the new version
release: clean
	gh release create ${TAG} \
		--title "Resume Release ${DATE}" \
		--notes "Release generated on ${DATE}"

### Utility

.PHONY: clean
clean: description = Clean build dir
clean:
	rm -rf resume.tex.bak resume_tmp.tex *.bak resume_tmp.tex *.aux *.log *.dvi *.4ct *.4tc *.lg *.idv *.tmp *.css *.html *.xref *.md
	rm -rf ./.build/*

.PHONY: clean-output
clean-output: description = Clean build dir
clean-output:
	rm -rf ./output/*

.PHONY: view
view: description = View generated CV PDF
view:
	open ./output/danpilch-resume-${DATE}.pdf
