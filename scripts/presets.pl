#!/usr/bin/perl

use strict;
use warnings;

my $preset = shift(@ARGV);

my %presets_to_seeds =
(
    'empty_col' => 4,
);

if (!exists($presets_to_seeds{$preset}))
{
    die "Unknown preset '$preset';";
}

exec("./impatience", "--seed", $presets_to_seeds{$preset});
