package Games::Impatience::MicrosoftRand;

use strict;
use warnings;

use integer;

use Class::XSAccessor {
    constructor => 'new',
    accessors => [qw(seed)],
};

sub rand
{
    my $self = shift;
    $self->seed(($self->seed() * 214013 + 2531011) & (0x7FFF_FFFF));
    return (($self->seed >> 16) & 0x7fff);
}

1;
