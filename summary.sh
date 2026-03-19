#! /usr/bin/sh

#get list of files with runs over 5k
#runs=(`awk -F, '$7>505000' /scratch/lss0021/slim_run2/master_file_nogc_ICE.csv`)
#nruns=(`awk -F, '$7>505000' /scratch/lss0021/slim_run2/master_file_nogc_noICE.csv`)

#Individual_162, 2544677791, 162, 1, 1.03, 159, 507696 ,0, .05870, .05480 
#Individual_363, 2247178793, 363, 1, 1.03, 39, 510698 ,0, .05783, .05700 

#use that info to parse these files:
id=(`awk -F, '$7>500010 {print $3}' /scratch/lss0021/slim_run2/master_file_nogc_ICE.csv`)
hap=(`awk -F, '$7>500010 {print $4}' /scratch/lss0021/slim_run2/master_file_nogc_ICE.csv`)
it=(`awk -F, '$7>500010 {print $6}' /scratch/lss0021/slim_run2/master_file_nogc_ICE.csv`)

echo "Number its over 5k ICE: ${#id[@]}"

rm summary.fixed.mutations.txt summary.fixed.mutations_noICE.txt

for ((i=0; i<${#id[@]}; i++)) 
do
#    ls /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm.txt
    # a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
    file_len=`wc -l /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm.txt | awk '{print $1}'`
#    echo $file_len

    if [[ $file_len -ge 3 ]]; then

	/home/lss0021/ICE_slim/fixed_mut_parse.pl /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm.txt

	if [[ -s collinear_fix.txt ]]; then 	
	    temp=$(wc -l collinear_fix.txt | awk '{print $1}')
	    col_del=$(bc <<< "scale=5; ${temp}/60000")    
	    sel1=`awk '{sum+=$5} END {printf "%5.8f\n", sum/NR}' collinear_fix.txt`
	else
	    col_del="NA"
	    sel1="NA"
	fi

	if [[ -s inversion_fix.txt ]]; then
	    temp=$(wc -l inversion_fix.txt | awk '{print $1}')
	    inv_del=$(bc <<< "scale=5; ${temp}/10000")
	    sel2=`awk '{sum+=$5} END {printf "%5.8f\n", sum/NR}' inversion_fix.txt`
	else
	    inv_del="NA"
	    sel2="NA"
	fi
    else 
	col_del="NA"
	inv_del="NA"
	sel1="NA"
	sel2="NA"
    fi

    echo "${id[$i]}, ${hap[$i]}, 1.03, ${it[$i]}, $col_del, $inv_del,$sel1, $sel2 " >> summary.fixed.mutations.txt
done

echo "ICE:"
awk -F, '$5!~/NA/ && $6!~/NA/' summary.fixed.mutations.txt | awk -F, '{col+=$5;inv+=$6} END {print "Fix nonHom",col/NR,"Fix inv",inv/NR,NR}'
awk -F, '$7!~/NA/ && $8!~/NA/' summary.fixed.mutations.txt | awk -F, '{col+=$7;inv+=$8} END {print "Sel coef nonHom",col/NR,"Sel coef inv",inv/NR,NR}'

#repeat for noICE
#use that info to parse these files:
id=(`awk -F, '$7>500010 {print $3}' /scratch/lss0021/slim_run2/master_file_nogc_noICE.csv`)
hap=(`awk -F, '$7>500010 {print $4}' /scratch/lss0021/slim_run2/master_file_nogc_noICE.csv`)
it=(`awk -F, '$7>500010 {print $6}' /scratch/lss0021/slim_run2/master_file_nogc_noICE.csv`)

echo "Number its over 5k no ICE: ${#id[@]}"

for ((i=0; i<${#id[@]}; i++)) 
do
#    ls /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm_noICE.txt
    file_len=`wc -l /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm_noICE.txt | awk '{print $1}'`
#    echo $file_len

    if [[ $file_len -ge 3 ]]; then

    # a Perl script to calculate the number of deleterious mutations in the inverted and collinear regions. Output is stored in the master file.
    /home/lss0021/ICE_slim/fixed_mut_parse.pl /scratch/lss0021/slim_run2/Individual_nogc_V2_${id[$i]}/Individual_${id[$i]}_${hap[$i]}_shet1.03_${it[$i]}_inversion_data_fm_noICE.txt

	if [[ -s collinear_fix.txt ]]; then 	
	    temp=$(wc -l collinear_fix.txt | awk '{print $1}')
	    col_del=$(bc <<< "scale=5; ${temp}/60000")    
	    sel1=`awk '{sum+=$5} END {printf "%5.8f\n", sum/NR}' collinear_fix.txt`
	else
	    col_del="NA"
	    sel1="NA"
	fi

	if [[ -s inversion_fix.txt ]]; then
	    temp=$(wc -l inversion_fix.txt | awk '{print $1}')
	    inv_del=$(bc <<< "scale=5; ${temp}/10000")
	    sel2=`awk '{sum+=$5} END {printf "%5.8f\n", sum/NR}' inversion_fix.txt`
	else
	    inv_del="NA"
	    sel2="NA"
	fi
    else 
	col_del="NA"
	inv_del="NA"
	sel1="NA"
	sel2="NA"
    fi

    echo "${id[$i]}, ${hap[$i]}, 1.03, ${it[$i]}, $col_del, $inv_del,$sel1, $sel2 " >> summary.fixed.mutations_noICE.txt
done

echo "No ICE:"
awk -F, '$5!~/NA/ && $6!~/NA/' summary.fixed.mutations_noICE.txt | awk -F, '{col+=$5;inv+=$6} END {print "Fix nonHom",col/NR,"Fix inv",inv/NR,NR}'
awk -F, '$7!~/NA/ && $8!~/NA/' summary.fixed.mutations_noICE.txt | awk -F, '{col+=$7;inv+=$8} END {print "Sel coef nonHom",col/NR,"Sel coef inv",inv/NR,NR}'
#awk -F, '{col+=$5;inv+=$6} END {print "Fix nonHom",col/NR,"Fix inv",inv/NR,NR}' summary.fixed.mutations_noICE.txt 
#awk -F, '{col+=$7;inv+=$8} END {print "Sel coef nonHom",col/NR,"Sel coef inv",inv/NR,NR}' summary.fixed.mutations_noICE.txt 
