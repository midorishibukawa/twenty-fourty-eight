THIS := $(lastword $(MAKEFILE_LIST))

.PHONY: build
build:
	@nix build

.PHONY: build-docker
build-docker:
	@$(MAKE) -f $(THIS) build-static
	@nix-build image.nix
	@docker load < result

.PHONY: build-static 
build-static:
	@nix build .#prd

.PHONY: dev 
dev:
	@nix develop -c $$SHELL

.PHONY: doc
doc:
	@dune build @doc

.PHONY: run 
run:
	@dune build
	@dune exec twenty_fourty_eight 

.PHONY: test-base
test-base:
	@export BISECT_FILE=$(PWD)/cobertura
	@dune runtest --instrument-with bisect_ppx --force

.PHONY: test
test:
	@$(MAKE) -f $(THIS) test-base
	@bisect-ppx-report summary

.PHONY: test-html
test-html:
	@$(MAKE) -f $(THIS) test-base
	@bisect-ppx-report html

.PHONY: watch 
watch:
	@dune build -w @run
