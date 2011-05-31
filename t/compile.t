#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

{
    # TEST
    ok (!system($^X, "-c", "Games/Impatience.pm"),
        "solitaire.pl compiles.");
}
