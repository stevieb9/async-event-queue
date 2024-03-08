use strict;
use warnings;

use Async::Event::Queue;
use Test::More;

my $mod = 'Async::Event::Queue';

{
    my $q = $mod->new(\&cb);

    sub cb {
        print "hey there!\n";
        my ($item) = @_;
        print "$$: $item\n";
    }

    my $i = 0;
    for (0..50) {
        select(undef, undef, undef, 0.5);
        $q->enqueue($_);
        while (! $q->waiting) {}
    }
    $q->halt;
}

done_testing();

print IPC::Shareable::ipcs() . "\n";
