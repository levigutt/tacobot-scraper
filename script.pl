#!/usr/bin/perl -wl
use strict;
use Firefox::Marionette;
use Data::Printer;

our %profiles;
sub done
{
    print for keys %profiles;
}

# ensure output even when closed with Ctrl+C or kill
$SIG{TERM} = \&done;
$SIG{INT} = \&done;


my $m = Firefox::Marionette->new(visible => 1);
$m->go('https://tacobot.tf/leaderboard');
sleep 3; # wait for page to load

my $expected_count = $m->find_selector('[aria-rowcount]')->attribute('aria-rowcount');
$expected_count--; # dont count header row
warn "expected count: $expected_count\n";

my @elems;
while(1)
{
    # get profiles and add to list
    my @elems = $m->find_selector('.public-table-player-mini-card a');
    $profiles{$_->attribute('href')}++ for @elems;
    warn "current count ", scalar keys %profiles, "\n";

    # stop when expected count is reached
    last if $expected_count == scalar keys %profiles;

    # scroll down and wait for elements to load
    $m->scroll($elems[-1], { block => 'start', inline => 'nearest' });
    sleep 1;
}

done();

