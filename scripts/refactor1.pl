#!/usr/bin/perl

use strict;
use warnings;

my $point_name = shift(@ARGV);

use IO::All;

my $contents = io->file("solitaire.pl")->slurp;

unless ($contents =~ s/(my \$\Q$point_name\E * = *SDLx::Point2D->new\( *x *=> *(\d+) *, *y *=> *(\d+),? *\);)/# $1/)
{
    die "Cannot find $point_name";
}

my ($x, $y) = ($2, $3);

$contents =~ s{(\n *# ADD_HERE_POINT)}/    \$self->_add_point('$point_name', { x=> $x, y => $y, });$1/;

$contents =~ s{\$\Q$point_name\E->xy}/\$self->_point_xy('$point_name')/g;
$contents =~ s{\$\Q$point_name\E->x\b}/\$self->_point_x('$point_name')/g;
$contents =~ s{\$\Q$point_name\E->y\b}/\$self->_point_y('$point_name')/g;

io->file("solitaire.pl")->print($contents);
