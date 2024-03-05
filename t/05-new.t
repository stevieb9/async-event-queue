use strict;
use warnings;

use Async::Event::Queue;
use Test::More;

my $no_cb_ok = eval { my $queue = Async::Event::Queue->new; 1; };
is $no_cb_ok, undef, "new() croaks if no callback supplied";
like $@, qr/requires a code ref/, "...and error is sane";

my $cb_nonref_ok = eval { my $queue = Async::Event::Queue->new([]); 1; };
is $cb_nonref_ok, undef, "new() croaks if callback isn't a coderef";
like $@, qr/requires a code ref/, "...and error is sane";

my $numprocs_int_ok = eval { my $queue = Async::Event::Queue->new(sub{}, 'aaa'); 1; };
is $numprocs_int_ok, undef, "new() croaks if \$num_procs isn't an int";
like $@, qr/requires an integer/, "...and error is sane";

done_testing();