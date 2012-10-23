# NAME

Test::Expects - Expects...

# SYNOPSIS

    use Test::Expects;
    use Test::More;

    expect($foo)->is(4);

# DESCRIPTION

Test::Expects is a RSpec-ish testing library. It is inspired from expect.js

# VALIDATIONS

- ok() - asserts that the value is truthy or not

    expect(1)->to_be_ok();
    expect(1)->to_be_ok();
    expect(0)->to_not_be_ok();
- is / be: asserts 'eq' equality

    expect(1)->is(1);
    expect(1)->is('1');
    expect(1)->not_to_be(0);
- a/an: asserts is-a

    use Data::Dumper;
    expect(Data::Dumper->new([]))->is_a('Data::Dumper');
- match: asserts String regular expression match

    expect('0.0.5')->to_match(qr/^[0-9]+\.[0-9]+\.[0-9]+$/);
- contain: asserts indexOf for an array or string

    expect([1, 2])->to_contain(1);
    expect('hello world')->to_contain('world');
- length: asserts array length

    expect([])->to_have_length(0);
    expect([1,2,3])->to_have_length(3);
- empty: asserts that an array is empty or not

    expect([])->to_be_empty();
    expect({})->to_be_empty();
    expect({ my => 'object' })->to_not_be_empty();
    expect([1,2,3])->to_not_be_empty();
- key/keys: asserts the presence of a key. Supports the only modifier

    expect({ a=> 'b' })->to_have_key('a');
    expect({ a=> 'b', c=> 'd' })->to_only_have_keys('a', 'c');
    expect({ a=> 'b', c=> 'd' })->to_not_only_have_key('a');
- throw\_exception : asserts that the coderef throws or not when called

    expect(sub { die })->to_throw_exception();
    expect(sub { die bless [], 'MyExc' })
        ->to_throw_exception(sub { # get $@
            my $e = shift;
            expect($e)->is_a('MyExc');
    });
    expect(sub { die "Bad foo" })->to_throw_exception(qr/foo/);
    expect(sub { 1; })->to_not_throw_exception();
- above: asserts >

    expect(3)->to_be_above(0);
- below: asserts <

    expect(0)->to_be_below(3);

# AUTHOR

Tokuhiro Matsuno <tokuhirom AAJKLFJEF@ GMAIL COM>

# SEE ALSO

[https://github.com/LearnBoost/expect.js](https://github.com/LearnBoost/expect.js)

# LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
