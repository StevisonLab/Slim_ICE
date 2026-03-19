#!/bin/bash

#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --time=90:00:00
#SBATCH --mem=6GB

#------------------------------------------------------------------------------------------
#--- Bash script to simulate the fate of an inversion happening in a specific haplotype.---
#------------------------------------------------------------------------------------------
module load python
module load slim

cd /scratch/lss0021/slim_run5/

# i stand for the individiual the inversion happens in. Note that Slim follows C nomenclature and the first indiviudal has indice 0.
#for ((i=0; i<2500; i+=1)) #note: original went from 4 to 14
#do  
i=${SLURM_ARRAY_TASK_ID}

# define the name of the folder storing the results.
PREFIX2="Individual_nogc_V2_$i"

# create the directory and move there
mkdir $PREFIX2

cd $PREFIX2
    
# definte the name that all files will share. it can be different from the folder name as many files manipulation in R requires specific file name syntax, and soemtimes one need more flexibility for folder names.
PREFIX="Individual_$i"
    
# do 100 replicates of the inversion scenario
for ((j=1; j<=100; j+=1)) #need to reset to do 100
do  
    echo "$PREFIX replicate $j ..."
    for ((h=0; h<=1;h++)) #do loop through haps		
    do
	#Run slim for first haplotype (hap 1 in slim)
	Seed=$(python -c 'import random as R; print(R.randint(1, 2**32-1))')
	slim -seed $Seed -d indv=$i -d haplo=$h -d s_het=1.03 -d rec=2.26e-8 /home/lss0021/ICE_slim/inversion_forall_nogc-m1.slim
	
	# rename the file after their creation. Handling file name is far easier in bash than in Slim, especially if we want importnat parameter values to be included in the name.
	mv del_mutations.txt ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	mv final_population.txt ${PREFIX}_${h}_shet1.03_${j}_final_population.txt
	
	# a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
	./../mutation_parse_updated.pl ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	
	temp=$(wc -l chrX_del.txt | awk '{print $1}')
	chrX=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2L_del.txt | awk '{print $1}')
	chr2L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2R_del.txt | awk '{print $1}')
	chr2R=$(bc <<< "scale=5; ${temp}/1546000")
	temp=$(wc -l inversion_del.txt | awk '{print $1}')
	inv=$(bc <<< "scale=5; ${temp}/454000")
	temp=$(wc -l chr3L_del.txt | awk '{print $1}')
	chr3L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr3R_del.txt | awk '{print $1}')
	chr3R=$(bc <<< "scale=5; ${temp}/2000000")

	time_end=$(awk 'NR==1{print $2}' ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt)

	# write the outcome in the master file.
	echo "$PREFIX, $Seed, $i, ${h}, 1.03, $j, $time_end , $chrX, $chr2L, $chr2R, $inv, $chr3L, $chr3R" >> ./../master_file_nogc_m1.csv
    done
    
    #Run slim again with parameters for model 2 - simple inversion 
    for ((h=0; h<=1;h++)) #do loop through haps		
    do
	slim -seed $Seed -d indv=$i -d haplo=$h -d s_het=1.03 -d rec=2.26e-8 /home/lss0021/ICE_slim/inversion_forall_nogc-m2.slim
	
	# rename the file after their creation. Handling file name is far easier in bash than in Slim, especially if we want importnat parameter values to be included in the name.
	mv del_mutations.txt ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	mv final_population.txt ${PREFIX}_${h}_shet1.03_${j}_final_population.txt
	
	# a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
	./../mutation_parse_updated.pl ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	
	temp=$(wc -l chrX_del.txt | awk '{print $1}')
	chrX=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2L_del.txt | awk '{print $1}')
	chr2L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2R_del.txt | awk '{print $1}')
	chr2R=$(bc <<< "scale=5; ${temp}/1546000")
	temp=$(wc -l inversion_del.txt | awk '{print $1}')
	inv=$(bc <<< "scale=5; ${temp}/454000")
	temp=$(wc -l chr3L_del.txt | awk '{print $1}')
	chr3L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr3R_del.txt | awk '{print $1}')
	chr3R=$(bc <<< "scale=5; ${temp}/2000000")

	time_end=$(awk 'NR==1{print $2}' ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt)

	# write the outcome in the master file.
	echo "$PREFIX, $Seed, $i, ${h}, 1.03, $j, $time_end , $chrX, $chr2L, $chr2R, $inv, $chr3L, $chr3R" >> ./../master_file_nogc_m2.csv
    done

    #Run slim again with parameters for model 3 - complex model with global-local effects
    for ((h=0; h<=1;h++)) #do loop through haps		
    do
	slim -seed $Seed -d indv=$i -d haplo=$h -d s_het=1.03 -d rec=2.78e-8 /home/lss0021/ICE_slim/inversion_forall_nogc-m3.slim
	
	# rename the file after their creation. Handling file name is far easier in bash than in Slim, especially if we want importnat parameter values to be included in the name.
	mv del_mutations.txt ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	mv final_population.txt ${PREFIX}_${h}_shet1.03_${j}_final_population.txt
	
	# a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
	./../mutation_parse_updated.pl ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	
	temp=$(wc -l chrX_del.txt | awk '{print $1}')
	chrX=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2L_del.txt | awk '{print $1}')
	chr2L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr2R_del.txt | awk '{print $1}')
	chr2R=$(bc <<< "scale=5; ${temp}/1546000")
	temp=$(wc -l inversion_del.txt | awk '{print $1}')
	inv=$(bc <<< "scale=5; ${temp}/454000")
	temp=$(wc -l chr3L_del.txt | awk '{print $1}')
	chr3L=$(bc <<< "scale=5; ${temp}/2000000")
	temp=$(wc -l chr3R_del.txt | awk '{print $1}')
	chr3R=$(bc <<< "scale=5; ${temp}/2000000")

	time_end=$(awk 'NR==1{print $2}' ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt)

	# write the outcome in the master file.
	echo "$PREFIX, $Seed, $i, ${h}, 1.03, $j, $time_end , $chrX, $chr2L, $chr2R, $inv, $chr3L, $chr3R" >> ./../master_file_nogc_m3.csv
    done

done


cd ..

#copy files from scratch to home directory
#cp master_file_nogc_m1.csv /home/lss0021/ICE_slim/
#cp master_file_nogc_m2.csv /home/lss0021/ICE_slim/
#cp master_file_nogc_m3.csv /home/lss0021/ICE_slim/
