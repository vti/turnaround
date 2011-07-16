package Bar;

use base 'Lamework::Base';

sub foo { $_[0]->{foo} }

sub hello { @_ > 1 ? $_[0]->{hello} = $_[1] : $_[0]->{hello} }

1;
