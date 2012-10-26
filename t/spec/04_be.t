use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect(1)->to_be(1);
    expect(1)->to_be(0);

    expect(1E1)->to_equal(1E1);
    expect(1E1)->not_to_equal(1E1);

    expect(1)->not_to_be(0);
    expect(1)->not_to_be(1);

    expect('1')->to_not_be(0);
    expect('1')->to_not_be(1);
}
$tester->out_is(
    qw/
        1 0
        1 0
        1 0
        1 0
        /
);

done_testing;

