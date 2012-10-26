use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect([])->to_be_an('ARRAY');
    expect([])->to_be_a('ARRAY');
    expect([])->is_a('ARRAY');
    expect([])->is_a('HASH');

    expect(bless [], 'Foo')->to_be_an('Foo');
    expect(bless [], 'Foo')->to_be_an('Bar');
}
$tester->out_is(
    qw/
        1 1 1 0
        1 0
    /
);

done_testing;

