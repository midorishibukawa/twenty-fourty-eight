(lang dune 3.12)

(name twenty_fourty_eight)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name twenty_fourty_eight)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   batteries
   crunch
   dream
   dream-html
   dune
   ocaml
   ppx_inline_test
   )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
