This a collection of various scripts I have written over the years.  They are
usually relatively quick and dirty, but there may be a useful nugget or two to
be gleaned from looking at them.

* newenv.pl - This was a script for managing our puppet environments.  We
  started using it before we knew of r10k (maybe before it existed), and it
  incorporated puppet-librarian.  At some point, we replaced puppet-librarian
  with r10k, but just for module wrangling.  I am not sure that r10k can still
  be used this way.

* repostatus.sh - This script just runs through repos in a directory and
  provides a simple indicator of their status (ooh, colors!)