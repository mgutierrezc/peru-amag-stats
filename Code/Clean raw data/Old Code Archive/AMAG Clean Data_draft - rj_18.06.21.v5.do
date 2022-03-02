*AMAG data cleaning code
di c(username)

if c(username)=="ronak" {
global main "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\"
global code "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\"
global roster "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Randomization"
global analysis "C:\Users\ronak\Dropbox (Harvard University)\AMAG courses evaluation 2021\Analysis"
}

if c(username)=="mayumi" {
global main "C:\Users\mayumi\Dropbox\AMAG courses evaluation 2021\"
global code "C:\Users\mayumi\Dropbox\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\mayumi\Dropbox\AMAG courses evaluation 2021\Data\"
global roster "C:\Users\mayumi\Dropbox\AMAG courses evaluation 2021\Code\Randomization"
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
cd "$roster"
import delimited "rand_peru_list_final.csv", encoding(UTF-8) clear
rename dni DNI
duplicates report DNI
drop apellidomaterno apellidopaterno cargo curso género nombres resadmisión
save "$data\randomization_treatment.dta", replace

******************
**Incoming data cleaning
******************
cd "$data"
import delimited "all_apps_wide_2021-06-18.csv",  encoding(UTF-8) clear 
gen source="set2"
tempfile set2
save `set2'

import delimited "all_apps_wide-2021-06-14.csv",  encoding(UTF-8) clear 
gen source="set1"
append using `set2' , force
tab source

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

*Drop demo attempt (RA confirmed this was the attempt that should be dropped)
drop if participanttime_started=="2021-06-07 15:43:55.606536+00:00" & DNI==40788349   

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

drop TipoIngreso celular correoinstitucional telefono SedeMatricula

*Absolute numbers by course
replace Curso = subinstr(Curso, "Curso Especializado a Distancia","",.) 
tab Curso if _merge==3 

*Percent participants from each course
bys Curso: egen course_size = count(DNI)
bys Curso: egen total_resp_course = count(DNI) if _merge==3
gen resp_rates_course = total_resp_course/course_size
replace resp_rates_course = round(resp_rates_course*100)
tab  resp_rates_course 
bys Curso: sum resp_rates_course

*merging treatment list
merge 1:1 DNI using randomization_treatment.dta, force generate(_merge2)
tab _merge2
drop _merge2
rename treat_socratic socratic_treated 

******************************************************
*General Summary statistics
******************************************************
*Participants by gender balance
tab Género
tab Género if _merge==3

gen gender_male=0 // gender dummy
replace gender_male=1 if Género=="Masculino"

*by role/position balance
tab Cargo
tab Cargo if _merge==3 

*dummies
gen judge=0
replace judge=1 if Cargo=="JUEZ"

gen prosecutor=0
replace prosecutor=1 if Cargo=="FISCAL"

******************************************************
*Exercise Summary statistics
******************************************************

*Trolley experiment
//dummies for each of the 4 treatments
gen footbridge_male=0
replace footbridge_male=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==1

gen footbridge_female=0
replace footbridge_female=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==0

gen bystander_male=0
replace bystander_male=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==1

gen bystander_female=0 
replace bystander_female=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==0

gen trolley_treatment=""
replace trolley_treatment="footbridge_male" if footbridge_male==1
replace trolley_treatment="footbridge_female" if footbridge_female==1
replace trolley_treatment="bystander_male" if bystander_male==1
replace trolley_treatment="bystander_female" if bystander_female==1
tab trolley_treatment //balance of treatment assignment

//Decisions by treatment types
tab trolley_treatment trolley1playertrolley_decision, row column
//RJ
graph bar trolley1playertrolley_decision, over(trolley_treatment)
graph bar trolley1playertrolley_decision, over(trolley_treatment) over(Género)
graph bar trolley1playertrolley_decision, over(trolley_treatment) over(judge)
graph bar trolley1playertrolley_decision, over(trolley_treatment) over(prosecutor)


//Decisions by female vs. male treatments (tiny gender bias)
tab trolley1playertrolley_decision trolley1playeris_men, column
//RJ
graph bar trolley1playertrolley_decision, over(trolley1playeris_men)
graph bar trolley1playertrolley_decision, over(trolley1playeris_men) over(judge)
graph bar trolley1playertrolley_decision, over(trolley1playeris_men) over(prosecutor)

//Decisions by footbridge vs. bystander
tab trolley1playertrolley_decision trolley1playeris_footbridge, column
//RJ
graph bar trolley1playertrolley_decision, over(trolley1playeris_footbridge)

//Decisions by participant gender and treatment
tab Género trolley1playertrolley_decision, row
bys trolley1playeris_footbridge Género : tab  trolley1playertrolley_decision
bys trolley1playeris_men Género : tab  trolley1playertrolley_decision
bys trolley_treatment: tab Género trolley1playertrolley_decision, row  

//Decisions by participant role
bys Cargo: tab trolley1playertrolley_decision
bys trolley_treatment: tab judge trolley1playertrolley_decision if _merge==3
bys trolley_treatment: tab prosecutor trolley1playertrolley_decision if _merge==3

*IAT score
//First node-randomization:option to take IAT or not
tab iat_take_or_not if _merge==3

//Upper branch 2nd node: take or skip IAT
tab iat1playerskip_iat if _merge==3, missing //breakdown of who chose to take IAT including missing (i.e. lower branch)
bys iat1playerskip_iat: tab Cargo gender_male
//RJ
graph bar iat1playerskip_iat, over(gender_male)
graph bar iat1playerskip_iat, over(Cargo)
graph bar iat1playerskip_iat, over(Género) over(Cargo) 

//feedback desire level distribution
tab iat1playerfeedback_desire_level
bys Cargo: sum iat1playerfeedback_desire_level
bys gender_male: sum iat1playerfeedback_desire_level
//RJ
catplot Cargo if _merge==3, by(iat1playerfeedback_desire_level) recast(bar) perc
catplot Género if _merge==3, by(iat1playerfeedback_desire_level) recast(bar) perc

//Whether participant wants feedback 
tab iat1playerwant_feedback if _merge==3, missing

//Option to IAT vs. got feedback
tab  iat_take_or_not feedback_or_not if _merge==3, row

//wants feedback vs. got feedback
tab iat1playerwant_feedback feedback_or_not if _merge==3, missing
//RJ:
catplot iat1playerwant_feedback if _merge==3, by(Cargo)  perc 
catplot iat1playerwant_feedback if _merge==3, by(Género) perc 

tab feedback_or_not iat_take_or_not if iat_take_or_not==1 & _merge==3

//Feedback for IAT option, took IAT, didn't get feedback: shows participants who got stuck
tab iat1playeriat_feedback if iat1playerskip_iat==0 & feedback_or_not==0 & _merge==3 & iat_take_or_not==1, missing 

tab participant_index_in_pages if  iat1playerskip_iat==0 & feedback_or_not==0 & _merge==3 & iat_take_or_not==1, missing //page index ->  & iat1playeriat_feedback==""  - shows some stuck on screen 12

tab participant_current_app_name if iat1playerskip_iat==0 & feedback_or_not==0 & _merge==3 & iat_take_or_not==1, missing //exercise name

//How many people got the error: randomization didn't happen, people ended on the IAT screen 
tab participant_index_in_pages if iat1playerskip_iat==0 & feedback_or_not==0 & _merge==3 & iat_take_or_not==1, missing 

//IAT scores
bys Cargo: sum iat1playeriat_score if _merge==3
bys gender_male: sum iat1playeriat_score
//RJ:
graph hbar iat1playeriat_score, over(Cargo)
graph hbar iat1playeriat_score, over(Género)


*Dice roll
//Distribution of dice roll vs. decision
tab  games_solo1playerlying_die_roll games_solo1playerlying_decision

//Dice liar dummy, only 2 liars
gen dice_liar=0 if _merge==3 & games_solo1playerlying_decision!=.
replace dice_liar=1 if games_solo1playerlying_die_roll!=games_solo1playerlying_decision
tab dice_liar

//who lied: male prosecutor and assistant
bys Cargo : tab dice_liar gender_male

*Redistribution Exercise
//Distribution of decisions, tail dues to slider? use text field?
tab redistribute_player_decision // unsure about how to read this variable, not sure what the baseline is

//Player knows partners? Most didn't
tab games_player_knowredist_partnB games_solo1playerknows_redistrib

/*RJ: commenting out for now as appending creates a mismatch
//Players only know partner B
tab redistribute_player_decision if games_player_knowredist_partnB==1 & games_solo1playerknows_redistrib==0

//Players only know partner A
tab redistribute_player_decision if games_player_knowredist_partnB==0 & games_solo1playerknows_redistrib==1

//Players only know partner A & B
tab redistribute_player_decision if games_player_knowredist_partnB==1 & games_solo1playerknows_redistrib==1
*/

//RJ: 
destring redistribute_player_decision, replace
graph hbar redistribute_player_decision, over(Cargo)
graph hbar redistribute_player_decision, over(Género)

*Altruism
//Distribution of decision, no tail here
tab games_solo1playerdictator_decisi 

//Does player know partner, only 13 participants do
bys games_solo1playerknows_dictator_ : tab games_solo1playerknows_dictator_

//RJ: 
graph hbar games_solo1playerdictator_decisi, over(Cargo)
graph hbar games_solo1playerdictator_decisi, over(Género)

*Motivated Reasoning
//Initial guess vs. fake news chance
//RJ: The way the question was asked the values probably capture the chance it was true news
tab motivated_reasoning1playerfake_n  motivated_reasoning1playerapprov 
//RJ:
orth_out motivated_reasoning1playerfake_n, by(motivated_reasoning1playerapprov) pcompare stars se
orth_out motivated_reasoning1playerfake_n, by(Curso) pcompare stars se
orth_out motivated_reasoning1playerfake_n, by(judge) pcompare stars se
orth_out motivated_reasoning1playerfake_n, by(prosecutor) pcompare stars se
orth_out motivated_reasoning1playerfake_n, by(Género) pcompare stars se

//Fake news and message (higher or lower)
bys motivated_reasoning1playernews_h: tab motivated_reasoning1playerfake_n
//RJ:
orth_out motivated_reasoning1playerfake_n, by(motivated_reasoning1playernews_h) pcompare stars se

//RJ: confirmation bias
//initial guess and final decision
tab motivated_reasoning1playerapprov motivated_reasoning1playerwould_, row 
//RJ: need to check with Chris about what 0/1 represents coding
catplot motivated_reasoning1playerwould_, by(motivated_reasoning1playerapprov) recast(bar)

//RJ: which arguments browsed by initial guess //check with Chris which is link X and A and how to convert to time spent as don't know which link clicked or clicked at all
orth_out motivated_reasoning1playertimest, by(motivated_reasoning1playerapprov) pcompare stars se
orth_out motivatedreason_timestamp, by(motivated_reasoning1playerapprov) pcompare stars se

//RJ: want to learn or not
tab motivated_reasoning1playerwant_t
tab Curso motivated_reasoning1playerwant_t , row nofreq
tab Género motivated_reasoning1playerwant_t , row nofreq
tab Cargo motivated_reasoning1playerwant_t , row nofreq
tab motivated_reasoning1playerapprov motivated_reasoning1playerwant_t , row nofreq
tab motivated_reasoning1playerwould_ motivated_reasoning1playerwant_t , row nofreq
//catplot motivated_reasoning1playerwant_t, by(motivated_reasoning1playerapprov) recast(bar)

*Socratic////balance- need to check with Chris which screen number corresponds to the socratic video 
//RJ: it's screen 16
tab socratic_treated
tab socratic_treated if _merge==3 & participant_index_in_pages>=16 //RJ
tab socratic_treated if _merge==3 & participant_index_in_pages>16 //RJ

*Survey//need to do by question


*Payoffs
tab participantpayoff

//by gender
bys gender_male: sum participantpayoff 

//by role
bys Cargo: sum participantpayoff

******************************************************
*Create file of students by course who have completed  
******************************************************

keep DNI Cargo Curso ApellidoPaterno ApellidoMaterno Nombres NroAula Institución email participant_current_app_name

order participant_current_app_name Curso NroAula DNI  ApellidoPaterno ApellidoMaterno Nombres email Cargo Institución  

rename participant_current_app_name Estado_de_Cuestionario

replace Estado_de_Cuestionario="Falta" if Estado_de_Cuestionario==""
replace Estado_de_Cuestionario="Completo" if Estado_de_Cuestionario=="prize"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="iat"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="login"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="motivated_reasoning"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="trolley"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="socratic_video"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="games_solo"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="redistribute"
replace Estado_de_Cuestionario="Comenzo pero no termino" if Estado_de_Cuestionario=="survey_qvsr"

tab Estado_de_Cuestionario

save "Student completetion status.dta", replace
export excel using "Estado de cuaestionario.xlsx", sheetreplace firstrow(variables) //RJ: added replace and merged latest set
exit



