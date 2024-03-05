use strict;
use warnings;

use Async::Event::Queue;
use Data::Dumper;
use Test::More;

my $q = Async::Event::Queue->new(sub {});

$q->enqueue(0, 1, 2);
$q->enqueue(3, 4, 5);

my $queue = $q->queue;

is ref $queue, 'ARRAY', "queue() returns an aref ok";
is ref $queue->[0], 'ARRAY', "queue() entry 0 is aref ok";
is ref $queue->[1], 'ARRAY', "queue() entry 1 is aref ok";

for (0..2) {
    is $queue->[0][$_], $_, "value of queue 0 elem $_ is $_ ok";

    my $inc = $_;
    $inc += 3;

    is $queue->[1][$_], $inc, "value of queue 1 elem $_ is $inc ok";
}

done_testing();
