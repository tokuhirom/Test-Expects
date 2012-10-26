use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

my $tester = test();
{
    package sandbox;
    use Test::Expects;

    # no arg
    expect(sub { die })->to_throw_exception;
    expect(sub { 1 })->to_throw_exception;
    # code arg
    expect(sub { die bless [], 'Foo' })->to_throw_exception(sub {
        expect($_)->to_be_a('Foo');
    });
    expect(sub { die bless [], 'Foo' })->to_throw_exception(sub {
        expect($_)->to_be_a('Bar');
    });
    # regexp arg
    expect(sub { die })->to_throw_exception(qr/hoge/);
    expect(sub { die 'hoge' })->to_throw_exception(qr/hoge/);

    # NOT ---------------------------------
    # no arg
    expect(sub { die })->to_not_throw_exception;
    expect(sub { 1 })->to_not_throw_exception;
}
$tester->out_is(qw/
    1 0
    1 0
    0 1

    0 1
/);

done_testing;

