#!/usr/bin/perl

use warnings;
use strict;

my $inFASTA = $ARGV[0];
my $outFASTA = $ARGV[1];

# helper method to read a fasta file sequence by sequence
sub _read_fasta_file {
    my ($fh, $callback) = @_;
    
    next unless ref($callback);

    my $name;
    my $sequence;
    
    while (<$fh>) {
        chomp;
        # remove ^M's..
        s/\015//g;
        if (/^>(\w+)/) {
            if ($name) {
                &$callback($name, $sequence);
            }
            $name = $1;
            $sequence = "";
        }
        else {
            $sequence .= $_;
        }
    }
    if ($name) {
        &$callback($name, $sequence);
    }
}


my $cnt=0;

open(FASTA, '<', $inFASTA) or die $!;
open(O, '>', $outFASTA) or die $!;

_read_fasta_file(\*FASTA, sub {
    my ($desc, $sequence) = @_;

    $cnt++;
    print O ">MGX_contig_".$cnt."\n".$sequence."\n";

});

close(O);
close(FASTA);
