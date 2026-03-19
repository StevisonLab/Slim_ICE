#!/usr/bin/perl

$PREFIX = $ARGV[0];

open(MUT, "$PREFIX") or die;
open (OUT_DEL_INV, ">inversion_fix.txt");
open (OUT_DEL_COL, ">collinear_fix.txt");
#open (OUT_LA_INV, ">inversion_LA.txt");
#open (OUT_LA_COL, ">collinear_LA.txt");

@inv_del = ();
@col_del = ();
#@inv_la = ();
#@col_la = ();

#add counter
#$counter=0;

while(<MUT>) {
    chomp;
    @in = split(/\s+/, $_);
    
    #    if ($counter<10) {
    #	print STDOUT "Field 6: $in[6]; Field 7: $in[7]\n";
    #	$counter++;
    #    }
    
    if ( 50000	<= $in[3] && $in[3] <= 79999  &&	$in[2] eq 'm5') {
	push @inv_del, "$_\n";
	#    }  elsif ( 50000 > $in[7] | $in[7] > 79999 &&	$in[6] eq 'm5' ) {
    }  elsif ( $in[3] > 99999 &&	$in[2] eq 'm5') {
	push @col_del, "$_\n";
	#    } elsif ( 50000	<= $in[7] && $in[7] <= 79999  &&	$in[6] =~ /m3|m4/ ) {
	#	push @inv_la, "$_\n";
	#    }
	#    elsif ( 50000	> $in[7]  | $in[7]> 79999 &&	$in[6] =~ /m3|m4/ ) {
	#	push @col_la, "$_\n";
    }
}

print OUT_DEL_INV "@inv_del";
print OUT_DEL_COL "@col_del";
#print OUT_LA_INV "@inv_la";
#print OUT_LA_COL "@col_la";
