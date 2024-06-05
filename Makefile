build:
	nix build

build_static:
	nix build .#prd

dev:
	nix develop -c $$SHELL

run:
	dune build
	dune exec twenty_fourty_eight 

.PHONY: test
test:
	export BISECT_FILE=${PWD}/cobertura && \
	dune runtest --instrument-with bisect_ppx --force && \
	bisect-ppx-report summary

test-html:
	export BISECT_FILE=${PWD}/cobertura && \
	dune runtest --instrument-with bisect_ppx --force && \
	bisect-ppx-report html

watch:
	dune build -w @run
