SERVICE_VERSION ?= $(shell git rev-parse --short HEAD)
SERVICE_NAME := cv-generator

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

### Build

all: build

.PHONY: build-docker
build-docker: description = Build cv via docker image
build-docker: clean
	docker run \
		-v ${PWD}:/workspace -w /workspace docker.io/danpilch/cv-build xelatex -output-directory=output danpilch_resume.xtx

.PHONY: build-local
build-local:
	xelatex -output-directory=./output danpilch_resume.xtx


.PHONY: clean
clean: description = Clean build output dir
clean:
	rm -rf ./output/*

.PHONY: view
view: description = View generated CV PDF
view: 
	open ./output/danpilch_resume.pdf
