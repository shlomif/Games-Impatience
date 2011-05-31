package SDLx::Point2D;

use strict;
use warnings;

our $VERSION = '0.0.1';

use Class::XSAccessor {
    constructor => 'new',
    accessors => [qw(x y)],
};

sub xy {
    my ($self) = @_;

    return [$self->x, $self->y];
}

1;


__END__

=head1 NAME

SDLx::Point2D - Class for a 2-dimensional point.

=head1 VERSION

Version 0.0.1

=head1 METHODS

=head2 x()

The X-coordinate.

=head2 y()

The Y-coordinate.

=head2 my [$x, $y] = $point->xy();

Returns a pair of (X,Y) coordinates in a single array reference.

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 BUGS

Please report any bugs or feature requests to
C<sdlx-point2d at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SDLx-Point2D>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 TODO

=over 4

=item * Empty

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SDLx::Point2D

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/SDLx-Point2D>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/SDLx-Point2D>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=SDLx-Point2D>

=item * Search CPAN

L<http://search.cpan.org/dist/SDLx-Point2D/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT X11.

=cut

1;

