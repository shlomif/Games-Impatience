#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

{
    # TEST
    ok (!system($^X, "-c", "solitaire.pl"),
        "solitaire.pl compiles.");
}
