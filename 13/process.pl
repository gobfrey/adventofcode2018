#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my $map = process_input(load_data('input.txt'));

output_map($map);

my $i = 0;
foreach (1..10000000)
{
	$i++;
	print STDERR "Tick $i\n";
	tick($map);
#	output_map($map);
}


sub tick
{
	my ($map) = @_;

	my ($x, $y) = (0,0);

	my $cart_locations = [];

	ROW: while (1)
	{
		$x = 0;
		last ROW if (!defined $map->{$x}->{$y});
		COL: while(1)
		{
			last COL if (!defined $map->{$x}->{$y});

			my $cell = $map->{$x}->{$y};
			if ($cell->{type} eq 'track' && $cell->{cart})
			{
				push @{$cart_locations}, [$x,$y];
			}
			$x++;
		}
		$y++;
	}

	my $cart_count = scalar @{$cart_locations};
	print "Moving $cart_count carts\n";
	if ($cart_count < 2)
	{
		use Data::Dumper;
		print STDERR Dumper $cart_locations;
		exit;
	}
	


	foreach my $location (@{$cart_locations})
	{
		step_cart($map, @{$location});
	}
}

sub step_cart
{
	my ($map, $x, $y) = @_;

	my $cell = $map->{$x}->{$y};

	return unless $cell->{cart}; #it might have been removed due to a collision

	my $cart = delete $cell->{cart};

	my $direction = cart_movement_direction($map, $cart, $x, $y);
	$y-- if $direction eq 'up';
	$y++ if $direction eq 'down';
	$x-- if $direction eq 'left';
	$x++ if $direction eq 'right';

	my $destination_type = location_type($map, $x, $y);

	my $destination_cell = $map->{$x}->{$y};
	if ($destination_cell->{cart})
	{
		print STDERR "Collision at $x,$y -- removing two carts\n";
		delete $map->{$x}->{$y}->{cart};
	}
	else
	{
		$destination_cell->{cart} = $cart;
		adjust_cart_facing($map, $x, $y, $direction);
	}
}

sub adjust_cart_facing
{
	my ($map, $x, $y, $direction) = @_;

	my $cell = $map->{$x}->{$y};

	my $track_char = $cell->{track};
	my $cart = $cell->{cart};
	my $cart_char = $cart->{cart};

	if ($track_char eq '+')
	{
		my $turn_direction = $cart->{next_direction};
		$cart->{next_direction} = next_direction($turn_direction);

		my $turn_map =
		{
			'straight' => { '^' => '^', 'v' => 'v', '>' => '>', '<' => '<' },
			'left' => { '^' => '<', 'v' => '>', '>' => '^', '<' => 'v' },
			'right' => { '^' => '>', 'v' => '<', '>' => 'v', '<' => '^' }

		};
		$cart->{cart} = $turn_map->{$turn_direction}->{$cart_char};
		return;
	}

	my $facing_map =
	{
		'/' =>	{ up => '>', down => '<', right => '^', left => 'v'},
		'\\' =>	{ up => '<', down => '>', right => 'v', left => '^'},
		'|' =>	{ up => '^', down => 'v'},
		'-' =>	{ right => '>', left => '<'}
	};

	if (!$facing_map->{$track_char}->{$direction})
	{
		die "invalid move $track_char -> $direction \n";
	}

	$cart->{cart} = $facing_map->{$track_char}->{$direction};
}

sub cart_movement_direction
{
	my ($map, $cart, $x, $y) = @_;

	my $cart_char = $cart->{cart};

	return 'down' if ($cart_char eq 'v');
	return 'up' if ($cart_char eq '^');
	return 'left' if ($cart_char eq '<');
	return 'right' if ($cart_char eq '>');

}

sub output_map
{
	my ($map) = @_;


	my ($x, $y) = (0,0);

	ROW: while (1)
	{
		$x = 0;
		last ROW if (!defined $map->{$x}->{$y});
		COL: while(1)
		{
			last COL if (!defined $map->{$x}->{$y});
			output_cell($map->{$x}->{$y});
			$x++;
		}
		print "\n";
		$y++;
	}

	print "\n";
}

sub output_cell
{
	my ($cell) = @_;

	if ($cell->{cart})
	{
		print $cell->{cart}->{cart};
	}
	else
	{
		print $cell->{track};
	}
}

sub create_cell
{
	my ($char) = @_;

	my $type = char_type($char);

	my $cell = {};

	if ($type eq 'cart')
	{
		$cell->{type} = 'track';
		$cell->{track} = '|' if ($char eq 'v' || $char eq '^');
		$cell->{track} = '-' if ($char eq '>' || $char eq '<');
		$cell->{cart} = { cart => $char, next_direction => 'left' };
	}
	else
	{
		$cell->{type} = $type;
		$cell->{track} = $char;
	}

	return $cell;
}

sub next_direction
{
	my ($direction) = @_;

	return 'straight' if $direction eq 'left';
	return 'right' if $direction eq 'straight';
	return 'left' if $direction eq 'right';

}

sub location_type
{
	my ($map, $x, $y) = @_;

	return 'empty' if (!$map->{$x} || !$map->{$x}->{$y});
	return $map->{$x}->{$y}->{type};
}

sub char_type
{
	my ($char) = @_;
	return 'cart' if is_cart($char);
	return 'track' if is_track($char);
	return 'empty';
}

sub is_cart
{
	my ($char) = @_;
	return 1 if $char eq 'v';
	return 1 if $char eq '^';
	return 1 if $char eq '>';
	return 1 if $char eq '<';
	return 0;
}

sub is_track
{
	my ($char) = @_;
	return 1 if $char eq '|';
	return 1 if $char eq '-';
	return 1 if $char eq '\\';
	return 1 if $char eq '/';
	return 1 if $char eq '+';
	return 0;
}

sub process_input
{
	my (@lines) = @_;

	my $map = {};
	my $y = 0;
	foreach my $line (@lines)
	{
		chomp($line);
		my $x = 0;
		foreach my $char (split(//,$line))
		{
			$map->{$x}->{$y} = create_cell($char);
			$x++;
		}
		$y++;
	}
	return $map;
}



sub load_data
{
	my ($filename) = @_;

	open FILE, $filename or die "Couldn't open $filename\n";
	return <FILE>;
}
