## 2048 in OCaml

An implementation of Gabriele Cirulli's 2048 game written in OCaml.


## Setting up

If you're using [nix](https://nixos.org/), you can simply run `make dev`
in order to launch a new shell with everything set up.


## Building

If you want to build a dynamically linked binary, you can run `make build`.
The binary will be located at `result/bin/twenty_fourty_eight`. If you want to
build a statically linked binary, you can run `make build_static` instead.


## Running

You can simply run `make run` to compile the code and launch the executable.
Running `make watch` will launch the executable and automatically recompile and
re-execute the new version of the code.


## Testing

You can run all tests by using the `make test` command. If you want to generate
an html file you can navigate and visualise the code coverage, you can run
`make test-html` instead.
