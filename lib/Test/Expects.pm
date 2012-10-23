package Test::Expects;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

use parent qw/Exporter/;

our @EXPORT = qw/expect/;

sub expect($) {
    return Test::Expects::Impl->new(@_);
}

package # hide from pause
    Test::Expects::Impl;

use parent qw/Test::Builder::Module/;

our $CLASS = __PACKAGE__;

use Carp ();
use Try::Tiny;

use constant {
    ONLY => 1,
};

sub new {
    my $class = shift;
    @_==1 or Carp::croak("Too much args");
    bless [$_[0]], $class;
}

sub equal {
    my $self = shift;
    my $expect = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->is_eq($self->[0], $expect);
}
sub is { goto &equal }
sub equals { goto &equal }

# expect(1).to.be.ok();
# expect(true).to.be.ok();
# expect({}).to.be.ok();
# expect(0).to.not.be.ok();
sub ok {
    my $self = shift;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok($self->[0]);
}

sub fail {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->fail();
}

sub to {
    my $self = shift;
    $self;
}

sub be {
    my $self = shift;
    if (@_) {
        $self->equal(@_);
    } else {
        $self;
    }
}

sub have {
    my $self = shift;
    $self;
}

sub not: method {
    my $self = shift;
    return Test::Expects::Impl::Not->new($self->[0]);
}

sub empty {
    my $self = shift;
    if (ref $self->[0] eq 'ARRAY') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->is_eq(0+@{$self->[0]}, 0);
    } elsif (ref $self->[0] eq 'HASH') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->is_eq(0+keys(%{$self->[0]}), 0);
    } else {
        Carp::croak("You cannot check 'empty' with this type...");
    }
}

sub length :method {
    my ($self, $len) = @_;
    if (ref $self->[0] eq 'ARRAY') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->is_eq(0+@{$self->[0]}, $len);
    } else {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->is_eq(CORE::length($self->[0]), $len);
    }
}

# expect(5).to.be.a('number');
# expect(5).is_a('number');
sub a {
    my ($self, $type) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok(UNIVERSAL::isa($self->[0], $type));
}
sub is_a { goto &a }
sub an { goto &a }

sub match {
    my ($self, $regexp) = @_;
    Carp::croak("Missing regexp for match. You man passed // instead of qr//?") unless defined $regexp;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->like($self->[0], $regexp);
}

sub only {
    my $self = shift;
    @_==0 or Carp::croak();

    $self->[ONLY()]++;
    $self;
}

sub key {
    my ($self, $key) = (shift, shift);
    Carp::croak("Invalid arguments for key") if @_;
    Carp::croak("Invalid arguments for key") if not defined $key;

    if (ref $self->[0] eq 'HASH') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(!!exists($self->[0]->{$key}));
    } else {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(0, "This is not a hash.");
    }
}

sub keys {
    my ($self, @key) = (shift, @_);
    Carp::croak("You may forgot 'only'?") unless $self->[ONLY];

    if (ref $self->[0] eq 'HASH') {
        my %copy = %{$self->[0]};
        for (@key) {
            delete $copy{$_};
        }
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(keys %copy == 0);
    } else {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(0, "This is not a hash.");
    }
}

# expect([1, 2]).to.contain(1);
# expect('hello world').to.contain('world');
sub contain {
    my ($self, $stuff) = @_;
    if (ref $self->[0] eq 'ARRAY') {
        my $test = sub {
            for my $m (@{$self->[0]}) {
                return 1 if $m eq $stuff;
            }
            return 0;
        }->();
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok($test);
    } else {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(index($self->[0], $stuff)>=0);
    }
}

sub throw_exception {
    my $self = shift;
    if (@_) {
        if (ref $_[0] eq 'Regexp') {
            my $re = shift;
            my $err;
            try {
                $self->[0]->();
            } catch {
                $err++;
                local $Test::Builder::Level = $Test::Builder::Level + 1;
                my $builder = $CLASS->builder;
                $builder->like($_, $re);
            };
            unless ($err) {
                local $Test::Builder::Level = $Test::Builder::Level + 1;
                my $builder = $CLASS->builder;
                $builder->fail("Don't throws");
            }
        } elsif (ref $_[0] eq 'CODE') {
            my $code = shift;
            my $err;
            try {
                $self->[0]->();
            } catch {
                $err++;
                $code->($_);
            };
            unless ($err) {
                local $Test::Builder::Level = $Test::Builder::Level + 1;
                my $builder = $CLASS->builder;
                $builder->fail("Don't throws");
            }
        } else {
            Carp::croak "Unknown : " . ref $_[0];
        }
    } else {
        my $err;
        try {
            $self->[0]->();
        } catch {
            $err++;
        };
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok($err);
    }
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*:://g;
    if ($AUTOLOAD =~ s/^(to|have|be|not|only)_//) {
        my $meth = $1;
        my $auto = $AUTOLOAD;
        $self->$meth->$auto(@_);
    } else {
        Carp::croak("Unknown method: $AUTOLOAD");
    }
}

sub above {
    my ($self, $stuff) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok($self->[0] > $stuff);
}

sub below {
    my ($self, $stuff) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok($self->[0] < $stuff);
}

sub DESTROY { }

package # hide from pause
    Test::Expects::Impl::Not;

use parent qw/Test::Builder::Module/;

our $CLASS = __PACKAGE__;

use Try::Tiny;

sub ONLY() { Test::Expects::Impl::ONLY }

sub new {
    my $class = shift;
    bless [@_], $class;
}

sub DESTROY { }

sub be {
    my $self = shift;
    if (@_) {
        $self->equal(@_);
    } else {
        $self;
    }
}

sub have {
    my $self = shift;
    $self;
}

sub to {
    my $self = shift;
    $self;
}

sub ok {
    my $self = shift;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok(!$self->[0]);
}

sub only {
    my $self = shift;
    @_==0 or Carp::croak();

    $self->[ONLY()]++;
    $self;
}

sub equal {
    my $self = shift;
    my $expect = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->isnt_eq($self->[0], $expect);
}

sub match {
    my ($self, $regexp) = @_;
    Carp::croak("Missing regexp for match. You man passed // instead of qr//?") unless defined $regexp;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->unlike($self->[0], $regexp);
}

sub empty {
    my $self = shift;
    if (ref $self->[0] eq 'ARRAY') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->isnt_eq(0+@{$self->[0]}, 0);
    } elsif (ref $self->[0] eq 'HASH') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->isnt_eq(0+keys(%{$self->[0]}), 0);
    } else {
        Carp::croak("You cannot check 'empty' with this type...");
    }
}

sub key {
    my ($self, $key) = (shift, shift);
    Carp::croak("You may forgot 'only'?") unless $self->[ONLY];

    if (ref $self->[0] eq 'HASH') {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(not exists $self->[0]->{$key});
    } else {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(0, "This is not a hash.");
    }
}

sub throw_exception {
    my $self = shift;
    if (@_) {
        Carp::croak("Invalid method calling. You cannot call not->throw_exception with arguments");
    } else {
        my $err;
        try {
            $self->[0]->();
        } catch {
            $err++;
        };
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my $builder = $CLASS->builder;
        $builder->ok(!$err);
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Expects - Expects...

=head1 SYNOPSIS

    use Test::Expects;
    use Test::More;

    expect($foo)->is(4);

=head1 DESCRIPTION

Test::Expects is a RSpec-ish testing library. It is inspired from expect.js

=head1 VALIDATIONS

=over 4

=item ok() - asserts that the value is truthy or not

    expect(1)->to_be_ok();
    expect(1)->to_be_ok();
    expect(0)->to_not_be_ok();

=item be / equal: asserts 'eq' equality

    expect(1)->is(1)
    expect(1)->is('1')
    expect(1)->not_to_be(0)

=item a/an: asserts is-a

    use Data::Dumper;
    expect(Data::Dumper->new([]))->is_a('Data::Dumper');

=item match: asserts String regular expression match

    expect('0.0.5')->to_match(/^[0-9]+\.[0-9]+\.[0-9]+$/);

=item contain: asserts indexOf for an array or string

    expect([1, 2])->to_contain(1);
    expect('hello world')->to_contain('world');

=item length: asserts array length

    expect([])->to_have_length(0);
    expect([1,2,3])->to_have_length(3);

=item empty: asserts that an array is empty or not

    expect([])->to_be_empty();
    expect({})->to_be_empty();
    expect({ length => 0, duck => 'typing' })->to_be_empty();
    expect({ my => 'object' })->to_not_be_empty();
    expect([1,2,3])->to_not_be_empty();

=item key/keys: asserts the presence of a key. Supports the only modifier

    expect({ a=> 'b' })->to_have_key('a');
    expect({ a=> 'b', c=> 'd' })->to_only_have_keys('a', 'c');
    expect({ a=> 'b', c=> 'd' })->to_only_have_keys(['a', 'c']);
    expect({ a=> 'b', c=> 'd' })->to_not_only_have_key('a');

=item throw_exception : asserts that the coderef throws or not when called

    expect(sub { die })->to_throw_exception();
    expect(sub { die bless [], 'MyExc' })
        ->to_throw_exception(sub { # get $@
            my $e = shift;
            expect($e)->is_a('MyExc');
    });
    expect(sub { die "Bad foo" })->to_throw_exception(qr/foo/);
    expect(sub { 1; })->to_not_throw_exception();

=item above: asserts >

    expect(3)->to_be_above(0);

=item below: asserts <

    expect(0)->to_be_below(3);

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

L<https://github.com/LearnBoost/expect.js>

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
