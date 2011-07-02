package Games::Impatience::PySolDeal;

use strict;
use warnings;

use Getopt::Long;

use Games::Impatience::MicrosoftRand;

my $MS_SUITS = 'CDHS';
my $OUR_SUITS = 'HCDS';

my @suits;
foreach my $suit (split//, $MS_SUITS)
{
    push @suits, index($OUR_SUITS, $suit);
}
my $RANKS = 'A23456789TJQK';

sub shuffle
{
    my $args = shift;

    my $seed = $args->{seed};

    my @deck;

    foreach my $rank (0 .. 12)
    {
        foreach my $suit (@suits)
        {
            push @deck, +{rank => $rank, suit => $suit};
        }
    }

    my @shuffled;
    my $r = Games::Impatience::MicrosoftRand->new(seed => $seed);

    for my $i (0 .. 51)
    {
        my $j = ($r->rand() % @deck);
        push @shuffled, $deck[$j];

        my $last_card = pop(@deck);
        if ($j != @deck)
        {
            $deck[$j] = $last_card;
        }
    }

    return \@shuffled;
}

1;
