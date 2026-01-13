#!/usr/bin/env perl
# bin/app.psgi
use strict;
use warnings;
use Dancer2;
use ICTTicketingApp;

my $app = sub {
    my $env = shift;
    Dancer2->to_app('ICTTicketingApp')->($env);
};