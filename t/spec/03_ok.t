use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;

    expect(1)->ok();
    expect({})->ok();
    expect(0)->ok();

    expect(0)->to_not_be_ok();
    expect(0)->not_ok();
    expect(1)->not_ok();
}
$tester->out_is(
    qw(
        1 1 0
        1 1 0
    )
);

done_testing;

