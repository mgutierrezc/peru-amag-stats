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
di _N

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

drop payment1playeryape_cell_phone_nu -payment1subsessionround_number

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
if c(username)=="Ronak" merge 1:1 DNI using "$data\randomization_treatment_endline.dta", force generate(randomizationstatus_merge) //use  for PCs
if c(username)=="mayumicornejo" merge 1:1 DNI using "$data/randomization_treatment_endline.dta", force generate(randomizationstatus_merge) //use for macs

tab randomizationstatus_merge
//drop randomizationstatus_merge

*drop demographics as baseline will have this merged in already
drop curso-género curso_en-género_en

*drop previosly included randomization status vars as baseline will have this merged in already
drop treat_socratic iat_take_or_not feedback_or_not

*MC: added drop for UG variables and label_iat already included in baseline
drop label_iat label_order_UG proposer

*MC: renamed merge variable so that it works to indicate who completed the endline. Similar to _merge variable in baseline
ren randomizationstatus_merge en_participant_merge

******************************************************
*merge with baseline data
******************************************************
*MC:Added this so it works for PCs and Macs
if c(username)=="Ronak" merge 1:1 DNI using "$data\Clean_Baseline_Data.dta", force generate(baseline_merge) //use  for PCs
if c(username)=="mayumicornejo" merge 1:1 DNI using "$data/Clean_Baseline_Data.dta", force generate(baseline_merge) //use for macs

tab baseline_merge

//MC: add drop baseline_merge, variable not needed
drop baseline_merge

******************************************************
*Create file of students by course who have completed  
******************************************************

rename en_participant_current_app_name Estado_de_Cuestionario_en

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

/*
preserve
keep DNI Cargo Curso ApellidoPaterno ApellidoMaterno Nombres NroAula Institución email en_Estado_de_Cuestionario bs_Estado_de_Cuestionario //MC: added bs_Estado_de_Cuestionario
order bs_Estado_de_Cuestionario en_Estado_de_Cuestionario Curso NroAula DNI  ApellidoPaterno ApellidoMaterno Nombres email Cargo Institución  
save "$data/Student completion status_endline.dta", replace
export excel using "$data/Estado de cuestionario_endline.xlsx", sheetreplace firstrow(variables) 
restore

********************************************************************************
**SAVE FULL CLEAN DATA
********************************************************************************
save "$data/Clean_Full_Data.dta", replace

********************************************************************************
**MC: EXPORT LIST of VARIABLES & Labels
********************************************************************************

describe, replace
drop vallab format type position

export excel name varlab using "$data/AMAG Data Variable List.xlsx", firstrow(variables) replace

exit
*/

******************************************************
**Motivated reasoning ex points system:
******************************************************
*notes from Brian
//In Soles,  the compensation for the first case would have been about S/.2,739,405.56. The exchange rate was 1 USD = 2.80 PEN in 2010, time of the actual resolution.
//In the second one, it was S/. 500.00 (500 soles)

***BASELINE
count if bs_motivated_damage>=2739306 & bs_motivated_damage<=2739506
sum bs_motivated_damage, d
gen bs_motivated_guess_dist = abs(bs_motivated_damage-2739506)
gen bs_motivated_bestguesspoints = .
replace bs_motivated_bestguesspoints = 100 if bs_motivated_damage==2739406
replace bs_motivated_bestguesspoints = 0 if bs_motivated_damage<2739306 | bs_motivated_damage>2739506
replace bs_motivated_bestguesspoints = 100-bs_motivated_guess_dist if bs_motivated_guess_dist<=100

//note: upper bound and lower bound variables have zero observations - but still putting the code here for future
gen bs_motivated_ub_dist = abs(bs_motivated_damage_upb-2739506)
gen bs_motivated_lb_dist = abs(bs_motivated_damage_lob-2739506)
count if bs_motivated_ub_dist<=100
count if bs_motivated_lb_dist<=100
//no one scores for upper or lower bound guesses either as they're over 100 +_ away

//correct guess for fake or real news depends on their guess and the message shown to them
//Note: the variable fakenews was named opposite so the number means prob of true news  
gen bs_motivated_answernewsstat = "Fake News"
replace bs_motivated_answernewsstat = "True News" if ///
(bs_motivated_damage<= 2739506 & bs_motivated_newsh==1) | ///
(bs_motivated_damage>= 2739506 & bs_motivated_newsh==0) 

gen bs_motivated_newspoints = .
replace bs_motivated_newspoints = 0 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==0
replace bs_motivated_newspoints = 19 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==1
replace bs_motivated_newspoints = 36 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==2
replace bs_motivated_newspoints = 51 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==3
replace bs_motivated_newspoints = 64 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==4
replace bs_motivated_newspoints = 75 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==5
replace bs_motivated_newspoints = 84 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==6
replace bs_motivated_newspoints = 91 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==7
replace bs_motivated_newspoints = 96 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==8
replace bs_motivated_newspoints = 99 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==9
replace bs_motivated_newspoints = 100 if bs_motivated_answernewsstat == "True News" & bs_motivated_fakenews==10

replace bs_motivated_newspoints = 0 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==10
replace bs_motivated_newspoints = 19 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==9
replace bs_motivated_newspoints = 36 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==8
replace bs_motivated_newspoints = 51 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==7
replace bs_motivated_newspoints = 64 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==6
replace bs_motivated_newspoints = 75 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==5
replace bs_motivated_newspoints = 84 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==4
replace bs_motivated_newspoints = 91 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==3
replace bs_motivated_newspoints = 96 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==2
replace bs_motivated_newspoints = 99 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==1
replace bs_motivated_newspoints = 100 if bs_motivated_answernewsstat == "Fake News" & bs_motivated_fakenews==0

tab bs_motivated_bestguesspoints
tab bs_motivated_newspoints
recode bs_motivated_bestguesspoints bs_motivated_newspoints (.=0)
gen bs_motivated_total = bs_motivated_bestguesspoints + bs_motivated_newspoints
tab bs_motivated_total

***ENDLINE
count if en_motivated_damage>=400 & en_motivated_damage<=600
sum en_motivated_damage, d
gen en_motivated_guess_dist = abs(en_motivated_damage-500)
gen en_motivated_bestguesspoints = .
replace en_motivated_bestguesspoints = 100 if en_motivated_damage==500
replace en_motivated_bestguesspoints = 0 if en_motivated_damage<400 | en_motivated_damage>600
replace en_motivated_bestguesspoints = 100-en_motivated_guess_dist if en_motivated_guess_dist<=100

//note: upper bound and lower bound variables have zero observations - but still putting the code here for future
gen en_motivated_ub_dist = abs(en_motivated_damage_upb-500)
gen en_motivated_lb_dist = abs(en_motivated_damage_lob-500)
count if en_motivated_ub_dist<=100
count if en_motivated_lb_dist<=100

//correct guess for fake or real news depends on their guess and the message shown to them
//Note: the variable fakenews was named opposite so the number means prob of true news  
gen en_motivated_answernewsstat = "Fake News"
replace en_motivated_answernewsstat = "True News" if ///
(en_motivated_damage<= 500 & en_motivated_newsh==1) | ///
(en_motivated_damage>= 500 & en_motivated_newsh==0) 

gen en_motivated_newspoints = .
replace en_motivated_newspoints = 0 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==0
replace en_motivated_newspoints = 19 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==1
replace en_motivated_newspoints = 36 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==2
replace en_motivated_newspoints = 51 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==3
replace en_motivated_newspoints = 64 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==4
replace en_motivated_newspoints = 75 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==5
replace en_motivated_newspoints = 84 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==6
replace en_motivated_newspoints = 91 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==7
replace en_motivated_newspoints = 96 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==8
replace en_motivated_newspoints = 99 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==9
replace en_motivated_newspoints = 100 if en_motivated_answernewsstat == "True News" & en_motivated_fakenews==10

replace en_motivated_newspoints = 0 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==10
replace en_motivated_newspoints = 19 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==9
replace en_motivated_newspoints = 36 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==8
replace en_motivated_newspoints = 51 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==7
replace en_motivated_newspoints = 64 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==6
replace en_motivated_newspoints = 75 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==5
replace en_motivated_newspoints = 84 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==4
replace en_motivated_newspoints = 91 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==3
replace en_motivated_newspoints = 96 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==2
replace en_motivated_newspoints = 99 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==1
replace en_motivated_newspoints = 100 if en_motivated_answernewsstat == "Fake News" & en_motivated_fakenews==0

tab en_motivated_bestguesspoints
tab en_motivated_newspoints
recode en_motivated_bestguesspoints en_motivated_newspoints (.=0)
gen en_motivated_total = en_motivated_bestguesspoints+ en_motivated_newspoints

tab en_motivated_total
tab bs_motivated_total

//converting to credits by dividing by 10
gen bs_motivated_total_credits = bs_motivated_total/10
gen en_motivated_total_credits = en_motivated_total/10


******************************************************
*Merging results from the ultimatum game from Peter  
******************************************************
if c(username)=="Ronak" merge 1:1 DNI using "$data\payments_ug.dta", force generate(ug_points_merge) //use  for PCs
if c(username)=="mayumicornejo" merge 1:1 DNI using "$data/payments_ug.dta", force generate(ug_points_merge) //use for macs

/*saved directly onto that dataset:
ren dni DNI
ren pay ug_points
tab ug_points
*/

gen en_ug_total_credits = ug_points/100
recode en_ug_total_credits (.=0)

tab en_motivated_total_credits
tab bs_motivated_total_credits
tab en_ug_total_credits

******************************************************
*Picking winners  
******************************************************
*Baseline
preserve 
tab bs_participant_book_choice 
tab bs_participant_book_choice if bs_Estado_de_Cuestionario=="Completo"
replace bs_participant_payoff = bs_participant_payoff+bs_motivated_total_credits  
keep if bs_Estado_de_Cuestionario=="Completo"
svyset [pweight = bs_participant_payoff]
set seed 2038947
keep DNI ApellidoPaterno ApellidoMaterno Nombres Curso Cargo email bs_participant_payoff bs_participant_book_choice
sample 10, count
count
drop bs_participant_payoff
list DNI ApellidoPaterno ApellidoMaterno Nombres
//Note: using Wei's code and Brian's list
//bs_books = {1: 'economics', 2: 'gender', 3: 'morality', 4: 'independence'}
gen bs_books = "" 
replace bs_books = "Justicia, Derecho y Mercado: Una Investigación sobre el Análisis Económico del Derecho bs Perú" if bs_participant_book_choice==1
replace bs_books = "La Investigación bs Derecho con Perspectiva de Género" if bs_participant_book_choice==2
replace bs_books = "Filosofía Pública: bssayos sobre Moral bs Política" if bs_participant_book_choice==3
replace bs_books = "Independencia Judicial: El Espacio de la Discreción" if bs_participant_book_choice==4
save "$data/baseline_winners.dta", replace
export excel using "$data/baseline_winners.xlsx", sheetreplace firstrow(variables) 
restore

//for endline merge with the credits from UG first
preserve 
tab en_participant_book_choice 
tab en_participant_book_choice if en_Estado_de_Cuestionario=="Completo"
keep if en_Estado_de_Cuestionario=="Completo"
replace en_participant_payoff = en_participant_payoff+en_motivated_total_credits+en_ug_total_credits
svyset [pweight = en_participant_payoff]
set seed 203894766
keep DNI ApellidoPaterno ApellidoMaterno Nombres Curso Cargo email en_participant_payoff en_participant_book_choice
sample 10, count
count
drop en_participant_payoff
list DNI ApellidoPaterno ApellidoMaterno Nombres
gen en_books = "" 
replace en_books = "Contra la corrupcion" if en_participant_book_choice==1
replace en_books = "Derechos feministas y humanos en el Peru" if en_participant_book_choice==2
replace en_books = "Hacia la decision justa" if en_participant_book_choice==3
replace en_books = "Prueba y Racionalidad de las Decisiones Judiciales" if en_participant_book_choice==4
save "$data/endline_winners.dta", replace
export excel using "$data/endline_winners.xlsx", sheetreplace firstrow(variables) 
restore




