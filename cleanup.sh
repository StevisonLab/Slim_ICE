#rm master_file_nogc*.csv

for ((i=0; i<=100; i+=1)) #note: original went from 4 to 14
do  
    # define the name of the folder storing the results.
    PREFIX2="Individual_nogc_V2_$i"
    echo $PREFIX2
    
    if [ -d "$PREFIX2" ]; then
	rm $PREFIX2/*.txt
#	pwd
#	rm ./*.txt
#	cd ../
#	pwd
	rmdir $PREFIX2
    fi

done


