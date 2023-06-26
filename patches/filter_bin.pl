#!/usr/bin/env perl

use strict;
use warnings;

# filter binning result by minimum size in bp; used to postprocess
# vamb output, which places unbinned contigs into separate bins,
# thus producing thousands of single-contig bins

my $fasta = shift @ARGV;
my $bintsv = shift @ARGV;
my $minsize = int(shift @ARGV);
my $outtsv = shift @ARGV;

open(F, $fasta) or die "Cannot read $fasta\n";
my $contigSizes = {};

_read_fasta_file(\*F,
                sub {
                    my ($name, $seq) = @_;
                    $contigSizes->{$name} = length($seq);
                }
                ); 
close(F);

open(TSV, $bintsv) or die;
my $binSizes = {};
while (my $line = <TSV>) {
    chomp($line);
    my ($contig, $bin) = split(/\t/, $line);
    die "No length information for $contig\n" unless defined($contigSizes->{$contig});
    if (exists($binSizes->{$bin})) {
        $binSizes->{$bin} += $contigSizes->{$contig};
    } else {
        $binSizes->{$bin} = $contigSizes->{$contig};
    }
}
close(TSV);

open(TSV, $bintsv) or die;
open(OUT, '>', $outtsv) or die;
while (my $line = <TSV>) {
    chomp($line);
    my ($contig, $bin) = split(/\t/, $line);
    die "Unknown bin $bin\n" unless defined($binSizes->{$bin});
    if ($binSizes->{$bin} > $minsize) {
        print OUT $line . "\n";
    }
}
close(TSV);
close(OUT);



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
        if (/^>(\S+)/) {
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

