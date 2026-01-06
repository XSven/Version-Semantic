use strict;
use warnings;

use Test::More import => [ qw( BAIL_OUT require_ok ) ], tests => 2;
use Test::API import => [ qw( public_ok ) ];

my $class;

BEGIN {
  $class = 'Version::Semantic';
  require_ok $class or BAIL_OUT "Cannot load class '$class'!"
}

public_ok $class, qw( parse major minor patch pre_release build core is_released compare_to )
