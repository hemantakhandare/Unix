#!/bin/bash

function check_table_records()
{
echo  -e "\nCheking record count of  dataset1.staging_table table\n"
#initiate counter and record varible
retval="true"
counter=0
v_rec_cnt1=99999999999
#replace table name with dataset1.staging_table
v_rec_cnt2=`bq query --use_legacy_sql=false --format=csv "select count(99) from dataset1.staging_table"|tail -1`
 

while [[ ($v_rec_cnt1 -ne $v_rec_cnt2) || ($v_rec_cnt2 -eq 0) ]]; do
##While loop will  be continued until Current Record count and Delayed Record count values are same.
 
#increment the counter value
(( counter++ ))
 
echo -e "\nInside the while loop. Ieration--> $counter\n\n"
#replace table name with dataset1.staging_table
v_rec_cnt1=`bq query --use_legacy_sql=false --format=csv "select count(99) from dataset1.staging_table"|tail -1`
sleep 2m
#replace table name with dataset1.staging_table
v_rec_cnt2=`bq query --use_legacy_sql=false --format=csv "select count(99) from dataset1.staging_table"|tail -1`
 
echo -e "\nCounter value --> $counter\n"
echo -e "\nCurrent Record count ---> $v_rec_cnt1\n"
echo -e "\nDelayed Record count ---> $v_rec_cnt2\n"
 
#Check if table has zero records for 5 th iteration
        if [[ v_rec_cnt1 -eq 0 && v_rec_cnt2 -eq 0 && $counter -eq 5 ]]
        then
            echo -e "\nSource table does not have any records.\n Please check with SFDC team before running the SP\n"
            echo "SP:---->dataset1.SP_staging_table_HIST()\n"
            retval="false"
            send_email_alert
            break
            #exit 1
        fi
done 
}
######check_table_records function end ##############################################
 
######send email alert function start ##############################################
function send_email_alert()
{
#replace with your email id
to_email="your_org_email@mail.com"
 
echo -e "Team,\n No records present in dataset1.staging_table Table as on $(date).\n Please rerun the Job once data is available.\n\n\n Job Name--> 'PBQDL_staging_table_HIST_DAILY_LNX'\nWorkflow Name--> 'PBQ_staging_table_HIST_DAILY'\nSP Name--> 'dataset1.SP_staging_table_HIST'\n\nAuto generated Email.  " | mail -s " GCP Alert !!! No records present in dataset1.staging_table Table." $to_email
}
######send email alert function end ##############################################
################################new Code ends##################################
 
#### Main code starts here#####
 
SCRIPT_START_TIME=`date +"%Y-%m-%d %H:%M:%S"`
echo "SCRIPT_START_TIME :$SCRIPT_START_TIME"
echo -e "\n--------- Job For Triggering Stored Procedure [dataset1.SP_staging_table_HIST]-------- \n"
log_filename=`date +"%Y_%m_%d_%H_%M_%S"`
log_path=$APP_LOGS
echo "logpath:$log_path/bq_ops_logs/SP_staging_table_HIST_${log_filename}.log"
exec > $APP_LOGS/bq_ops_logs/SP_staging_table_HIST_${log_filename}.log 2>&1
 
time_stmp=`date +"%Y%m%d%H%M%S"`
 
echo -e "\n--------- Job For Triggering Stored Procedure -------- \n"
 
f1="dataset1"
f2="SP_staging_table_HIST"
    sp_dataset=$f1
    SP=$f2
    echo "stored procedure dataset:$sp_dataset";
#   SP=`echo "$f2"|cut -d '.' -f2`;
    echo "stored procedure name:$SP";
 
    stored_proc_ds=${sp_dataset}
    stored_proc=$SP
 
###calling check_table_records() function to check table records insertion and zero records
check_table_records
echo -e "\nReturn value from check_table_records()---->$retval\n"
#Checking the retval from function check_table_records ,if true then only run the SP 
if [[ "${retval}" == "true"  ]]
then 
 

#triggering Stored procedure
    echo "------------------------------------------------------------------------"
    echo "stored procedure calling[triggering/executing] ...."
    bq query --use_legacy_sql=false "call ${stored_proc_ds}.${stored_proc}()"
    if [[ $? -eq 0 ]]
    then
        echo "[Success] : stored procedure executed successfully."
 
    else
        echo "[Failed] : Failed to execute stored procedure"
        exit 1
    fi

 
f3="LOGTBL_D2_Pharma_BIA"
sp_dataset=$f1
SP=$f2
TableName=$f3
#Checking Given Stored procedure status
echo -e "\n\n\n-----------------Checking SP execution status in dataset1.LOGTBL_D2_Pharma_BIA table --------------"
 
stored_proc_status=`bq query --use_legacy_sql=false --format=csv "select status from ${sp_dataset}.${f3} where module_name='${SP}' order by end_date desc limit 1"|tail -1`
 
echo ${stored_proc_status}
 
if [[ "${stored_proc_status}" == "SUCCESS" ]]
then
     echo -e "\n\n${sp_dataset}.${SP} Stored procedure ran successfully."
else
     echo -e "\n[Failed] : Stored procedure has Failed,Please check the log table for more details."
     echo -e "\n[Failed] : Query:--> select * from ${sp_dataset}.${f3} where module_name='${SP}' order by end_date desc limit 1"
exit 1
fi
echo "------------------------------------------------------------------------"
 

fi
