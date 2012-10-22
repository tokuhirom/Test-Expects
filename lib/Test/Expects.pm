package Test::Expects;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

use parent qw/Exporter Test::Builder::Module/;

our $CLASS = __PACKAGE__;

our @EXPORT = qw/expect/;

sub expect($) {
    return Test::Expects->new(@_);
}

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

sub greater_than {
    my ($self, $stuff) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $builder = $CLASS->builder;
    $builder->ok($self->[0] > $stuff);
}

sub less_than {
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

sub ONLY() { Test::Expects::ONLY }

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

=head1 DESCRIPTION

Test::Expects is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

L<https://github.com/LearnBoost/expect.js>

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
