#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use SDLx::Point2D;

{
    my $point = SDLx::Point2D->new(x => 100, y => 200);

    # TEST
    ok ($point, "Point was initialized.");

    # TEST
    is ($point->x, 100, "X is 100.");

    # TEST
    is ($point->y, 200, "Y is 200.");

    # TEST
    is_deeply ($point->xy(), [100,200], "XY pair returns a list.");
}
