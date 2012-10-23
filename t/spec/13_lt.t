use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect(4)->to_be_below(1);
    expect(4)->to_be_below(4);
    expect(4)->to_be_below(5);
}
$tester->out_is(qw/
    0 0 1
/);

done_testing;

