package Setters;

use base 'Lamework::Base';

sub set_foo {$_[0]->{value} = $_[1]}
sub get_foo {$_[0]->{value}}

1;
