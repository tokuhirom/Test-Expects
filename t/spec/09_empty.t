use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect([])->to_be_empty();
    expect([])->to_not_be_empty();
    expect({})->to_be_empty();
    expect({})->to_not_be_empty();
    expect({ length => 0, duck => 'typing' })->to_be_empty();
    expect({ my => 'object' })->to_not_be_empty();
    expect([1,2,3])->to_not_be_empty();
    expect([1,2,3])->to_be_empty();
}
$tester->out_is(qw/
    1 0
    1 0
    0 1
    1 0
/);

done_testing;

