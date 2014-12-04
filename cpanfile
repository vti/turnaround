requires 'JSON'                 => '0';
requires 'Plack'                => '0';
requires 'Routes::Tiny'         => '0.14';
requires 'String::CamelCase'    => '0';

recommends 'Email::MIME';
recommends 'I18N::AcceptLanguage';
recommends 'Text::APL';
recommends 'YAML::Tiny';

on 'test' => sub {
    requires 'Text::Caml';

    requires 'Test::Requires';
    requires 'Test::Fatal'      => '0';
    requires 'Test::More'       => '0';
    requires 'Test::MonkeyMock' => '0';
};
