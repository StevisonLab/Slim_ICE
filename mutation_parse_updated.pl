#!/usr/bin/perl

$PREFIX = $ARGV[0];

open(MUT, "$PREFIX") or die;
open (OUT_DEL_X, ">chrX_del.txt");
open (OUT_DEL_2L, ">chr2L_del.txt");
open (OUT_DEL_2R, ">chr2R_del.txt");
open (OUT_DEL_INV, ">inversion_del.txt");
open (OUT_DEL_3L, ">chr3L_del.txt");
open (OUT_DEL_3R, ">chr3R_del.txt");

#@X_del = ();
#@2L_del = ();
#@inv_del = ();
#@2R_del = ();
#@3L_del = ();
#@3R_del = ();

#add counter
#$counter=0;

while(<MUT>) {
    chomp;
    @in = split(/\s+/, $_);
    
    #    if ($counter<10) {
    #	print STDOUT "Field 6: $in[6]; Field 7: $in[7]\n";
    #	$counter++;
    #    }
    
    if ( $in[7] > 55047499 && $in[7] <= 60019275 && $in[6] eq 'm5') {  #mutation inside inversion
	print OUT_DEL_INV "$_\n";
    } elsif ( $in[7] <= 22018999 && $in[6] eq 'm5') {  #mutation on X
	print OUT_DEL_X "$_\n";
    } elsif ( $in[7] >= 22019000 && $in[7] <= 44037999 && $in[6] eq 'm5') {  #mutation on 2L
	print OUT_DEL_2L "$_\n";
    } elsif ( $in[7] >= 44038000 && $in[7] <= 55047499 && $in[6] eq 'm5') {  #mutation on 2R
	print OUT_DEL_2R "$_\n";
    } elsif ( $in[7] > 60019275 && $in[7] <= 66056999 && $in[6] eq 'm5') {  #mutation on 2R
	print OUT_DEL_2R "$_\n";
    } elsif ( $in[7] >= 66057000 && $in[7] <= 88075999 && $in[6] eq 'm5') {  #mutation on 3L
	print OUT_DEL_3L "$_\n";
    } elsif ( $in[7] >= 88076000 && $in[6] eq 'm5') {  #mutation on 3R
	print OUT_DEL_3R "$_\n";
    }
}

#print OUT_DEL_INV "@inv_del";
#print OUT_DEL_COL "@col_del";
#print OUT_LA_INV "@inv_la";
#print OUT_LA_COL "@col_la";
