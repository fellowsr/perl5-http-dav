#!/usr/bin/env perl
#
# RT #125208, Local file naming differences with PUT between linux and windows
# (and get?)

use strict;
use warnings;
use Test::More tests => 11;
use lib 't';
use TestDetails
  qw($test_user $test_pass $test_url do_test fail_tests test_callback);


# Test 1
use_ok('HTTP::DAV');

my $dav=HTTP::DAV->new();
HTTP::DAV::DebugLevel(3);

note "user $test_user";
note "pass $test_pass";
note "url  $test_url";

$dav->credentials( $test_user,$test_pass,$test_url );
#2
ok( $dav->open(-url => $test_url ), "Opened") || diag $dav->message;

my $collection = $test_url;
$collection=~ s#/$##g; # Remove trailing slash. We'll put it on.


# Normal operation, filenames with no spaces
# Test 2
subtest "Normal operation, no spaces" => sub {
  plan tests => 2;
  ok(
    $dav->put( -local => "t/9_RT_125208.t", -url => $collection),
    "File without any local spaces putted"
  ) || diag explain "Put failed ",$dav->message(), " ", $dav->errors();

  ok(
    $dav->delete( -url => "$collection/9_RT_125208.t"),
    "File without any local spaces deleted"
  ) || diag explain "Put failed ", $dav->message(), " ", $dav->errors();
  done_testing();
};

ok(
  -d "t/test_data",
  "test_data directory exists"
) ;
ok(
  -e "t/test_data/RT 125208.txt",
  "Test file exists, dbl quotes"
);
#6
ok(
  -e 't/test_data/RT 125208.txt',
  "Test file exists, single quotes"
);
#7
ok(
  ! -e 't/test_data/RT',
  "Firstpart of test file does not exist"
);
# dbl quotes with no backslashes
my $sample= "t/test_data/RT 125208.txt";
{
  $sample =~ s#\ #\\ #g;
  my @globs=glob($sample);
  note "Files = ",join("|",@globs);
  #8
  is( scalar(@globs),1,"Got a single filename");
}
# single quoted with no backslashes
$sample= 't/test_data/RT 125208.txt';
{
  $sample =~ s#\ #\\ #g;
  my @globs=glob($sample);
  note join("|",@globs);
  is( scalar(@globs),1,"Got a single filename");
}
# wrapped in dbl quotes, as per patch from reporter
$sample= '"t/test_data/RT 125208.txt"';
{
  $sample =~ s#\ #\\ #g;
  my @globs=glob($sample);
  note join("|",@globs);
  is( scalar(@globs),1,"Got a single filename");
}

BAIL_OUT( "need a smarter RE to match \\'s");

ok(
  $dav->put( -local => "t/test_data/RT\ 125208.txt" , -url => $collection ),
  "Putting spaced file"
) || diag explain "Spaced put failed ", $dav->message()," ", $dav->errors();

done_testing;
