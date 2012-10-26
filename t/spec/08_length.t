use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect([])->to_have_length(0);
    expect([])->to_have_length(1);
    expect([1,2,3])->to_have_length(3);
    expect([1,2,3])->to_have_length(4);
}
$tester->out_is(qw/
    1 0
    1 0
/);

done_testing;

