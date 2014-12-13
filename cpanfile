requires 'Plack';
requires 'Routes::Tiny' => '0.14';
requires 'String::CamelCase';

recommends 'Email::MIME';
recommends 'I18N::AcceptLanguage';
recommends 'JSON';
recommends 'Text::APL';
recommends 'YAML::Tiny';

on 'test' => sub {
    requires 'Text::Caml';

    requires 'Test::Requires';
    requires 'Test::Fatal';
    requires 'Test::More';
    requires 'Test::MonkeyMock';
};
