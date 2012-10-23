use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect({ a => 'b' })->to->have->key('a');
    expect({ a => 'b', c => 'd' })->to->only->have->keys('a', 'c');
    expect({ a => 'b', c => 'd' })->to->not->only->have->key('a');
}
$tester->out_is(qw/
    1
    1
    1
/);

done_testing;

