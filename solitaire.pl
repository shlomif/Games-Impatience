#!/usr/bin/perl

package Games::Cards::Solitaire::SDL;

use strict;
use warnings;

use Carp;

use Class::XSAccessor {
    constructor => '_create_empty_new',
    accessors => [qw(display event fps last_click layers left_mouse_down loop
        _points    
    )],
};

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

SDL::init(SDL_INIT_VIDEO);

my $WINDOW_WIDTH  = 800;
my $WINDOW_HEIGHT = 600;

sub new
{
    my $class = shift;

    my $self = $class->_create_empty_new(@_);

    $self->display(scalar (SDL::Video::set_video_mode(
                $WINDOW_WIDTH, $WINDOW_HEIGHT, 32, SDL_HWSURFACE | SDL_HWACCEL
            ))); # SDL_DOUBLEBUF

    $self->layers( SDLx::LayerManager->new() );

    $self->event( SDL::Event->new() );

    $self->fps( SDLx::FPS->new(fps => 60) );

    $self->loop(1);

    $self->last_click(Time::HiRes::time);

    $self->_points(+{});

    $self->_add_point('rewind_deck_1_position', { x => 20,   y => 20,  });
    $self->_add_point('rewind_deck_1_hotspot',  { x => 40,   y => 40,  });
    $self->_add_point('rewind_deck_2_position', { x=> 130, y => 20, });    $self->_add_point('rewind_deck_2_hotspot', { x=> 150, y => 40, });    $self->_add_point('left_stack_position', { x=> 20, y => 200, });    $self->_add_point('left_stack_hotspot', { x=> 40, y => 220, });    $self->_add_point('left_target_position', { x=> 350, y => 20, });    $self->_add_point('left_target_hotspot', { x=> 370, y => 40, });    $self->_add_point('space_between_stacks', { x=> 110, y => 20, });
    # ADD_HERE_POINT
    return $self;
}

sub _add_point {
    my ($self, $name, $xy) = @_;

    $self->_points->{$name} = SDLx::Point2D->new(%$xy);
}

sub _point {
    my ($self, $name) = @_;

    if (! exists($self->_points->{$name})) {
        Carp::confess "Unknown Point of name '$name'!";
    }

    return $self->_points->{$name};
}

sub _point_x {
    my ($self, $name) = @_;

    return $self->_point($name)->x;
}

sub _point_y {
    my ($self, $name) = @_;

    return $self->_point($name)->y;
}


sub _point_xy {
    my ($self, $name) = @_;

    return $self->_point($name)->xy;
}

my $NUM_RANKS_IN_SUITS = 13;

my $hotspot_offset         = 20;

sub play
{
    my $self = shift;

    $self->init_background();
    $self->init_cards();

    if ( my @rects = @{$self->layers->blit($self->display)} ) {
        SDL::Video::update_rects($self->display, @rects);
    }

    return $self->game();
}

sub _x
{
    return shift->pos->x;
}

sub _y
{
    return shift->pos->y;
}

sub _is_num {
    return shift =~ m{\A\d+\z};
}

sub _is_layer_visible {
    my ($layer) = @_;

    return
    (
           defined $layer
        && $layer->data->{id} =~ m/\d+/
        && $layer->data->{visible}
        && !scalar @{$layer->ahead}
    );
}

sub _handle_layer {
    my ($self, $layer, $stack_ref) = @_;

    my $target = $self->layers->by_position(
        $self->_point_x('left_target_hotspot') + $self->_point_x('space_between_stacks') * int($layer->data->{id} / 13), $self->_point_y('left_target_hotspot')
    );

    if($self->can_drop($layer->data->{id}, $target->data->{id})) {

        $layer->attach($self->event->button_x, $self->event->button_y);
        $layer->foreground;

        my $square = sub { my $n = shift; return $n*$n; };

        my $calc_dx = sub {
            return ( _x($target) - _x($layer) ); 
        };
        my $calc_dy = sub { 
            return ( _y($target) - _y($layer) ); 
        };

        my $calc_dist = sub {
            return sqrt(
                $square->($calc_dx->()) + $square->($calc_dy->())
            );
        };

        my $dist  = 999;
        my $steps = $calc_dist->() / 40;

        my $step_x = $calc_dx->() / $steps;
        my $step_y = $calc_dy->() / $steps;

        while($dist > 40) {

            #$w += $layer->clip->w - $x;
            #$h += $layer->clip->h - $y;
            $layer->pos(
                _x($layer) + $step_x, _y($layer) + $step_y
            );
            $self->layers->blit($self->display);
            #SDL::Video::update_rect($self->display, $x, $y, $w, $h);
            SDL::Video::update_rect($self->display, 0, 0, 0, 0);
            $self->fps->delay;

            $dist = $calc_dist->();
        }
        $layer->detach_xy(_x($target), _y($target));

        if (@$stack_ref)
        {
            $self->show_card(pop @$stack_ref);
        }

        return 1;
    }
    else {
        return;
    }
}

sub _calc_default_layer {
    my ($self, $idx) = @_;

    return +($idx == -1)
        ? $self->layers->by_position( @{$self->_point_xy('rewind_deck_2_hotspot')} )
        : $self->layers->by_position( 
            $self->_point_x('left_stack_hotspot') + $self->_point_x('space_between_stacks') * $idx, 
            $self->_point_y('left_stack_hotspot') 
        );
}

sub _handle_mouse_button_up
{
    my ($self, $handler) = @_;

    $self->left_mouse_down(0) if $self->event->button_button == SDL_BUTTON_LEFT;
    $handler->{on_drop}->();

    my $dropped = 1;
    while($dropped) {
        $dropped = 0;
        for my $idx (-1..6) {

            my $layer = $self->_calc_default_layer($idx);

            my @stack = ($layer, @{$layer->ahead});
            
            $layer = pop @stack if scalar @stack;
            
            if( _is_layer_visible($layer) ) {
                $dropped = $self->_handle_layer($layer, \@stack);
            }
        }
    }
}

sub event_loop
{
    my $self = shift;

    my $handler = shift;
    
    SDL::Events::pump_events();
    while(SDL::Events::poll_event($self->event))
    {
        my $type = $self->event->type;

        if ($type == SDL_MOUSEBUTTONDOWN) {
            $self->left_mouse_down(1) if $self->event->button_button == SDL_BUTTON_LEFT;
            my $time = Time::HiRes::time;
            if ($time - $self->last_click >= 0.3) {
                $handler->{on_click}->();
            }
            else {
                $handler->{on_dblclick}->();
            }
            $self->last_click($time);
        }
        elsif ($type == SDL_MOUSEMOTION) {
            if ($self->left_mouse_down) {
                $handler->{on_drag}->();
            }
            else {
                $handler->{on_mousemove}->();
            }
        }
        elsif ($type == SDL_MOUSEBUTTONUP) {
            $self->_handle_mouse_button_up($handler);
        }
        elsif ($type == SDL_KEYDOWN) {
            if($self->event->key_sym == SDLK_PRINT) {

                my $screen_shot_index = 1;

                # TODO : perhaps do it using max.
                foreach my $bmp_fn (<Shot*\.bmp>)
                {
                    if (my ($new_index) = $bmp_fn =~ /Shot(\d+)\.bmp/)
                    { 
                        if ($new_index >= $screen_shot_index)
                        {
                            $screen_shot_index = $new_index + 1;
                        }
                    }
                }

                SDL::Video::save_BMP($self->display, sprintf("Shot%04d.bmp", $screen_shot_index ));
            }
            elsif($self->event->key_sym == SDLK_ESCAPE) {
                $handler->{on_quit}->();
            }
            $handler->{on_keydown}->();
        }
        elsif ($type == SDL_QUIT) {
            $handler->{on_quit}->();
        }
    }
}

sub game
{
    my $self = shift;

    my @selected_cards = ();
    my $x = 0;
    my $y = 0;
    my $handler =
    {
        on_quit    => sub {
            $self->loop(0);
        },
        on_drag => sub {
        },
        on_drop    => sub {
            # @selected_cards contains whatever set
            # of cards the player is moving around
            if(scalar @selected_cards) {
                my @selected_cards_ = (map { $_->foreground } @selected_cards);

                my @stack           = scalar @selected_cards_
                                    ? @{$selected_cards[0]->behind}
                                    : ();
                my $dropped         = 0;
                my @position_before = ();
                
                if(scalar @stack) {
                    # to empty field
                    if($stack[0]->data->{id} =~ m/empty_stack/
                       && $self->can_drop($selected_cards[0]->data->{id}, $stack[0]->data->{id})) {
                        @position_before = @{$self->layers->detach_xy($stack[0]->pos->x, $stack[0]->pos->y)};
                        $dropped         = 1;
                    }
                    
                    # to face-up card
                    elsif($stack[0]->data->{visible}
                       && $self->can_drop($selected_cards[0]->data->{id}, $stack[0]->data->{id})) {
                        @position_before = @{$self->layers->detach_xy($stack[0]->pos->x, $stack[0]->pos->y + $self->_point_y('space_between_stacks'))};
                        $dropped         = 1;
                    }
                    
                    if($dropped && scalar @position_before) {
                        $position_before[0] += $hotspot_offset; # transparent border
                        $position_before[1] += $hotspot_offset;
                        $self->show_card(@position_before);
                    }
                }

                $self->layers->detach_back unless $dropped;
            }
            @selected_cards = ();
        },
        on_click => sub {
            unless(scalar @selected_cards) {
                my $layer = $self->layers->by_position($self->event->button_x, $self->event->button_y);
                
                if(defined $layer) {
                    if($layer->data->{id} =~ m/^\d+$/) {
                        if($layer->data->{visible}) {
                            @selected_cards = ($layer, @{$layer->ahead});
                            $self->layers->attach(@selected_cards, $self->event->button_x, $self->event->button_y);
                        }
                        elsif(!scalar @{$layer->ahead}) {
                            $layer->attach($self->event->button_x, $self->event->button_y);
                            $layer->foreground;
                            $layer->detach_xy(@{$self->_point_xy('rewind_deck_2_position')});
                            $self->show_card($layer);
                        }
                    }
                    elsif($layer->data->{id} =~ m/rewind_deck/) {
                        $layer = $self->layers->by_position(@{$self->_point_xy('rewind_deck_2_hotspot')});
                        my @cards = ($layer, @{$layer->behind});
                        pop @cards;
                        pop @cards;
                        foreach my $card (@cards) {
                            $card->attach(@{$self->_point_xy('rewind_deck_2_hotspot')});
                            $card->foreground;
                            $card->detach_xy($self->_point_xy('rewind_deck_1_position'));
                            $self->hide_card($self->_point('rewind_deck_1_hotspot'));
                        }
                    }
                }
            }
        },
        on_dblclick => sub {
            $self->last_click(0);
            $self->layers->detach_back;

            my $layer  = $self->layers->by_position($self->event->button_x, $self->event->button_y);

            if(defined $layer
            && !scalar @{$layer->ahead}
            && $layer->data->{id} =~ m/\d+/
            && $layer->data->{visible}) {
                my $target = $self->layers->by_position(
                    $self->_point_x('left_target_hotspot') + 11 * int($layer->data->{id} / 13), $self->_point_y('left_target_hotspot')
                );

                if($self->can_drop($layer->data->{id}, $target->data->{id})) {
                    $layer->attach($self->event->button_x, $self->event->button_y);
                    $layer->foreground;
                    $layer->detach_xy(_x($target), _y($target));
                    $self->show_card($self->event->button_x, $self->event->button_y);
                }
            }
        },
        on_mousemove => sub {
        },
        on_keydown => sub {
        },
    };
    
    while($self->loop) {
        $self->event_loop($handler);
        $self->layers->blit($self->display);
        SDL::Video::update_rect($self->display, 0, 0, 0, 0);
        $self->fps->delay;
    }
}


sub _get_card_rank
{
    my ($card) = @_;

    return ($card % $NUM_RANKS_IN_SUITS);
}

sub _is_card_a_king {
    my ($card) = @_;

    return (_get_card_rank($card) == ($NUM_RANKS_IN_SUITS - 1));
}

sub _is_card_an_ace {
    my ($card) = @_;

    return (_get_card_rank($card) == 0);
}

sub can_drop {
    my $self = shift;

    my $card       = shift;
    my $card_color = int($card / 13);
    my $target     = shift;
    my $stack      = $self->layers->by_position($self->_point_x('left_target_hotspot') + $self->_point_x('space_between_stacks') * $card_color, $self->_point_y('left_target_hotspot'));
    
    #my @stack = $self->layers->get_layers_behind_layer($stack);
    #my @stack = $self->layers->get_layers_ahead_layer($stack);

    # Kings can be put on empty fields.
    if (_is_card_a_king($card)) {
        return 1 if $target =~ m/empty_stack/;
    }
    
    # Aces can be put on empty field (at upper right)
    if( _is_card_an_ace($card) 
        && $target =~ m/empty_target_\Q$card_color\E/) {
        return 1;
    }
    
    my $are_nums = _is_num($card) && _is_num($target);

    if ($are_nums
        && $card == $target + 1
        && $target == $stack->data->{id}
        && $stack->data->{visible}
    ) 
    {
        return 1;
    }
    
    if($are_nums
        && '12,25,38,51' !~ m/\b\Q$card\E\b/
        && ($card + 14 == $target || $card + 40 == $target
         || $card - 12 == $target || $card - 38 == $target)
    )
    {
        return 1;
    }
    
    return 0;
}

sub hide_card {
    my $self = shift;

    my $xy = shift;

    my $layer = $self->layers->by_position(@{$xy->xy});

    if($layer
    && $layer->data->{id} =~ m/\d+/
    && $layer->data->{visible}) {
        $layer->surface(SDL::Image::load('data/card_back.png'));
        $layer->data({id => $layer->data->{id}, visible => 0});
    }
}

sub show_card {
    my $self = shift;

    my $layer = (scalar @_ == 2) ? $self->layers->by_position(@_) : shift;

    if($layer
    && $layer->data->{id} =~ m/\d+/
    && !$layer->data->{visible}) {
        $layer->surface(SDL::Image::load('data/card_' . $layer->data->{id} . '.png'));
        $layer->data({id => $layer->data->{id}, visible => 1});
    }
}

sub init_background {

    my $self = shift;

    $self->layers->add(SDLx::Layer->new(SDL::Image::load('data/background.png'),                           {id => 'background'}));
    $self->layers->add(SDLx::Layer->new(SDL::Image::load('data/empty_stack.png'), @{$self->_point_xy('rewind_deck_1_position')}, {id => 'rewind_deck'}));
    $self->layers->add(SDLx::Layer->new(SDL::Image::load('data/empty_stack.png'), @{$self->_point_xy('rewind_deck_2_position')}, {id => 'empty_deck'}));
    
    foreach my $idx (0 .. 3) {
        $self->layers->add(
            SDLx::Layer->new(
                SDL::Image::load('data/empty_target_' . $idx . '.png'),
                $self->_point_x('left_target_position') + $self->_point_x('space_between_stacks') * $idx,
                $self->_point_y('left_target_position'),
                {id => 'empty_target_' . $idx}
            )
        );
    }
     
    for my $idx (0 .. 6)
    {
        $self->layers->add(
            SDLx::Layer->new(SDL::Image::load('data/empty_stack.png'),
                $self->_point_x('left_stack_position')  + $self->_point_x('space_between_stacks') * $idx, $self->_point_y('left_stack_position'),
                {id => 'empty_stack'}
            )
        );
    }
}

sub init_cards {
    my $self = shift;

    my $stack_index    = 0;
    my $stack_position = 0;
    my @card_value     = fisher_yates_shuffle([0..51]);
    for my $card (0..51)
    {
        my $image   = 'data/card_back.png';
        my $visible = 0;
        my ($x, $y) = @{$self->_point_xy('rewind_deck_1_position')};
        
        if($card < 28)
        {
            if($stack_position > $stack_index)
            {
                $stack_index++;
                $stack_position = 0;
            }
            if($stack_position == $stack_index)
            {
                $image   = 'data/card_' . $card_value[$card] . '.png';
                $visible = 1;
            }
            $x = $self->_point_x('left_stack_position') + $self->_point_x('space_between_stacks') * $stack_index;
            $y = $self->_point_y('left_stack_position') + $self->_point_y('space_between_stacks') * $stack_position;
            $stack_position++;
        }
        
        $self->layers->add(
            SDLx::Layer->new(
                SDL::Image::load($image), 
                $x, $y, 
                {id => $card_value[$card], visible => $visible}
            )
        );
    }
}

sub fisher_yates_shuffle
{
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
    return @$array;
}

1;

package main;

my $self = Games::Cards::Solitaire::SDL->new;
$self->play();

1;

