#!/bin/bash

#------------------------------------------------------------------------------------------
#--- Bash script to simulate the fate of an inversion happening in a specific haplotype.---
#------------------------------------------------------------------------------------------

mkdir /scratch/lss0021/slim_run5/
cp mutation_parse_updated.pl /scratch/lss0021/slim_run5/
cp burn_in.txt /scratch/lss0021/slim_run5/

echo "folder_name, seed, individual, haplotype,  het_adv,  rep, time_end, chrX, chr2L, chr2R, inv, chr3L, chr3R" > /scratch/lss0021/slim_run5/master_file_nogc_m1.csv
echo "folder_name, seed, individual, haplotype,  het_adv,  rep, time_end, chrX, chr2L, chr2R, inv, chr3L, chr3R" > /scratch/lss0021/slim_run5/master_file_nogc_m2.csv
echo "folder_name, seed, individual, haplotype,  het_adv,  rep, time_end, chrX, chr2L, chr2R, inv, chr3L, chr3R" > /scratch/lss0021/slim_run5/master_file_nogc_m3.csv

if [[ -s /scratch/lss0021/slim_run5/master_file_nogc_m1.csv && -s /scratch/lss0021/slim_run5/master_file_nogc_m2.csv && -s /scratch/lss0021/slim_run5/master_file_nogc_m3.csv ]];then

    sbatch --array=1-100 run_slim.sh

fi
