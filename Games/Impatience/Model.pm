package Games::Impatience::Model;

use strict;
use warnings;

use Carp;

use Class::XSAccessor {
    constructor => '_create_empty_new',
    accessors => [],
};

sub new
{    
    my $class = shift;

    my $self = $class->_create_empty_new(@_);

    return $self;
}

1;
