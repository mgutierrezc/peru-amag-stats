*AMAG endline data cleaning code

if c(username)=="Ronak" {
global main "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\"
global code "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\"
global data_baseline "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\Baseline raw\"
global data_endline "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\Endline raw\"
global roster "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Randomization"
}

if c(username)=="mayumicornejo" {
global main "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/"
global code "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/Code/Clean raw data/"
global data "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/Data/"
global data_baseline "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/Data/Baseline raw/"
global data_endline "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/Data/Endline raw"
global roster "/Users/mayumicornejo/Ash Center-Julianne Dropbox/Mayumi Cornejo/AMAG courses evaluation 2021/Code/Randomization"
}

******************
**Incoming data cleaning
******************
cd "$data_endline"
import delimited "all_apps_wide_2021-07-20.csv",  encoding(UTF-8) clear 

*Drop observations without DNI
drop if login1playerdni==.
ren login1playerdni DNI

*Drop demo observations
br if sessionis_demo==1
drop if sessionis_demo==1
drop sessionis_demo

*Drop bot observations
drop if participant_is_bot==1
drop participant_is_bot

*drop duplicate DNI observations
duplicates report DNI
duplicates list DNI
duplicates tag DNI, gen(dup)
sort DNI participant_index_in_pages 
br if dup>0
bys DNI: drop if _n<_N & dup>0 //Note: currently dropping those with lower participation for a duplicate
isid DNI

******************************************************
*Information about status of completion
******************************************************

*Participant stats
di _N //number of surveys with loginIDs 
tab participant_current_app_name 
tab participant_index_in_pages

*merging participant list
cd "$data"
merge 1:1 DNI using participant_list_full.dta, force  
tab _merge

//drop TipoIngreso celular telefono SedeMatricula //correoinstitucional

*Absolute numbers by course
replace Curso = subinstr(Curso, "Curso Especializado a Distancia","",.) 
tab Curso if _merge==3 

*merging treatment list
merge 1:1 DNI using randomization_treatment_endline.dta, force generate(_merge2)
tab _merge2
drop _merge2
rename treat_socratic socratic_treated 

//Course response rate
bys Curso: egen course_size = count(DNI)
bys Curso: egen total_resp_course = count(DNI) if _merge==3
gen resp_rates_course = total_resp_course/course_size
replace resp_rates_course = (resp_rates_course*100)
bys Curso: sum resp_rates_course

*by role/position balance
tab Cargo
tab Cargo if _merge==3 

******************************************************
*Create file with ultimatum game related variables and demographics to pass on to Sam and Peter 
******************************************************
preserve
keep DNI ultimatum1playerid_in_group - ultimatum3subsessionround_number proposer order_of_ex label_order_UG Cargo Curso género 
order DNI ultimatum1playerid_in_group - ultimatum3subsessionround_number proposer order_of_ex label_order_UG Cargo Curso género
save "$data/Ultimatum_game_data_full.dta", replace
restore
exit
******************************************************
*Create file of students by course who have completed  
******************************************************
keep DNI Cargo Curso ApellidoPaterno ApellidoMaterno Nombres NroAula Institución email participant_current_app_name

order participant_current_app_name Curso NroAula DNI  ApellidoPaterno ApellidoMaterno Nombres email Cargo Institución  

rename participant_current_app_name Estado_de_Cuestionario_en

replace Estado_de_Cuestionario_en="Falta" if Estado_de_Cuestionario_en==""
replace Estado_de_Cuestionario_en="Completo" if Estado_de_Cuestionario_en=="prize"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="iat"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="login"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="motivated_reasoning"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="trolley"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="ultimatum"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="games_solo"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="redistribute"
replace Estado_de_Cuestionario_en="Comenzo pero no termino" if Estado_de_Cuestionario_en=="survey_qvsr"

tab Estado_de_Cuestionario_en

save "$data/Student completion status_endline.dta", replace

******************************************************
*Merging with Baseline completion status to see how many of the completed ones also completed baseline  
******************************************************
*merging participant list
merge 1:1 DNI using "Student completion status.dta", force  gen(merge3)
tab merge3

tab Estado_de_Cuestionario Estado_de_Cuestionario_en 

export excel using "$data/Estado de cuestionario_endline.xlsx", sheetreplace firstrow(variables) 
exit












/*to check later
*Drop blank/unnecessary variables
drop dup
drop survey_qvsr1playerat_this_time_1 survey_qvsr1playerat_this_time_2 survey_qvsr1playerat_this_time_3 survey_qvsr1playerat_this_time_4 survey_qvsr1playerat_this_time_5 survey_qvsr1playerat_this_time_6 survey_qvsr1playerat_this_time_7 survey_qvsr1playerthink_of_you_1 survey_qvsr1playerthink_of_you_2 survey_qvsr1playerthink_of_day_1 survey_qvsr1playerthink_of_day_2 survey_qvsr1playerthink_of_day_3

drop v64 v65 v66 v68 // not sure how to handle these variables since they might be named differently for others when CSV is exported to stata

drop survey_qvsr1playerwork_engagemen v54 v55 

drop login1playerpayoff login1playerrole

drop participantvisited participantmturk_worker_id participantmturk_assignment_id 

drop sessionlabel sessionmturk_hitgroupid sessionmturk_hitid sessioncomment

drop sessionconfigparticipation_fee sessionconfigmock_exogenous_data sessionconfigreal_world_currency login1groupid_in_subsession login1subsessionround_number survey_qvsr1playerpayoff redistribute1playerpayoff redistribute1subsessionround_num redistribute1groupid_in_subsessi trolley1playerpayoff iat1playerpayoff socratic_video1playerpayoff motivated_reasoning1playerpayoff prize1playerpayoff prize1subsessionround_number prize1groupid_in_subsession socratic_video1groupid_in_subses socratic_video1subsessionround_n motivated_reasoning1groupid_in_s motivated_reasoning1playerid_in_ motivated_reasoning1subsessionro //not sure if these variables should be dropped

drop survey_qvsr1playerrole survey_qvsr1playerlg_selected survey_qvsr1playerip survey_qvsr1playerregion_detecte redistribute1playerrole games_solo1playerrole v132 v133 trolley1playerrole iat1playerrole socratic_video1playerrole motivated_reasoning1playerrole prize1playerrole

*Rename variables- not sure how this code should be handled since the stata might put different variable names for these 
rename v79 redistribute_partnername_a
rename v130 motivatedreason_approveconfiden
rename v138 motivatedreason_timestamp
rename v78 redistribute_partnerDNI_b
rename v80 redistribute_partnername_b
rename v81 redistribute_player_decision
rename v88 games_solo_partner_name
rename v92 games_player_knowredist_partnB
*/
