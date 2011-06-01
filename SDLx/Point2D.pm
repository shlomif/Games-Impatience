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

=head1 SYNOPSIS

    use SDLx::Point2D;

    my $point = SDLx::Point2D->new(x => 5, y => 100);

    # Prints 5
    print $point->x(), "\n";

    # Prints 100
    print $point->y(), "\n";

    # Prints "(5,100)"
    printf "(%s)\n", join(',', @{$point->xy});


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

Copyright 2010 Shlomi Fish.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

1;
