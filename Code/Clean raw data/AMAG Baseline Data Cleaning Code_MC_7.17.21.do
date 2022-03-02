********************************************************************************
**AMAG cleaning code for baseline raw data and participant list
********************************************************************************

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

********************************************************************************
**Prep participant list file to link with incoming data
********************************************************************************
cd "$roster"
import excel Matriculados_03.06.2021.xlsx, firstrow clear
destring DNI, force replace
isid DNI

drop ResAdmisión TipoIngreso celular correoinstitucional telefono SedeMatricula

if c(username)=="ronak" save "$data\participant_list_full.dta", replace //use  for PCs
if c(username)=="mayumicornejo" save "$data/participant_list_full.dta", replace //use for macs


********************************************************************************
**Prep randomization list file to link with incoming data
********************************************************************************
cd "$roster"
import delimited "rand_peru_list_final.csv", encoding(UTF-8) clear
rename dni DNI
duplicates report DNI
drop apellidomaterno apellidopaterno cargo curso género nombres resadmisión

rename treat_socratic socratic_treated 
rename feedback_or_not iat_feedback_option_or_not //RJ: clarifying that this is whether they got the option to receive the feedback and not whether they actually got it or not so changed the name
rename label_iat iat_treatment_description
rename iat_take_or_not iat_option_take_or_not

if c(username)=="ronak" save "$data\randomization_treatment.dta", replace //use  for PCs
if c(username)=="mayumicornejo" save "$data/randomization_treatment.dta", replace //use for macs

********************************************************************************
**BASELINE  DATA CLEANING
********************************************************************************
*Load data: need to append these 2 datasets for complete baseline data
cd "$data_baseline"
import delimited "all_apps_wide_2021-06-29.csv",  encoding(UTF-8) clear 
gen source="set2"
tempfile set2
save `set2'

import delimited "all_apps_wide_2021-06-14.csv",  encoding(UTF-8) clear 
gen source="set1"
append using `set2' , force 
tab source

*Drop observations without DNI
ren login1playerdni DNI
drop if DNI==.

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

drop games_solo1groupid_in_subsession games_solo1playerid_in_group games_solo1playerrole games_solo1subsessionround_numbe

drop iat1groupid_in_subsession iat1playerbypass_iat iat1playeriat_tables iat1playerid_in_group iat1playerpayoff iat1playerrole iat1subsessionround_number

drop login1groupid_in_subsession login1playerid_in_group login1playerpayoff login1playerrole login1subsessionround_number

drop motivated_reasoning1groupid_in_s motivated_reasoning1playerid_in_ motivated_reasoning1playerpayoff motivated_reasoning1playerrole motivated_reasoning1subsessionro

drop participant_max_page_index participantcode participantid_in_session participantlabel participantmturk_assignment_id participantmturk_worker_id participantvisited 

drop prize1groupid_in_subsession prize1playerid_in_group prize1playerpayoff prize1playerrole prize1subsessionround_number

drop redistribute1groupid_in_subsessi redistribute1playerid_in_group redistribute1playerpayoff redistribute1playerrole redistribute1subsessionround_num 

drop sessioncode sessioncomment sessionconfigmock_exogenous_data sessionconfigparticipation_fee sessionconfigreal_world_currency sessionlabel sessionmturk_hitgroupid sessionmturk_hitid

drop social_eff_2p1groupchosen_alloca social_eff_2p1groupid_in_subsess social_eff_2p1playerid_in_group social_eff_2p1playerpayoff social_eff_2p1playerrole social_eff_2p1subsessionround_nu

drop socratic_video1groupid_in_subses socratic_video1playerid_in_group socratic_video1playerpayoff socratic_video1playerrole socratic_video1subsessionround_n 

drop source 

drop survey_qvsr1groupid_in_subsessio survey_qvsr1playerat_this_time_1 survey_qvsr1playerat_this_time_2 survey_qvsr1playerat_this_time_3 survey_qvsr1playerat_this_time_4 survey_qvsr1playerat_this_time_5 survey_qvsr1playerat_this_time_6 survey_qvsr1playerat_this_time_7 survey_qvsr1playerid_in_group survey_qvsr1playerlg_selected survey_qvsr1playerip survey_qvsr1playerpayoff survey_qvsr1playerq_10_0_1_01 survey_qvsr1playerrole survey_qvsr1playerregion_detecte survey_qvsr1playerthink_of_you_1 survey_qvsr1playerthink_of_you_2 survey_qvsr1playerthink_of_day_1 survey_qvsr1playerthink_of_day_2 survey_qvsr1playerthink_of_day_3 survey_qvsr1playerwork_engagemen survey_qvsr1subsessionround_numb

drop trolley1groupid_in_subsession trolley1playerid_in_group trolley1playerpayoff trolley1playerrole trolley1subsessionround_number

drop v54 v55 v64 v65 v66 v68

drop login1playerfirst_name login1playerlast_name

*Rename variables 
//RJ added and shortened names
ren motivated_reasoning1playerapprov motivated_approvguess
ren motivated_reasoning1playerdamage motivated_damage
ren motivated_reasoning1playernews_h motivated_newsh
ren motivated_reasoning1playerfake_n motivated_fakenews
ren motivated_reasoning1playerwould_ motivated_decision
ren motivated_reasoning1playerwant_t motivated_info
rename v130 motivated_approvconfiden
rename v132 motivated_damage_lob 
rename v133 motivated_damage_upb 
rename motivated_reasoning1playertimest motivated_click_arga //RJ added
rename v138 motivated_click_argb

rename redistribute1playerredistribute_ redistribute_partner_dni_a
rename v79 redistribute_partner_name_a
rename v78 redistribute_partner_dni_b
rename v80 redistribute_partner_name_b
rename v81 redistribute_player_decision
rename games_solo1playerknows_redistrib redistribute_knows_partner_a
rename v92 redistribute_knows_partner_b

rename games_solo1playerdictator_decisi dictator_player_decision
rename games_solo1playerdictator_partne dictator_partner_dni
rename games_solo1playerdictator_payoff dictator_player_payoff
rename games_solo1playerknows_dictator_ dictator_knows_partner
rename v88 dictator_partner_name

rename games_solo1playerlying_decision die_roll_decision
rename games_solo1playerlying_die_roll die_roll_player_roll_value
rename games_solo1playerlying_payoff die_roll_player_payoff

rename participantpayoff participant_payoff
rename participanttime_started participant_time_started 
rename prize1playerbook participant_book_choice

rename trolley1playeris_footbridge trolley_playeris_footbridge 
rename trolley1playeris_men trolley_playeris_men 
rename trolley1playertrolley_decision trolley_decision //RJ shortened name

//RJ additions:
ren iat1playert_show_feedback_no_mat iat_show_feedback 
ren iat1playerwant_feedback iat_want_feedback
ren iat1playerfeedback_desire_level iat_feedback_level
//MC additions
ren iat1playeriat_version iat_version
ren iat1playeriat_score iat_score
ren iat1playeriat_feedback iat_feedback_descriptive
ren iat1playerskip_iat iat_player_skipped

********************************************************************************
*Merging participant and treatment lists
********************************************************************************
cd "$data"
*merging participant list
merge m:1 DNI using participant_list_full.dta, force  
tab _merge

*merging treatment list
merge 1:1 DNI using randomization_treatment.dta, force generate(_merge2)
tab _merge2
drop _merge2

********************************************************************************
*Create relevant variables
********************************************************************************
*Relabel course names
replace Curso = subinstr(Curso, "Curso Especializado a Distancia","",.)

*Create Age variable
des FechaNacimiento
gen Age_decimal = (td(29jun2021) - FechaNacimiento)/365.25 //change baseline date as needed
gen Age_rounded = floor(Age_decimal)

tab Age_rounded if _merge==3, missing
replace Age_rounded=. if Age_rounded<10 //drops a couple of error birthdates in the 2010s

*Crate Trolley treatment variables
//dummies for each of the 4 treatments
gen trolley_footbridge_male=.
replace trolley_footbridge_male=0 if _merge==3
replace trolley_footbridge_male=1 if trolley_playeris_footbridge==1 &trolley_playeris_men==1

gen trolley_footbridge_female=.
replace trolley_footbridge_female=0 if _merge==3
replace trolley_footbridge_female=1 if trolley_playeris_footbridge==1 &trolley_playeris_men==0

gen trolley_bystander_male=.
replace trolley_bystander_male=0 if _merge==3
replace trolley_bystander_male=1 if trolley_playeris_footbridge==0 &trolley_playeris_men==1

gen trolley_bystander_female=.
replace trolley_bystander_female=0 if _merge==3 
replace trolley_bystander_female=1 if trolley_playeris_footbridge==0 &trolley_playeris_men==0

gen trolley_treatment=""
replace trolley_treatment="footbridge_male" if trolley_footbridge_male==1
replace trolley_treatment="footbridge_female" if trolley_footbridge_female==1
replace trolley_treatment="bystander_male" if trolley_bystander_male==1
replace trolley_treatment="bystander_female" if trolley_bystander_female==1

******************************************************
*RJ adding a prefix to mark baseline variables
******************************************************
foreach var of varlist participant_index_in_pages -participant_payoff survey_qvsr1playerqvsr_4-participant_book_choice{
	ren `var' bs_`var'
}

ren _merge bs_participant_merge

ren trolley_bystander_female bs_trolley_bystander_female
ren trolley_bystander_male bs_trolley_bystander_male
ren trolley_footbridge_female bs_trolley_footbridge_female
ren trolley_footbridge_male bs_trolley_footbridge_male
ren trolley_treatment bs_trolley_treatment

******************************************************
*MC: Define Book variables file of students by course who have completed  
******************************************************

//bs_books = {1: 'economics', 2: 'gender', 3: 'morality', 4: 'independence'}
tostring bs_participant_book_choice, replace
replace bs_participant_book_choice = "Justicia, Derecho y Mercado: Una Investigación sobre el Análisis Económico del Derecho en el Perú" if bs_participant_book_choice=="1"
replace bs_participant_book_choice = "La Investigación bs Derecho con Perspectiva de Género" if bs_participant_book_choice=="2"
replace bs_participant_book_choice = "Filosofía Pública: bssayos sobre Moral de la Política" if bs_participant_book_choice=="3"
replace bs_participant_book_choice = "Independencia Judicial: El Espacio de la Discreción" if bs_participant_book_choice=="4"


********************************************************************************
*Create file of students by course who have completed  
********************************************************************************
gen Estado_de_Cuestionario=bs_participant_current_app_name

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
ren Estado_de_Cuestionario bs_Estado_de_Cuestionario

//RJ: changed this here so that we have completion status in the baseline version too 
********************************************************************************
**SAVE BASELINE CLEAN DATA
********************************************************************************
save "$data/Clean_Baseline_Data.dta", replace

********************************************************************************
**EXPORT BASELINE COMPLETION STATUS FILE
********************************************************************************
preserve
keep DNI Cargo Curso ApellidoPaterno ApellidoMaterno Nombres NroAula Institución email bs_Estado_de_Cuestionario
order bs_Estado_de_Cuestionario Curso NroAula DNI  ApellidoPaterno ApellidoMaterno Nombres email Cargo Institución  
save "$data/Student completion status.dta", replace
export excel using "$data/Estado de cuestionario_baseline.xlsx", sheetreplace firstrow(variables) 
restore
exit




