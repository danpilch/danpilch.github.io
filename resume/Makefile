SERVICE_VERSION ?= $(shell git rev-parse --short HEAD)
SERVICE_NAME := cv-generator
CONTAINER_VERSION := v2

# Utility functions
check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = $(if $(value $1),, \
	$(error undefined '$1' variable: $2))

# Pattern #1 example: "example : description = Description for example target"
# Pattern #2 example: "### Example separator text
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

# 'all' will build PDF, DOCX, and TXT
all: build

.PHONY: build
build: description = Build PDF, DOCX, and TXT via Docker
build: clean
	# Build PDF
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		xelatex -output-directory=output danpilch_resume.xtx

	# Build DOCX (requires Pandoc in the container)
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		pandoc danpilch_resume.xtx --from=latex -o output/danpilch_resume.docx

	# Build TXT (requires Pandoc in the container)
	docker run --rm \
		-v ${PWD}:/workspace -w /workspace \
		docker.io/danpilch/cv-build:${CONTAINER_VERSION} \
		pandoc danpilch_resume.xtx --from=latex -t plain -o output/danpilch_resume.txt

.PHONY: release
release: description = Create a GitHub release for the new version
release: clean build
	gh release create resume-$(shell date +%Y-%m-%d) --generate-notes

### Local Build Targets (skip Docker)

.PHONY: build-local
build-local: description = Build PDF locally if XeLaTeX is installed
build-local:
	xelatex -output-directory=./output danpilch_resume.xtx

.PHONY: build-docx-local
build-docx-local: description = Build DOCX locally if Pandoc is installed
build-docx-local:
	pandoc danpilch_resume.xtx -o output/danpilch_resume.docx

.PHONY: build-txt-local
build-txt-local: description = Build TXT locally if Pandoc is installed
build-txt-local:
	pandoc danpilch_resume.xtx -t plain -o output/danpilch_resume.txt

### Utility

.PHONY: clean
clean: description = Clean build output dir
clean:
	rm -rf ./output/*

.PHONY: view
view: description = View generated CV PDF
view:
	open ./output/danpilch_resume.pdf
