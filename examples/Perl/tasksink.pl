#!/usr/bin/perl
=pod

Task sink

Binds PULL socket to tcp://localhost:5558

Collects results from workers via that socket

Author: Daisuke Maki (lestrrat)
Original version Author: Alexander D'Archangel (darksuji) <darksuji(at)gmail(dot)com>

=cut

use strict;
use warnings;
use 5.10.0;

use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PULL);
use Time::HiRes qw/time/;
use English qw/-no_match_vars/;
use zhelpers;

use constant MSECS_PER_SEC => 1000;

local $| = 1;

# Prepare our context and socket
my $context = zmq_init();
my $receiver = zmq_socket($context, ZMQ_PULL);
zmq_bind($receiver, 'tcp://*:5558');

# Wait for start of batch
s_recv($receiver);

# Start our clock now
my $tstart = time;

# Process 100 confirmations
for my $task_nbr (0 .. 99) {
    s_recv($receiver);
    use integer;
    if (($task_nbr / 10) * 10 == $task_nbr) {
        print ':';
    } else {
        print '.';
    }
}
# Calculate and report duration of batch
my $tend = time;

my $tdiff = $tend - $tstart;
my $total_msec = $tdiff * MSECS_PER_SEC;
say "Total elapsed time: $total_msec msec";
