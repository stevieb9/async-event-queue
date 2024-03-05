#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Async::Event::Queue' ) || print "Bail out!\n";
}

diag( "Testing Async::Event::Queue $Async::Event::Queue::VERSION, Perl $], $^X" );
