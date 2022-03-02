*AMAG data cleaning code

if c(username)=="ronak" {
global main "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\"
global code "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\"
global roster "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Randomization"
}

************************************************************************
**preparing participant list file for linking with incoming data
************************************************************************
cd "$roster"
import excel Matriculados_03.06.2021.xlsx, firstrow clear
destring DNI, force replace
isid DNI
save "$data\participant_list_full.dta", replace

******************
**Incoming data 
******************

cd "$data"
import delimited "all_apps_wide-2021-06-10.csv",  encoding(UTF-8) clear 

*Drop observations without DNI
drop if login1playerdni==.
ren login1playerdni DNI

*Drop demo observations
br if sessionis_demo==1
drop if sessionis_demo==1
drop sessionis_demo

*dropping incorrect demo versions that were accidently done after the launch
drop if participanttime_started=="2021-06-04 23:58:00.716545+00:00" | participanttime_started=="2021-06-05 00:05:18.015527+00:00"

*Drop bot observations
drop if participant_is_bot==1
drop participant_is_bot

******************************************************
*Information about status of completion
******************************************************
duplicates report DNI
duplicates tag DNI, gen(dup)
sort DNI participant_index_in_pages 
br if dup>0
bys DNI: drop if _n<_N & dup>0
isid DNI
di _N //number of surveys with loginIDs 
tab participant_current_app_name 
merge m:1 DNI using participant_list_full, force  
tab _merge
replace Curso = subinstr(Curso, "Curso Especializado a Distancia","",.) 
tab Curso if _merge==3 //absolute numbers by course
bys Curso: egen course_size = count(DNI)
bys Curso: egen total_resp_course = count(DNI) if _merge==3
gen resp_rates_course = total_resp_course/course_size
replace resp_rates_course = round(resp_rates_course*100)
tab resp_rates_course
bys Curso: sum resp_rates_course

exit

*Drop blank/unnecessary variables
drop survey_qvsr1playerat_this_time_1 survey_qvsr1playerat_this_time_2 survey_qvsr1playerat_this_time_3 survey_qvsr1playerat_this_time_4 survey_qvsr1playerat_this_time_5 survey_qvsr1playerat_this_time_6 survey_qvsr1playerat_this_time_7 survey_qvsr1playerthink_of_you_1 survey_qvsr1playerthink_of_you_2 survey_qvsr1playerthink_of_day_1 survey_qvsr1playerthink_of_day_2 survey_qvsr1playerthink_of_day_3

drop v64 v65 v66 v68 // not sure how to handle these variables since they might be named differently for others when CSV is exported to stata

drop survey_qvsr1playerwork_engagemen v54 v55 

drop login1playerpayoff login1playerrole

drop participantvisited participantmturk_worker_id participantmturk_assignment_id 

drop sessionlabel sessionmturk_hitgroupid sessionmturk_hitid sessioncomment

drop sessionconfigparticipation_fee sessionconfigmock_exogenous_data sessionconfigreal_world_currency login1groupid_in_subsession login1subsessionround_number survey_qvsr1playerpayoff redistribute1playerpayoff participanttime_started  redistribute1subsessionround_num redistribute1groupid_in_subsessi trolley1playerpayoff iat1playerpayoff socratic_video1playerpayoff motivated_reasoning1playerpayoff prize1playerpayoff prize1subsessionround_number prize1groupid_in_subsession //not sure if these variables should be dropped

drop survey_qvsr1playerrole  survey_qvsr1playerlg_selected survey_qvsr1playerip survey_qvsr1playerregion_detecte redistribute1playerrole games_solo1playerrole v132 v133 trolley1playerrole iat1playerrole socratic_video1playerrole motivated_reasoning1playerrole prize1playerrole

*Rename variables- not sure how this code should be handled since the stata might put different variable names for these 
rename v79 redistribute_partnername_a
rename v130 motivatedreason_approveconfiden
rename v138 motivatedreason_timestamp
rename v78 redistribute_partnerDNI_b
rename v80 redistribute_partnername_b
rename v81 redistribute_player_decision
rename v88 games_solo_partner_name
rename v92 games_player_knowredist_partnB

