(lang dune 2.0)

(name mssh)





(license ISC)

(authors
  "ssun")

(maintainers
  "ssun")

(generate_opam_files true)

(package
 (name mssh)
 (synopsis "Ssh into multiple hosts in tmux panes")
 (description "Ssh into multiple hosts in tmux panes")
 (depends
  (ocaml (>= 4.08.0))
  dune
  (alcotest :with-test)
  (odoc :with-doc)))
