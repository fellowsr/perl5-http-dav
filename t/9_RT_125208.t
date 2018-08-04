#!/usr/bin/env perl
#
# RT #125208, Local file naming differences with PUT between linux and windows
#

use strict;
use warnings;
use Test::More;
use lib 't';
use TestDetails
  qw($test_user $test_pass $test_url do_test fail_tests test_callback);

use File::Path ();

# Test 1
use_ok('HTTP::DAV');
my $dav=HTTP::DAV->new();
HTTP::DAV::DebugLevel(3);

note "user $test_user";
note "pass $test_pass";
note "url  $test_url";

$dav->credentials( $test_user,$test_pass,$test_url );
ok( $dav->open(-url => $test_url ), "Opened") || diag $dav->message;

my $collection = $test_url;
$collection=~ s#/$##g; # Remove trailing slash. We'll put it on.

# Test 2
ok(
  $dav->put( -local => "t/9_RT_125208.t", -url => $collection),
  "File without any local spaces putted"
) || diag explain "Put failed ", $dav->message(), $dav->errors();

# Test 3
ok(
  $dav->delete( -url => "$collection/9_RT_125208.t"),
  "File without any local spaces deleted"
) || diag explain "Put failed ", $dav->message(), $dav->errors();

ok(-d "t/test_data", "Test data directory exists" ) ;
ok(-e "t/test_data/RT 125208.txt", "Test file exists");

ok(
  $dav->put( -local => "t/test_data/RT 125208.txt" , -url => $collection ),
  "Putting spaced file"
) || diag explain "Spaced put failed ", $dav->message(), $dav->errors();

done_testing;
