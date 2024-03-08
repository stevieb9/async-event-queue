package Async::Event::Queue;

use strict;
use warnings;

BEGIN { use IPC::Shareable; print IPC::Shareable::ipcs() . "\n"; }

use Async::Event::Interval;
use Carp qw(croak);
use Cwd qw(abs_path);
use Data::Dumper;
#use Script::Singleton warn => 1;

our $VERSION = '0.01';

my $queue_glue = abs_path((caller())[1]) . "_queue2";

tie my @queue, 'IPC::Shareable', {
    key     => $queue_glue,
    create  => 1,
    tidy    => 1,
    destroy => 1,
};

my @procs;

sub _core_cb {
    my (@procs) = @_;

    tie my @queue, 'IPC::Shareable', {
        key     => $queue_glue,
        create  => 0,
    };

    for my $proc (@procs) {
        if ($proc->waiting) {
            if (my $queue_item = shift @queue) {
                $proc->start($queue_item->[0]);
            }
        }
    }
}

sub new {
    my ($class, $callback, $num_procs) = @_;

    if (! defined $callback || ref $callback ne 'CODE') {
        croak "new() requires a code reference sent in";
    }

    my $self = bless {}, $class;

    $self->num_procs($num_procs // 2);
    $self->_cb($callback);

    $self->_procs_create;
    $self->_core_proc;

    $self->_core_proc->start;

    return $self;
}
sub waiting {
    my ($self) = @_;
    return $self->_core_proc->waiting;
}
sub _core_proc {
    my ($self) = @_;
    if (! $self->{core_proc}) {
        $self->{core_proc} = Async::Event::Interval->new(1, \&_core_cb, @procs);
    }
    return $self->{core_proc};
}
sub halt {
    my ($self) = @_;

    for my $proc (@procs) {
        $proc->stop;
    }

    $self->_core_proc->stop;
}
sub enqueue {
    my ($self, @data) = @_;
    push @queue, \@data;
}
sub num_procs {
    my ($self, $num_procs) = @_;

    if (defined $num_procs && $num_procs !~ /^\d+$/) {
        croak "num_procs() requires an integer number of processes to start";
    }

    if (! $self->{num_procs}) {
        $self->{num_procs} = $num_procs;
    }

    return $self->{num_procs};
}
sub queue_items {
    my ($self) = @_;
    return @queue;
}

sub _cb {
    my ($self, $cb) = @_;

    if (! $self->{cb}) {
        $self->{cb} = $cb;
    }

    return $self->{cb};
}
sub _proc_store {
    my ($self, $proc) = @_;

    if (! $proc || ref $proc ne 'Async::Event::Interval') {
        croak "_proc_store() must be sent in an object of Async::Event::Interval";
    }

    push @procs, $proc;
}
sub _procs_create {
    my ($self) = @_;

    for (1..$self->num_procs) {
        $self->_proc_store(
            Async::Event::Interval->new(0, $self->_cb)
        )
    }
}
    # Put all procs in a hash { id => $event }
    # When event is done, push to array (@{ $self->done })
    # When looping globally, shift $self->done, and start $event with next queue

sub __placeholder {}

1;
__END__

=head1 NAME

Async::Event::Queue - Queue manager for dispatching to Async::Event::Interval events

=for html
<a href="https://github.com/stevieb9/async-event-queue/actions"><img src="https://github.com/stevieb9/async-event-queue/workflows/CI/badge.svg"/></a>
<a href='https://coveralls.io/github/stevieb9/async-event-queue?branch=main'><img src='https://coveralls.io/repos/stevieb9/async-event-queue/badge.svg?branch=main&service=github' alt='Coverage Status' /></a>


=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 name

Description.

I<Parameters>:

    $bar

I<Mandatory, String>: The name of the thing with the guy and the place.

I<Returns>: C<0> upon success.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2024 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>
