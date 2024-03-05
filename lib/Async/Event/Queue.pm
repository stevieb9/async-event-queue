package Async::Event::Queue;

use strict;
use warnings;

use Async::Event::Interval;
use Carp qw(croak);

our $VERSION = '0.01';

sub new {
    my ($class, $callback, $num_procs) = @_;

    $num_procs //= 4;

    if (! defined $callback || ref $callback ne 'CODE') {
        croak "new() requires a code reference sent in";
    }

    my $self = bless {}, $class;

    $self->num_procs($num_procs);
    $self->_cb($callback);

    return $self;
}
sub enqueue {
    my ($self, @data) = @_;
    push @{ $self->{queue} }, \@data;
}
sub dequeue {
    my ($self) = @_;
    return shift @{ $self->{queue} };
}
sub num_procs {
    my ($self, $num_procs) = @_;

    if (! defined $num_procs || $num_procs !~ /^\d+$/) {
        croak "num_procs() requires an integer number of processes to start";
    }

    if (! $self->{num_procs}) {
        $self->{num_procs} = $num_procs;
    }

    return $self->{num_procs};
}
sub queue {
    my ($self) = @_;
    return $self->{queue};
}

sub _cb {
    my ($self, $cb) = @_;

    if (! $self->{cb}) {
        $self->{cb} = $cb;
    }

    return $self->{cb};
}
sub _procs_create {
    my ($self) = @_;
}

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
