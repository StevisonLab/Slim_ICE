#!/bin/bash

#------------------------------------------------------------------------------------------
#--- Bash script to simulate the fate of an inversion happening in a specific haplotype.---
#------------------------------------------------------------------------------------------
module load slim
#cp burn_in.txt /scratch/lss0021/slim/
#cp mutation_parse.pl /scratch/lss0021/slim/
cd /scratch/lss0021/slim

# i stand for the individiual the inversion happens in. Note that Slim follows C nomenclature and the first indiviudal has indice 0.
for ((i=0; i<2500; i+=1)) #note: original went from 4 to 14
do  
    
    # define the name of the folder storing the results.
    PREFIX2="Individual_nogc_V2_$i"
    
    # check that the fodler does not exsit to avoid erasing already exisitng results.
    if [ -d $PREFIX2 ]; then
	echo "abort simulation: $PREFIX is an existing directory"; 
	exit 1
    fi
    
    # if the master file storing  the seed, as well as the mian parameters used does not exist, create it with its column names.
    if [ ! -f master_file_nogc_ICE.csv ]; then
	echo "folder_name, seed, individual, haplotype,  het_adv,  rep, time_end, inversion_count, collinear_del, inversion_del" > master_file_nogc_ICE.csv
    fi

        # if the master file storing  the seed, as well as the mian parameters used does not exist, create it with its column names.
    if [ ! -f master_file_nogc_noICE.csv ]; then
	echo "folder_name, seed, individual, haplotype,  het_adv,  rep, time_end, inversion_count, collinear_del, inversion_del" > master_file_nogc_noICE.csv
    fi
    
    # create the directory and move there
    mkdir $PREFIX2
    #	cp burn_in.txt $PREFIX2
    cd $PREFIX2
    
    # definte the name that all files will share. it can be different from the folder name as many files manipulation in R requires specific file name syntax, and soemtimes one need more flexibility for folder names.
    PREFIX="Individual_$i"
    
    # do 100 replicates of the inversion scenario
    for ((j=1; j<=1000; j+=1)) #need to reset to do 100
    do  
	echo "$PREFIX"
	for ((h=0; h<=1;h++)) #do loop through haps		
	do
	    #Run slim for first haplotype (hap 1 in slim)
	    Seed=$(python3 -c 'import random as R; print(R.randint(1, 2**32-1))')
	    slim -seed $Seed -d indv=$i -d haplo=$h -d s_het=1.03 -d P_KEEP=0.857 -d rec=0.0000184 /home/lss0021/ICE_slim/inversion_forall_nogc-fixed-ICE.slim
	    
	    # rename the file after their creation. Handling file name is far easier in bash than in Slim, especially if we want importnat parameter values to be included in the name.
	    mv del_mutations.txt ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	    mv inversion_data_fm.txt ${PREFIX}_${h}_shet1.03_${j}_inversion_data_fm.txt
	    mv fitness_p1.txt ${PREFIX}_${h}_shet1.03_${j}_fitness_p1.txt
	    mv inversion_counts.txt ${PREFIX}_${h}_shet1.03_${j}_inversion_counts.txt
	    mv final_population.txt ${PREFIX}_${h}_shet1.03_${j}_final_population.txt
	    
	    # a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
	    ./../mutation_parse.pl ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt
	    
	    temp=$(wc -l collinear_del.txt | awk '{print $1}')
	    col_del=$(bc <<< "scale=5; ${temp}/60000") 			# to adapt depending on the number of chromosomes
	    temp=$(wc -l inversion_del.txt | awk '{print $1}')
	    inv_del=$(bc <<< "scale=5; ${temp}/10000")
	    
	    time_end=$(awk 'NR==1{print $2}' ${PREFIX}_${h}_shet1.03_${j}_del_mutations.txt)
	    inv_count=0
	    if [ $time_end == 1000001 ]; then 
		inv_count=$(awk 'END {print $12}' ${PREFIX}_${h}_shet1.03_${j}_inversion_counts.txt)
	    fi
	    
	    # write the outcome in the master file.
	    echo "$PREFIX, $Seed, $i, ${h}, 1.03, $j, $time_end ,$inv_count, $col_del, $inv_del " >> ./../master_file_nogc_ICE.csv
	done
	
	#Run slim again with parameters set so there is NO ICE
	
	for ((h=0; h<=1;h++)) #do loop through haps		
	do
	    #Run slim for first haplotype (hap 1 in slim)
	    Seed=$(python3 -c 'import random as R; print(R.randint(1, 2**32-1))')
	    slim -seed $Seed -d indv=$i -d haplo=$h -d s_het=1.03 -d P_KEEP=1.0 -d rec=0.0000024 /home/lss0021/ICE_slim/inversion_forall_nogc-fixed-noICE.slim
	    
	    # rename the file after their creation. Handling file name is far easier in bash than in Slim, especially if we want importnat parameter values to be included in the name.
	    mv del_mutations.txt ${PREFIX}_${h}_shet1.03_${j}_del_mutations_noICE.txt
	    mv inversion_data_fm.txt ${PREFIX}_${h}_shet1.03_${j}_inversion_data_fm_noICE.txt
	    mv fitness_p1.txt ${PREFIX}_${h}_shet1.03_${j}_fitness_p1_noICE.txt
	    mv inversion_counts.txt ${PREFIX}_${h}_shet1.03_${j}_inversion_counts_noICE.txt
	    mv final_population.txt ${PREFIX}_${h}_shet1.03_${j}_final_population_noICE.txt
	    
	    # a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
	    ./../mutation_parse.pl ${PREFIX}_${h}_shet1.03_${j}_del_mutations_noICE.txt
	    
	    temp=$(wc -l collinear_del.txt | awk '{print $1}')
	    col_del=$(bc <<< "scale=5; ${temp}/60000") 			# to adapt depending on the number of chromosomes
	    temp=$(wc -l inversion_del.txt | awk '{print $1}')
	    inv_del=$(bc <<< "scale=5; ${temp}/10000")
	    
	    time_end=$(awk 'NR==1{print $2}' ${PREFIX}_${h}_shet1.03_${j}_del_mutations_noICE.txt)
	    inv_count=0
	    if [ $time_end == 1000001 ]; then 
		inv_count=$(awk 'END {print $12}' ${PREFIX}_${h}_shet1.03_${j}_inversion_counts_noICE.txt)
	    fi
	    
	    # write the outcome in the master file.
	    echo "$PREFIX, $Seed, $i, ${h}, 1.03, $j, $time_end ,$inv_count, $col_del, $inv_del " >> ./../master_file_nogc_noICE.csv
	done
    done
    cd ..
done

cp master_file_nogc_ICE.csv /home/lss0021/ICE_slim/
cp master_file_nogc_noICE.csv /home/lss0021/ICE_slim/
