package Baz;
use base 'Lamework::Base';

sub foo { $_[0]->{foo} }
sub bar { $_[0]->{bar} }

1;
