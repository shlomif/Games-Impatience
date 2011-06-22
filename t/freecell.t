#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use Games::ImFreecell;

{
    my $game = Games::ImFreecell->new;

    # TEST
    ok ($game, "Game was initialised.");
}

