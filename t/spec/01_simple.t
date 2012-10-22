use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Data::Dumper;

my $tester = test();
{
    package sandbox;
    use Test::Expects;

    expect(5963)->equals(5963);
    expect(4649)->equals(5963);
    expect(4649)->to_be(4649);
    expect(4649)->is(4649);
}

$tester->out_is(
    qw/1 0 1 1/
);
done_testing;

