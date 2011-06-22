#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use Games::ImFreecell;
use Games::Impatience::Model;

{
    my $game = Games::ImFreecell->new;

    # TEST
    ok ($game, "Game was initialised.");
}

{
    my $model = Games::Impatience::Model->new;

    # TEST
    ok ($model, "Model was initted.");
}
