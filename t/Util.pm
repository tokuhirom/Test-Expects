package t::Util;
use strict;
use warnings;
use utf8;
use parent qw/Exporter/;

our @EXPORT = qw/mkres test/;

sub test {
    my $out;
    my $builder = Test::Builder->create;
    $builder->output(\$out);
    $builder->failure_output(\my $err);
    $builder->todo_output(\my $todo);
    *Test::Expects::Impl::builder = sub { $builder };
    *Test::Expects::Impl::Not::builder = sub { $builder };
    return bless {out => \$out}, 't::Util::Tester'; 
}

sub mkres {
    my $i = 1;
    join('', map { ($_ ? 'ok' : 'not ok') . ' ' . $i++ . "\n" } @_)
}

{
    package t::Util::Tester;
    use Test::More;
    sub out_is {
        my $self = shift;
        is(${$self->{out}}, t::Util::mkres(@_));
    }
}

1;

