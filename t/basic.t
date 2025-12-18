use strict;
use warnings;

use Test::More import => [ qw( BAIL_OUT is isa_ok like ok plan require_ok subtest ) ], tests => 3;
use Test::Fatal qw( exception );
my $class;

BEGIN {
  $class = 'Version::Semantic';
  require_ok $class or BAIL_OUT "Cannot load class '$class'!"
}

like exception { $class->parse( '1.0.0-alpha_beta' ) }, qr/is not a semantic version/, 'Invalid semantic version';

subtest 'Test named capture group accessors' => sub {
  plan tests => 12;

  isa_ok my $self = $class->parse( '1.2.3-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay' ), $class;
  is $self->major,       1,                           'major';
  is $self->minor,       2,                           'minor';
  is $self->patch,       3,                           'patch';
  is $self->pre_release, 'alpha-a.b-c-somethinglong', 'pre_release';
  is $self->build,       'build.1-aef.1-its-okay',    'build';

  # Use a "v" prefixed semantic version
  isa_ok $self = $class->parse( 'v0.0.4' ), $class;
  is $self->major, 0, 'major';
  is $self->minor, 0, 'minor';
  is $self->patch, 4, 'patch';
  ok not( defined $self->pre_release ), 'pre_release is not defined'; ## no critic ( RequireTestLabels )
  ok not( defined $self->build ), 'build is not defined' ## no critic ( RequireTestLabels )
}
