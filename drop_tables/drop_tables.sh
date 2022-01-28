#!/bin/bash
#run_file.meta --This is metafile which contains dataset information from which we want to extract the table name to operate on
# set -e -- causes a script immediatly exits when it encounters an error
set -e
cd ~
v_date=`date`

create_source_file() 
{
echo "********************"
    echo "Preparing source file for dataset --> $1"
	# --max_results=10000 flag --The BigQuery ls will only show 100 tables in a dataset so we have used this flag
bq ls --max_results=10000 $1| awk '{print $1}' | grep -E '_hv$|_ct$'>${1}.txt

#$? --get command execution station --0 means success otherwise error
RetCode1=$?

if [ $RetCode1 -eq 0 ]
then
    
    echo "${1}.txt file created successfully ."
	echo "********************"
	
else
    echo "********************"
    echo "Please check the error for $1.txt"
	echo "********************"
fi
	
}

drop_tables() 
{
echo "********************"
    echo "Deleting tables for dataset --> $1"
	v_dataset=$1
	
	#${}--to get variable value
	#$()--to get command output
	
for table in $(cat ${v_dataset}.txt)
do 
echo "Dropping --> ${v_dataset}.${table}"

#echo "bq rm -f -t  ${v_dataset}.${table}"
#-f --to forcefully delete the table
bq rm -f -t  ${v_dataset}.${table}
	
RetCode1=$?

if [ $RetCode1 -eq 0 ]
then
    #echo "********************"
    echo "${v_dataset}.${table} dropped successfully "
	echo "********************"	
else
    echo "********************"
    echo "Please check the error for bq rm -f -t  ${v_dataset}.${table} command"
	echo "********************"
fi
done	
}
#main programme starts from here
echo "Today's date --> $v_date"
echo "********************"
echo "Starting Table deletion script"
echo ""
echo "********************"
echo "Step 1 : Extract tables names from the dataset to the temp text file"
echo "Step 2 : Read the temp file containing tables and delete them one by one."
echo "********************"
echo ""

echo ""
echo "executing Step 1 "
for datasetname in $(cat run_file.meta)
do
create_source_file $datasetname
done

echo "Completed with  Step 1 "
echo "********************"
echo ""
echo "Executing  Step 2"
for datasetname in $(cat run_file.meta)
do
drop_tables $datasetname
done
echo "Completed with Step 2"

RetCode1=$?

if [ $RetCode1 -eq 0 ]
then
    echo "********************"
    echo "Script executed successfully "
	echo "********************"	
	exit 0
else
    echo "********************"
    echo "Please check the error"
	echo "********************"
	exit $RetCode1
fi



