SERVICE_VERSION ?= $(shell git rev-parse --short HEAD)
SERVICE_NAME := cv-generator
CONTAINER_VERSION := v4
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
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		xelatex -jobname=danpilch-resume-${DATE} -output-directory=output resume.tex
	
	# Build HTML (requires Pandoc in the container)
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		make4ht -f html5+inlinecss --output-dir ./output/ -l resume.tex "xelatex"

	# Cleanup make4ht build files
	rm -rf *.aux *.log *.dvi *.4ct *.4tc *.lg *.idv *.tmp *.css *.html *.xref

	# Build TXT (requires Pandoc in the container)
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		pandoc resume.tex --from=latex -t plain -o output/danpilch-resume-${DATE}.txt

.PHONY: release
release: description = Create a GitHub release for the new version
release: clean build
	DATE=$(shell date +%Y-%m-%d)
	TAG="resume-$(shell date +%Y-%m-%d-%H%M%S)"
	gh release create ${TAG} \
		--title "Resume Release ${DATE}" \
		--notes "Release generated on ${DATE}" \
		output/danpilch-resume-${DATE}.pdf \
		output/danpilch-resume-${DATE}.docx \
		output/danpilch-resume-${DATE}.txt

### Local Build Targets (skip Docker)

.PHONY: build-local
build-local: description = Build PDF locally if XeLaTeX is installed
build-local:
	xelatex -output-directory=./output resume.tex

.PHONY: build-txt-local
build-txt-local: description = Build TXT locally if Pandoc is installed
build-txt-local:
	pandoc resume.tex --from=latex -t plain -o output/danpilch-resume.txt

### Utility

.PHONY: clean
clean: description = Clean build output dir
clean:
	rm -rf *.aux *.log *.dvi *.4ct *.4tc *.lg *.idv *.tmp *.css *.html *.xref
	rm -rf ./output/*
	rm -rf ./.build/*

.PHONY: view
view: description = View generated CV PDF
view:
	open ./output/danpilch-resume-${DATE}.pdf
