#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use SDLx::Point2D;

{
    my $point = SDLx::Point2D->new(x => 100, y => 200);

    # TEST
    ok ($point, "Point was initialized.");

    # TEST
    is ($point->x, 100, "X is 100.");

    # TEST
    is ($point->y, 200, "Y is 200.");
}
