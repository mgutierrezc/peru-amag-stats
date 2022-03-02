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
import delimited "all_apps_wide_2021-07-18.csv",  encoding(UTF-8) clear 

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

*drop ultimatum game related variables -> sent to Peter and Sam
drop ultimatum1playerid_in_group - ultimatum3subsessionround_number 

*Drop blank/unnecessary variables
drop dup

drop games_solo1groupid_in_subsession games_solo1playerid_in_group games_solo1playerrole games_solo1subsessionround_numbe

drop iat1groupid_in_subsession iat1playerbypass_iat iat1playeriat_tables iat1playerid_in_group iat1playerpayoff iat1playerrole iat1subsessionround_number

drop login1groupid_in_subsession login1playerid_in_group login1playerpayoff login1playerrole login1subsessionround_number

drop motivated_reasoning1groupid_in_s motivated_reasoning1playerid_in_ motivated_reasoning1playerpayoff motivated_reasoning1playerrole motivated_reasoning1subsessionro

drop participant_max_page_index participantcode participantid_in_session participantlabel participantmturk_assignment_id participantmturk_worker_id participantvisited 

drop prize1groupid_in_subsession prize1playerid_in_group prize1playerpayoff prize1playerrole prize1subsessionround_number

drop redistribute1groupid_in_subsessi redistribute1playerid_in_group redistribute1playerpayoff redistribute1playerrole redistribute1subsessionround_num 

drop sessioncode sessioncomment sessionconfigmock_exogenous_data sessionconfigparticipation_fee sessionconfigreal_world_currency sessionlabel sessionmturk_hitgroupid sessionmturk_hitid

drop survey_qvsr1playerq_10_0_1_01 survey_qvsr1playerid_in_group survey_qvsr1playerrole survey_qvsr1playerpayoff survey_qvsr1groupid_in_subsessio survey_qvsr1subsessionround_numb survey_qvsr1playerq_10_0_1_01

drop trolley1groupid_in_subsession trolley1playerid_in_group trolley1playerpayoff trolley1playerrole trolley1subsessionround_number

drop games_solo1playerlying_decision games_solo1playerlying_die_roll games_solo1playerlying_payoff

drop thankyou1playerid_in_group thankyou1playerrole thankyou1playerpayoff thankyou1groupid_in_subsession thankyou1subsessionround_number

//drop v54 v55 v64 v65 v66 v68

drop login1playerfirst_name login1playerlast_name

*Rename variables
rename redistribute1playerredistribute_ redistribute_partner_dni_a
rename v56 redistribute_partner_name_a
rename v55 redistribute_partner_dni_b
rename v57 redistribute_partner_name_b
rename v58 redistribute_player_decision
rename games_solo1playerknows_redistrib redistribute_knows_partner_a
rename v159 redistribute_knows_partner_b

rename games_solo1playerdictator_decisi dictator_player_decision
rename games_solo1playerdictator_partne dictator_partner_dni
rename games_solo1playerdictator_payoff dictator_player_payoff
rename games_solo1playerknows_dictator_ dictator_knows_partner
rename v155 dictator_partner_name

ren motivated_reasoning1playerapprov motivated_approvguess
ren motivated_reasoning1playerdamage motivated_damage
ren motivated_reasoning1playernews_h motivated_newsh
ren motivated_reasoning1playerfake_n motivated_fakenews
ren motivated_reasoning1playerwould_ motivated_decision
ren motivated_reasoning1playerwant_t motivated_info
rename v191 motivated_approvconfiden
rename v193 motivated_damage_lob 
rename v194 motivated_damage_upb 
rename motivated_reasoning1playertimest motivated_click_arga
rename v199 motivated_click_argb

rename participantpayoff participant_payoff
rename participanttime_started participant_time_started 
rename prize1playerbook participant_book_choice

rename trolley1playertreatment_if_new trolley_treat
rename trolley1playertrolley_decision trolley_decision

ren iat1playert_show_feedback_no_mat iat_show_feedback 
ren iat1playerwant_feedback iat_want_feedback
ren iat1playerfeedback_desire_level iat_feedback_level

//MC -added these renaming
ren iat1playeriat_version iat_version
ren iat1playeriat_score iat_score
ren iat1playeriat_feedback iat_feedback_descriptive
ren iat1playerskip_iat iat_player_skipped

******************************************************
*adding a prefix to mark endline variables
******************************************************
foreach var of varlist * {
	ren `var' en_`var'
}
ren en_DNI DNI

******************************************************
*merging endline file with treatment list
******************************************************

*MC:Added this so it works for PCs and Macs
if c(username)=="ronak" merge 1:1 DNI using "$data\randomization_treatment_endline.dta", force generate(randomizationstatus_merge) //use  for PCs
if c(username)=="mayumicornejo" merge 1:1 DNI using "$data/randomization_treatment_endline.dta", force generate(randomizationstatus_merge) //use for macs

tab randomizationstatus_merge

*drop demographics as baseline will have this merged in already
drop curso-género curso_en-género_en

*drop previosly included randomization status vars as baseline will have this merged in already
drop treat_socratic iat_take_or_not feedback_or_not

*MC: added drop for UG variables and label_iat already included in baseline
drop label_iat label_order_UG proposer order_of_ex acceptance_frame

*MC: renamed merge variable so that it works to indicate who completed the endline. Similar to _merge variable in baseline
ren randomizationstatus_merge en_participant_merge

******************************************************
*merge with baseline data
******************************************************
*MC:Added this so it works for PCs and Macs
if c(username)=="ronak" merge 1:1 DNI using "$data\Clean_Baseline_Data.dta", force generate(baseline_merge) //use  for PCs
if c(username)=="mayumicornejo" merge 1:1 DNI using "$data/Clean_Baseline_Data.dta", force generate(baseline_merge) //use for macs

tab baseline_merge

//MC: add drop baseline_merge, variable not needed
drop baseline_merge

******************************************************
*MC: Define Book variables file of students by course who have completed  
******************************************************

//en_books 
tostring en_participant_book_choice, replace
replace en_participant_book_choice = "Contra la corrupcion" if en_participant_book_choice=="1"
replace en_participant_book_choice = "Derechos feministas y humanos en el Peru" if en_participant_book_choice=="2"
replace en_participant_book_choice = "Hacia la decision justa" if en_participant_book_choice=="3"
replace en_participant_book_choice = "Prueba y Racionalidad de las Decisiones Judiciales" if en_participant_book_choice=="4"

******************************************************
*Create file of students by course who have completed  
******************************************************

gen Estado_de_Cuestionario_en=en_participant_current_app_name 

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

ren Estado_de_Cuestionario_en en_Estado_de_Cuestionario
tab en_Estado_de_Cuestionario
tab bs_Estado_de_Cuestionario en_Estado_de_Cuestionario 

preserve
keep DNI Cargo Curso ApellidoPaterno ApellidoMaterno Nombres NroAula Institución email en_Estado_de_Cuestionario bs_Estado_de_Cuestionario //MC: added bs_Estado_de_Cuestionario
order bs_Estado_de_Cuestionario en_Estado_de_Cuestionario Curso NroAula DNI  ApellidoPaterno ApellidoMaterno Nombres email Cargo Institución  
save "$data/Student completion status_endline.dta", replace
export excel using "$data/Estado de cuestionario_endline.xlsx", sheetreplace firstrow(variables) 
restore

***************************************************************************
**SAVE FULL CLEAN DATA
***************************************************************************

save "$data/Clean_Full_Data.dta", replace

*****************************************************************************CREATE VARIABLES:Match gender/postition to altruism and redistribution game partners 
***************************************************************************

//Prep file of participticipants with gender/position
/*
clear all

use "$data/participant_list_full.dta"

keep DNI Cargo Género

destring DNI, force replace
isid DNI

rename Cargo matched_position
rename Género matched_gender
rename DNI matched_DNI

save "$data/participants_gender_position.dta", replace
clear all

use "$data/Clean_Full_Data.dta"
*/

//Variables for BASELINE dictator/altruism game partner 
cd "$data"
destring bs_dictator_partner_dni, force replace

duplicates report bs_dictator_partner_dni

rename bs_dictator_partner_dni matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI bs_dictator_partner_dni
rename matched_gender bs_dictator_partner_gender
rename matched_position bs_dictator_partner_position
rename _merge bs_dictator_partner_merge

//Variables for ENDLINE dictator/altruism game partner 
destring en_dictator_partner_dni, force replace

duplicates report en_dictator_partner_dni

rename en_dictator_partner_dni matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI en_dictator_partner_dni
rename matched_gender en_dictator_partner_gender
rename matched_position en_dictator_partner_position
rename _merge en_dictator_partner_merge

//Variables for BASELINE redistribution game partner A
destring bs_redistribute_partner_dni_a, force replace

duplicates report bs_redistribute_partner_dni_a

rename bs_redistribute_partner_dni_a matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI bs_redistribute_partner_dni_a
rename matched_gender bs_redistribute_partner_gender_a
rename matched_position bs_redistribute_partner_cargo_a
rename _merge bs_redistribute_partner_merge_a

//Variables for BASELINE redistribution game partner B
destring bs_redistribute_partner_dni_b, force replace

duplicates report bs_redistribute_partner_dni_b

rename bs_redistribute_partner_dni_b matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI bs_redistribute_partner_dni_b
rename matched_gender bs_redistribute_partner_gender_b
rename matched_position bs_redistribute_partner_cargo_b
rename _merge bs_redistribute_partner_merge_b

//Variables for ENDLINE redistribution game partner A
destring en_redistribute_partner_dni_a, force replace

duplicates report en_redistribute_partner_dni_a

rename en_redistribute_partner_dni_a matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI en_redistribute_partner_dni_a
rename matched_gender en_redistribute_partner_gender_a
rename matched_position en_redistribute_partner_cargo_a
rename _merge en_redistribute_partner_merge_a

//Variables for ENDLINE redistribution game partner B
destring en_redistribute_partner_dni_b, force replace

duplicates report en_redistribute_partner_dni_b

rename en_redistribute_partner_dni_b matched_DNI

merge m:1 matched_DNI using participants_gender_position.dta, force  
tab _merge

rename matched_DNI en_redistribute_partner_dni_b
rename matched_gender en_redistribute_partner_gender_b
rename matched_position en_redistribute_partner_cargo_b
rename _merge en_redistribute_partner_merge_b

***************************************************************************
**SAVE FULL CLEAN DATA with NEW VARIABLES
***************************************************************************

save "$data/Clean_Full_Data.dta", replace


/*
********************************************************************************
**MC: EXPORT LIST of VARIABLES & Labels
********************************************************************************

describe, replace
drop vallab format type position

export excel name varlab using "$data/AMAG Data Variable List.xlsx", firstrow(variables) replace
*/

exit


