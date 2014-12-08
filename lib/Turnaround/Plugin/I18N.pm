package Turnaround::Plugin::I18N;

use strict;
use warnings;

use Turnaround::I18N;

use base 'Turnaround::Plugin';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{lexicon} = $params{lexicon} || 'perl';

    $self->{service_name}             = $params{service_name};
    $self->{helper_name}              = $params{helper_name};
    $self->{insert_before_middleware} = $params{insert_before_middleware};

    $self->{service_name}             ||= 'i18n';
    $self->{helper_name}              ||= $self->{service_name};
    $self->{helper_name}              ||= $self->{service_name};
    $self->{insert_before_middleware} ||= 'RequestDispatcher';

    return $self;
}

sub startup {
    my $self = shift;

    my $app_class = $self->{app_class};
    $app_class =~ s{::}{/}g;

    my $path = $INC{"$app_class\.pm"};
    $path =~ s{\.pm$}{/I18N};

    my $locale_dir;
    my $lexicon;
    if (-d $path) {
        $locale_dir = $path;
        $lexicon    = 'perl';
    }
    elsif (-d $self->{home}->catfile('locale')) {
        $locale_dir = $self->{home}->catfile('locale');
        $lexicon    = 'gettext';
    }
    else {
        Carp::croak('Cannot detect locale_dir');
    }

    my $i18n = Turnaround::I18N->new(
        app_class  => $self->{app_class},
        locale_dir => $locale_dir,
        lexicon    => $lexicon
    );
    $self->{services}->register($self->{service_name} => $i18n);

    $self->{builder}
      ->insert_before_middleware($self->{insert_before_middleware},
        'I18N', i18n => $i18n);
}

1;
