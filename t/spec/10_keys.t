use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect({ a => 'b' })->to_have_key('a');
    expect({ a => 'b', c => 'd' })->to_only_have_keys('a', 'c');
    expect({ a => 'b', c => 'd' })->to_not_only_have_key('a');
}
$tester->out_is(qw/
    1
    1
    1
/);

done_testing;

