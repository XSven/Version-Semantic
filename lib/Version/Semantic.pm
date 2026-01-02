# Prefer numeric version for backwards compatibility
BEGIN { require 5.010_001 }; ## no critic ( RequireUseStrict, RequireUseWarnings )
use strict;
use warnings;

package Version::Semantic;

$Version::Semantic::VERSION = 'v1.0.0';

use overload '<=>' => 'compare_to';

sub _croakf ( $@ );

# - Allow optional "v" prefix
#   https://semver.org/spec/v2.0.0.html#is-v123-a-semantic-version
# - On purpose use "build" (the BNF symbol name) instead of "buildmetadata" as
#   the name of the last named capture group
sub _SEM_VER_REG_EX () {
  ## no critic ( ProhibitComplexRegexes )
  qr/
    \A
    v?
    (?<major> 0 | [1-9]\d* ) \. (?<minor> 0 | [1-9]\d* ) \.(?<patch> 0 | [1-9]\d* )
    (?: -  (?<pre_release> (?: 0 | [1-9]\d* | \d*[a-zA-Z-][0-9a-zA-Z-]* ) (?: \. (?: 0 | [1-9]\d* | \d*[a-zA-Z-][0-9a-zA-Z-]* ) )* ) )?
    (?: \+ (?<build> [0-9a-zA-Z-]+ (?: \. [0-9a-zA-Z-]+ )* ) )?
    \z
  /x
}

# Use BNF terminology
# https://semver.org/spec/v2.0.0.html#backusnaur-form-grammar-for-valid-semver-versions
sub major       { shift->{ major } }
sub minor       { shift->{ minor } }
sub patch       { shift->{ patch } }
sub pre_release { shift->{ pre_release } }
sub build       { shift->{ build } }

sub parse {
  my ( $class, $version ) = @_;

  $version =~ m/${ \( _SEM_VER_REG_EX ) }/x
    or _croakf "Version '%s' is not a semantic version", $version;

  bless { %+ }, $class
}

# https://semver.org/spec/v2.0.0.html#spec-item-11
sub compare_to {
  my ( $self, $other ) = @_;

  return $self->major <=> $other->major if $self->major != $other->major;
  return $self->minor <=> $other->minor if $self->minor != $other->minor;
  return $self->patch <=> $other->patch if $self->patch != $other->patch;
  $self->_compare_pre_release( $other )
}

# TODO: Implement pre_release comparison
sub _compare_pre_release {
  my ( $self, $other ) = @_;

  my $a_pre_release = $self->pre_release;
  my $b_pre_release = $other->pre_release;

  return -1 if defined $a_pre_release     and not defined $b_pre_release;
  return 1  if not defined $a_pre_release and defined $b_pre_release;

}

sub _croakf ( $@ ) {
  # Load Carp lazily
  require Carp;
  @_ = ( ( @_ == 1 ? shift : sprintf shift, @_ ) . ', stopped' );
  goto &Carp::croak
}

1
