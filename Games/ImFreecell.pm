#!/usr/bin/perl

package Games::ImFreecell;

use strict;
use warnings;

use Carp;

use Class::XSAccessor {
    constructor => '_create_empty_new',
    accessors => [],
};

=head1 NAME

Games::ImFreecell - an implementation of Patience for Perl/SDL (Klondike
so far)

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';

=head1 SYNOPSIS

    use Games::ImFreecell;

    my $game = Games::ImFreecell->new();

    $game->play();

=cut

use Time::HiRes;

use SDL;
use SDL::Event;
use SDL::Events;
use SDL::Rect;
use SDL::Surface;
use SDL::Video;

use SDLx::SFont;
use SDLx::Surface;
use SDLx::Sprite;

use SDLx::LayerManager;
use SDLx::Layer;
use SDLx::FPS;
use SDLx::Point2D;


# Some constants.
my $WINDOW_WIDTH  = 800;
my $WINDOW_HEIGHT = 600;

my $NUM_RANKS_IN_SUITS = 13;

my $hotspot_offset         = 20;

sub new
{
    my $class = shift;

    my $self = $class->_create_empty_new(@_);

    return $self;
}

1;

=head1 AUTHOR

Tobias Leich (FROGGS), L<http://github.com/FROGGS> .

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-impatience at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Impatience>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Impatience

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Games-Impatience>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Games-Impatience>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Games-Impatience>

=item * Search CPAN

L<http://search.cpan.org/dist/Games-Impatience/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright by Tobias Leich ("FROGGS"), 2010-2011 under the Artistic 2.0
License (or at your option any later version of that license). See the
C<COPYING> file for details.

=cut

