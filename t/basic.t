use strict;
use warnings;

use Test::More import => [ qw( BAIL_OUT is isa_ok like ok plan require_ok subtest ) ], tests => 8;
use Test::Fatal qw( dies_ok exception lives_ok );
my $class;

BEGIN {
  $class = 'Version::Semantic';
  require_ok $class or BAIL_OUT "Cannot load class '$class'!"
}

like exception { $class->parse( '1.0.0-alpha_beta' ) }, qr/is not a semantic version/, 'Invalid semantic version';
like exception { $class->parse( '1.0.0_01' ) }, qr/is not a semantic version/,
  'Perl underscore syntax does not refer to a semantic version';

subtest 'Invalid semantic version' => sub {
  plan tests => 39;

  my @versions = qw(
    1.2
    1.2.3-0123
    1.2.3-0123.0123
    1.1.2+.123
    +invalid
    -invalid
    -invalid+invalid
    -invalid.01
    alpha
    alpha.beta
    alpha.beta.1
    alpha.1
    alpha+beta
    alpha_beta
    alpha.
    alpha..
    beta
    1.0.0-alpha_beta
    -alpha.
    1.0.0-alpha..
    1.0.0-alpha..1
    1.0.0-alpha...1
    1.0.0-alpha....1
    1.0.0-alpha.....1
    1.0.0-alpha......1
    1.0.0-alpha.......1
    01.1.1
    1.01.1
    1.1.01
    1.2
    1.2.3.DEV
    1.2-SNAPSHOT
    1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788
    1.2-RC-SNAPSHOT
    -1.0.3-gamma+b7718
    +justmeta
    9.8.7+meta+meta
    9.8.7-whatever+meta+meta
    99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12
  );
  dies_ok { $class->parse( $_ ) } "$_" for @versions
};

subtest 'Valid semantic versions' => sub {
  plan tests => 31;

  my @versions = qw(
    0.0.4
    1.2.3
    10.20.30
    1.1.2-prerelease+meta
    1.1.2+meta
    1.1.2+meta-valid
    1.0.0-alpha
    1.0.0-beta
    1.0.0-alpha.beta
    1.0.0-alpha.beta.1
    1.0.0-alpha.1
    1.0.0-alpha0.valid
    1.0.0-alpha.0valid
    1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay
    1.0.0-rc.1+build.1
    2.0.0-rc.1+build.123
    1.2.3-beta
    10.2.3-DEV-SNAPSHOT
    1.2.3-SNAPSHOT-123
    1.0.0
    2.0.0
    1.1.7
    2.0.0+build.1848
    2.0.1-alpha.1227
    1.0.0-alpha+beta
    1.2.3----RC-SNAPSHOT.12.9.1--.12+788
    1.2.3----R-S.12.9.1--.12+meta
    1.2.3----RC-SNAPSHOT.12.9.1--.12
    1.0.0+0.build.1-rc.10000aaa-kk-0.1
    99999999999999999999999.999999999999999999.99999999999999999
    1.0.0-0A.is.legal
  );
  lives_ok { $class->parse( $_ ) } "$_" for @versions
};

subtest 'Test named capture group accessors' => sub {
  plan tests => 8;

  isa_ok my $self = $class->parse( '1.2.3-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay' ), $class;
  is $self->major,       1,                           'major';
  is $self->minor,       2,                           'minor';
  is $self->patch,       3,                           'patch';
  is $self->core,        '1.2.3',                     'core';
  is $self->pre_release, 'alpha-a.b-c-somethinglong', 'pre_release';
  ok not( $self->is_released ), 'Is not a release';
  is $self->build, 'build.1-aef.1-its-okay', 'build'
};

subtest 'Test named capture group accessors: "v" prefixed semantic version' => sub {
  plan tests => 8;

  isa_ok my $self = $class->parse( 'v0.0.4' ), $class;
  is $self->major, 0,       'major';
  is $self->minor, 0,       'minor';
  is $self->patch, 4,       'patch';
  is $self->core,  '0.0.4', 'core';
  ok not( defined $self->pre_release ), 'pre_release is not defined';
  ok $self->is_released,                'Is a release';
  ok not( defined $self->build ),       'build is not defined'
};

subtest 'Test named capture group accessors: "-TRIAL\d*" pre-releases' => sub {
  plan tests => 22;

  my $expected_pre_release = 'TRIAL';
  isa_ok my $self = $class->parse( "1.0.5-$expected_pre_release" ), $class;
  is $self->major,       1,                     'major';
  is $self->minor,       0,                     'minor';
  is $self->patch,       5,                     'patch';
  is $self->core,        '1.0.5',               'core';
  is $self->pre_release, $expected_pre_release, "pre_release: $expected_pre_release";
  ok not( $self->is_released ),   'Is not a release';
  ok not( defined $self->build ), 'build is not defined';

  for ( 0 .. 13 ) {
    $expected_pre_release = "TRIAL$_";
    $self                 = $class->parse( "1.2.3-$expected_pre_release" );
    is $self->pre_release, $expected_pre_release, "pre_release: $expected_pre_release"
  }
}
