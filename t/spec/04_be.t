use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect(1)->to->be(1);
    expect(1)->to->be(0);

    expect(1E1)->to->equal(1E1);
    expect(1E1)->not->to->equal(1E1);

    expect(1)->not->to->be(0);
    expect(1)->not->to->be(1);

    expect('1')->to->not->be(0);
    expect('1')->to->not->be(1);
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

