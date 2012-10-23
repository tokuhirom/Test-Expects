use strict;
use warnings;
use utf8;
use Test::More;
use Test::Expects;

my @items = get_items();
for (@items) {
    my ($title, $code) = @$_;
    note $title;
    eval $code;
    die $@ if $@;
}

done_testing;
exit;

sub get_items {
    open my $fh, '<', 'lib/Test/Expects.pm';
    my $src = do { local $/; <$fh> };
    my $block = ($src =~ /^=head1 VALIDATIONS\n\n=over 4(.+?)^=head1/ms)[0];
    $block or die;
    my @blocks = map { [split /\n/, $_, 2] } grep /\S/, split /^=item /m, $block;
    return @blocks;
}
