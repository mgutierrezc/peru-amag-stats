*AMAG data cleaning code

if c(username)=="ronak" {
global main "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\"
global code "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\"
global roster "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Randomization"
}

************************************************************************
**prep participant list file to link with incoming data
************************************************************************
cd "$roster"
import excel Matriculados_03.06.2021.xlsx, firstrow clear
destring DNI, force replace
isid DNI
save "$data\participant_list_full.dta", replace

************************************************************************
**prep randomization list file to link with incoming data
************************************************************************
import delimited "/Users/mayumicornejo/Desktop/World Bank /rand_peru_list_final.csv", encoding(UTF-8) 
rename dni DNI
drop apellidomaterno apellidopaterno cargo curso género nombres resadmisión
save "randomization_treatment.dta"

******************
**Incoming data cleaning
******************

cd "$data"
import delimited "all_apps_wide-2021-06-14.csv",  encoding(UTF-8) clear 

*Drop observations without DNI
drop if login1playerdni==.
ren login1playerdni DNI

*Drop demo observations
br if sessionis_demo==1
drop if sessionis_demo==1
drop sessionis_demo

*dropping incorrect demo versions that were accidently done after the launch (Ronak)
drop if participanttime_started=="2021-06-04 23:58:00.716545+00:00" | participanttime_started=="2021-06-05 00:05:18.015527+00:00"

*drop possible test obsevarions with DNIs:23981093, 44587283, 44196897, 40788349, 46751257, 41175760, 70077738, 45455469

tab DNI if DNI==23981093
tab DNI if DNI==44587283
tab DNI if DNI==44196897
tab DNI if DNI==40788349
tab DNI if DNI==46751257
tab DNI if DNI==41175760
tab DNI if DNI==70077738
tab DNI if DNI==45455469 

list participanttime_started participant_current_app_name if DNI==40788349
list participanttime_started participant_current_app_name if DNI==41175760

*Drop bot observations
drop if participant_is_bot==1
drop participant_is_bot

*drop duplicate DNI observations
duplicates report DNI
duplicates tag DNI, gen(dup)
sort DNI participant_index_in_pages 
br if dup>0
bys DNI: drop if _n<_N & dup>0
isid DNI

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

******************************************************
*Information about status of completion
******************************************************

*Participant stats
di _N //number of surveys with loginIDs 
tab participant_current_app_name 
tab participant_index_in_pages

*merging participant list
merge m:1 DNI using participant_list_full.dta, force  
tab _merge

drop TipoIngreso celular correoinstitucional email telefono SedeMatricula

*Absolute numbers by course
replace Curso = subinstr(Curso, "Curso Especializado a Distancia","",.) 
tab Curso if _merge==3 

*Participants from each course
bys Curso: egen course_size = count(DNI)
bys Curso: egen total_resp_course = count(DNI) if _merge==3
gen resp_rates_course = total_resp_course/course_size
replace resp_rates_course = round(resp_rates_course*100)
tab  resp_rates_course 
bys Curso: sum resp_rates_course

*merging socratic treatment list
merge m:1 DNI using randomization_treatment.dta, force generate(_merge2)
tab _merge2
drop _merge2
rename treat_socratic socratic_treated

******************************************************
*General Summary statistics
******************************************************
*Participants by gender
tab Género if _merge==3
gen gender_male=0 // gender dummy
replace gender_male=1 if Género=="Masculino"

*by role/position
tab Cargo if _merge==3

gen judge=0
replace judge=1 if Cargo=="JUEZ"

gen prosecutor=0
replace prosecutor=1 if Cargo=="FISCAL"

******************************************************
*Exercise Summary statistics
******************************************************

*Trolley experiment

gen footbridge_male=0
replace footbridge_male=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==1

gen footbridge_female=0
replace footbridge_female=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==0

gen bystander_male=0
replace tracks_male=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==1

gen bystander_female=0 
replace tracks_female=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==0

gen trolley_treatment=""
replace trolley_treatment="footbridge_male" if footbridge_male==1
replace trolley_treatment="footbridge_female" if footbridge_female==1
replace trolley_treatment="bystander_male" if bystander_male==1
replace trolley_treatment="bystander_female" if bystander_female==1
tab trolley_treatment


tab Género trolley1playertrolley_decision
bys trolley1playeris_footbridge Género : tab  trolley1playertrolley_decision
bys trolley_treatment: tab Género trolley1playertrolley_decision  

bys Cargo: tab trolley1playertrolley_decision
bys trolley_treatment: tab judge trolley1playertrolley_decision if _merge==3
bys trolley_treatment: tab prosecutor trolley1playertrolley_decision if _merge==3

*IAT score
tab iat1playerskip_iat
bys iat1playerskip_iat: tab Cargo gender_male

bys Cargo: sum iat1playeriat_score if _merge==3
bys gender_male: sum iat1playeriat_score

tab iat1playerfeedback_desire_level
bys Cargo: sum iat1playerfeedback_desire_level
bys gender_male: sum iat1playerfeedback_desire_level


*Dice roll
tab  games_solo1playerlying_die_roll games_solo1playerlying_decision

gen dice_liar=0 if _merge==3 & games_solo1playerlying_decision!=.
replace dice_liar=1 if games_solo1playerlying_die_roll!=games_solo1playerlying_decision

bys Cargo : tab dice_liar gender_male

*Redistribution
tab redistribute_player_decision // a little unsure about how to read this variable, not sure what the baseline is

tab redistribute_player_decision if games_player_knowredist_partnB==1 & games_solo1playerknows_redistrib==0

tab redistribute_player_decision if games_player_knowredist_partnB==0 & games_solo1playerknows_redistrib==1

tab redistribute_player_decision if games_player_knowredist_partnB==1 & games_solo1playerknows_redistrib==1

*Altruism
tab games_solo1playerdictator_decisi 
bys games_solo1playerknows_dictator_ : tab games_solo1playerdictator_decisi

*Motivated Reasoning
tab motivated_reasoning1playerfake_n  motivated_reasoning1playerapprov

bys motivated_reasoning1playernews_h: tab motivated_reasoning1playerfake_n

*Survey


*Payoffs
tab participantpayoff
bys gender_male: sum participantpayoff 
bys Cargo: sum participantpayoff





exit



