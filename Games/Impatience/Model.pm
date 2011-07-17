package Games::Impatience::Model;

use strict;
use warnings;

use Carp;

use Class::XSAccessor {
    accessors => [qw(_columns _undealt_talon _dealt_talon 
           _id_lookup _foundations)],
};

sub new
{    
    my $class = shift;

    my $self = {};
    
    bless $self, $class;
    
    $self->_init(@_);

    return $self;
}

sub _init
{
    my ($self, $args) = @_;

    $self->_columns([ map { [] } (1 .. 7)]);

    $self->_dealt_talon([]);
    $self->_undealt_talon([]);

    $self->_id_lookup({});

    $self->_foundations([ map { 0 } (0 .. 3)]);

    return;
}

sub add_card_to_talon
{
    my ($self, $card) = @_;

    push @{$self->_undealt_talon}, $card;

    $self->_id_lookup->{$card->{id}} =
    {
        place => 'undealt_talon',
        pos => $#{$self->_undealt_talon},
    };

    return;
}

sub add_card_to_column
{
    my ($self, $col_idx, $card) = @_;

    if (($col_idx < 0) || ($col_idx > $#{$self->_columns}))
    {
        Carp::confess ("col_idx $col_idx is out of range.");
    }

    my $col = $self->_columns->[$col_idx];

    push @$col, $card;

    $self->_id_lookup->{$card->{id}} =
    {
        place => 'columns',
        pos => [$col_idx, $#$col],
    };

    return;
}

1;
