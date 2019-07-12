#!/usr/bin/perl

use warnings;
use strict;

my $inTSV = $ARGV[0];
my $inFASTA = $ARGV[1];

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


my $assignments = {};

open(TSV, '<', $inTSV) or die $!;
while (my $line = <TSV>) {
    chomp($line);
    my ($contig, $bin) = split(/\t/, $line);
    $assignments->{$contig} = $bin;
}
close(TSV);

my $bincnt = 1;
my $binnumber = {};

open(FASTA, '<', $inFASTA) or die $!;
_read_fasta_file(\*FASTA, sub {
    my ($desc, $sequence) = @_;

    my $binname = $assignments->{$desc};
    if (defined($binname)) {
        if (exists($binnumber->{$binname})) {
            $binname = "Bin." . $binnumber->{$binname};
        } else {
            $binnumber->{$binname} = $bincnt;
	    $binname = "Bin." . $binnumber->{$binname};
            $bincnt++;
        }
    } else {
        $binname = "Unbinned";
    }

    open(O, '>>', $binname . ".fas") or die $!;
    print O ">".$desc."\n".$sequence."\n";
    close(O);

});
close(FASTA);
