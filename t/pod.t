#!perl -T

use strict;
use warnings;
use Test::More tests => 2;

use Test::Pod 1.22;

# TEST
pod_file_ok( 'SDLx/Point2D.pm', 'SDLx/Point2D.pm has valid POD' );

# TEST
pod_file_ok ('Games/Impatience.pm', 'Games/Impatience.pm has valid POD');
