use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect([1, 2])->to_contain(1);
    expect([1, 2])->to_contain(0);
    expect('hello world')->to_contain('world');
    expect('hello world')->to_contain('kan');
}
$tester->out_is(qw/
    1 0
    1 0
/);

done_testing;

