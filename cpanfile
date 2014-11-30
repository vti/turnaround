requires 'Carp'                 => '0';
requires 'Cwd'                  => '0';
requires 'Encode'               => '0';
requires 'Exporter'             => '0';
requires 'File::Basename'       => '0';
requires 'File::Spec'           => '0';
requires 'I18N::LangTags::List' => '0';
requires 'List::Util'           => '0';
requires 'Locale::Maketext'     => '0';
requires 'Scalar::Util'         => '0';
requires 'Storable'             => '0';

requires 'Email::MIME'          => '0';
requires 'I18N::AcceptLanguage' => '0';
requires 'I18N::LangTags::List' => '0';
requires 'JSON'                 => '0';
requires 'Plack'                => '0';
requires 'Routes::Tiny'         => '0.009014';
requires 'String::CamelCase'    => '0';
requires 'YAML::Tiny'           => '0';

recommends 'Text::APL';
recommends 'Text::Caml';

on 'test' => sub {
    requires 'Test::Class'               => '0';
    requires 'Test::Fatal'               => '0';
    requires 'Test::More'                => '0';
    requires 'Test::MockObject::Extends' => '0';
    requires 'Test::MonkeyMock'          => '0';
};
