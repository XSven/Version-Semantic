use strict;
use warnings;

use Test::More import => [ qw( $TODO BAIL_OUT ok plan require_ok subtest ) ], tests => 3;
my $class;

BEGIN {
  $class = 'Version::Semantic';
  require_ok $class or BAIL_OUT "Cannot load class '$class'!"
}

subtest '11.2' => sub {
  plan tests => 3;

  my @versions = ( '1.0.0', '2.0.0', '2.1.0', '2.1.1' );
  for ( my $i = 0 ; $i < $#versions ; ++$i ) {
    ok $class->parse( $versions[ $i ] ) < $class->parse( $versions[ $i + 1 ] ), "$versions[ $i ] < $versions[ $i + 1 ]"
  }
};

subtest '11.3' => sub {
  plan tests => 2;

  ok $class->parse( '1.0.0-alpha' ) < $class->parse( '1.0.0' ), '1.0.0-alpha < 1.0.0';
  ok $class->parse( '1.0.0' ) > $class->parse( '1.0.0-alpha' ), '1.0.0 > 1.0.0-alpha'
}
