use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect(4)->to_be_greater_than(1);
    expect(4)->to_be_greater_than(4);
    expect(4)->to_be_greater_than(5);
}
$tester->out_is(qw/
    1 0 0
/);

done_testing;

