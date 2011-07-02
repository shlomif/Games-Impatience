#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

use Games::Impatience::MicrosoftRand;

my $SUITS = 'CDHS';
my $RANKS = 'A23456789TJQK';

sub shuffle
{
    my $seed = shift;

    my @deck;

    foreach my $rank (0 .. 12)
    {
        foreach my $suit (0 .. 3)
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

my $seed;

GetOptions(
    'seed=i' => \$seed,
) or die "Improper options - $!";

if (!defined($seed))
{
    die "You must specify a seed!";
}

print join(' ', map { substr($RANKS, $_->{rank},1).substr($SUITS, $_->{suit}, 1) }
    @{shuffle($seed)}), "\n";
    ;
1;

