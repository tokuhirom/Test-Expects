use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;
    expect([])->to->be->an('ARRAY');
    expect([])->to->be->a('ARRAY');
    expect([])->is_a('ARRAY');
    expect([])->is_a('HASH');

    expect(bless [], 'Foo')->to->be->an('Foo');
    expect(bless [], 'Foo')->to->be->an('Bar');
}
$tester->out_is(
    qw/
        1 1 1 0
        1 0
    /
);

done_testing;

