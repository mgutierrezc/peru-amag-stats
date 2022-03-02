****************************************************************
********AMAG 2 Summary Statistics for Baseline and endline data
*******************************************************************

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

*Load Data
use "$data/Clean_Full_Data.dta"

***********************************************
*Information about status of completion
***********************************************

*Baseline/Endline Participant stats, # incomplete, partially complete, complete

tab  bs_Estado_de_Cuestionario 
tab en_Estado_de_Cuestionario

***************************************************
*General Baseline/Endline Summary statistics
**************************************************
//By Curso
tab Curso if bs_participant_merge==3 //participant distribution 
tab Curso if en_participant_merge==3

//Course response rate- Baseline
bys Curso: egen bs_course_size = count(Curso) if Curso!=""
bys Curso: egen bs_total_resp_course = count(DNI) if bs_participant_merge==3
gen bs_resp_rates_course = bs_total_resp_course/bs_course_size
replace bs_resp_rates_course = (bs_resp_rates_course*100)
bys Curso: sum bs_resp_rates_course

//Course response rate- Endline
bys Curso: egen en_course_size = count(Curso) if Curso!=""
bys Curso: egen en_total_resp_course = count(DNI) if en_participant_merge==3
gen en_resp_rates_course = en_total_resp_course/en_course_size
replace en_resp_rates_course = (en_resp_rates_course*100)
bys Curso: sum en_resp_rates_course

//Course balance by gender-Baseline
encode Curso, generate(bs_CursoCoded) 
label values bs_CursoCoded 
tab bs_CursoCoded
tab bs_CursoCoded if bs_participant_merge==3

catplot  Género bs_CursoCoded if bs_participant_merge==3, recast(bar) title("Number of Participants by Course & Gender") ytitle ("") var1opts(relabel(1"Fem" 2 "Mas"))var2opts(label(labsize(*.7) ang(45)) relabel(1 "ControlConvencionalidad" 2 "InterpretaciónConstitucional" 3 "Jurisprudencia.." 4 "Razonamiento.." 5 "Virtudes y principios" 6 "Ética jurídica..."))

//Course balance by gender-Endline
encode Curso, generate(en_CursoCoded) 
label values en_CursoCoded 
tab en_CursoCoded
tab en_CursoCoded if en_participant_merge==3

catplot  Género en_CursoCoded if en_participant_merge==3, recast(bar) title("Number of Participants by Course & Gender") ytitle ("") var1opts(relabel(1"Fem" 2 "Mas"))var2opts(label(labsize(*.7) ang(45)) relabel(1 "ControlConvencionalidad" 2 "InterpretaciónConstitucional" 3 "Jurisprudencia.." 4 "Razonamiento.." 5 "Virtudes y principios" 6 "Ética jurídica..."))

//MC-Course balance by role-Baseline
label define order3 1 "ControlConvencionalidad" 2 "InterpretaciónConstitucional" 3 "Jurisprudencia.." 4 "Razonamiento.." 5 "Virtudes y principios" 6 "Ética jurídica..."
label values bs_CursoCoded order3
catplot  Cargo if bs_participant_merge==3, by(bs_CursoCoded) recast(bar) ytitle("Frequency")

//MC-Course balance by role-Endline
label values en_CursoCoded order3
catplot  Cargo if en_participant_merge==3, by(en_CursoCoded) recast(bar) ytitle("Frequency")

*Participants by gender balance-Baseline/Endline
gen gender_male=. // gender dummy
replace gender_male=0 if Género!=""
replace gender_male=1 if Género=="Masculino"

tab Género
tab Género if bs_participant_merge==3

tab Género if en_participant_merge==3

*by role/position balance Baseline/Endline
tab Cargo
tab Cargo if bs_participant_merge==3 

tab Cargo if en_participant_merge==3 

*Graph gender/role Baseline
catplot  Género if bs_participant_merge==3, over(Cargo) recast(bar) title("Number of Participants by Gender and Role") ytitle ("") var1opts(relabel(1"Fem" 2 "Mas"))

*Graph gender/role Endline
catplot  Género if en_participant_merge==3, over(Cargo) recast(bar) title("Number of Participants by Gender and Role") ytitle ("") var1opts(relabel(1"Fem" 2 "Mas"))

*Graphs by Age- Baseline
hist Age_rounded if bs_participant_merge==3, wi(1) freq title("Participant Age Distribution") ytitle("Frequency") xtitle("Age")

hist Age_rounded if bs_participant_merge==3, by(Cargo) wi(1) freq  ytitle("Frequency") xtitle("Age") 

graph bar Age_rounded if bs_participant_merge==3, over(Cargo) ytitle("Age") title("Mean Age  by Role")

hist Age_rounded if bs_participant_merge==3, by(Cargo Género) wi(1) freq  ytitle("Frequency") xtitle("Age") 

graph bar Age_rounded if bs_participant_merge==3, over(Género) ytitle("Age") title("Mean Age  by Gender")

*Graphs by Age- Endline
hist Age_rounded if en_participant_merge==3, wi(1) freq title("Participant Age Distribution") ytitle("Frequency") xtitle("Age")

hist Age_rounded if en_participant_merge==3, by(Cargo) wi(1) freq  ytitle("Frequency") xtitle("Age") 

graph bar Age_rounded if en_participant_merge==3, over(Cargo) ytitle("Age") title("Mean Age  by Role")

hist Age_rounded if en_participant_merge==3, by(Cargo Género) wi(1) freq  ytitle("Frequency") xtitle("Age") 

graph bar Age_rounded if en_participant_merge==3, over(Género) ytitle("Age") title("Mean Age  by Gender")

*dummies
gen judge=.
replace judge=0 if Cargo!=""
replace judge=1 if Cargo=="JUEZ"

gen prosecutor=.
replace prosecutor=0 if Cargo!=""
replace prosecutor=1 if Cargo=="FISCAL"

gen asis=.
replace  asis=0 if Cargo!=""
replace asis=1 if Cargo=="ASIS"

*********************************************
*TROLLEY Exercise Summary statistics
*********************************************

*Trolley treatment assignment balance
//Baseline
tab bs_trolley_treatment //Those who completed baseline were assigned the same treatment at endline

//Endline
gen en_trolley_treatment=""
replace en_trolley_treatment=en_trolley_treat if en_trolley_treat!="" & en_trolley_decision!=.
replace en_trolley_treatment=bs_trolley_treatment if en_trolley_decision!=. & bs_trolley_decision!=.
tab en_trolley_treatment 

//Decisions by treatment types- BASELINE
tab bs_trolley_treatment bs_trolley_decision, row column 

graph bar bs_trolley_decision, over(bs_trolley_treatment) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment")

graph bar bs_trolley_decision, over(bs_trolley_treatment, label(angle(45))) over(Género) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Gender") 

graph bar bs_trolley_decision, over(bs_trolley_treatment, label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Judge Role") 

graph bar bs_trolley_decision, over(bs_trolley_treatment, label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Prosecutor Role") 

//Decisions by treatment types- ENDLINE
tab en_trolley_treatment en_trolley_decision, row column 

graph bar en_trolley_decision, over(en_trolley_treatment) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment")

graph bar en_trolley_decision, over(en_trolley_treatment, label(angle(45))) over(Género) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Gender") 

graph bar en_trolley_decision, over(en_trolley_treatment, label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Judge Role") 

graph bar en_trolley_decision, over(en_trolley_treatment, label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment and Prosecutor Role") 

//Decisions by female vs. male treatments (tiny gender bias)-BASELINE
tab bs_trolley_decision bs_trolley_playeris_men, column

graph bar bs_trolley_decision, over(bs_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type")

graph bar bs_trolley_decision, over(bs_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment") label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Judge Role")

graph bar bs_trolley_decision, over(bs_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment") label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Prosecutor Role")

//Decisions by female vs. male treatments -ENDLINE
*Create relevant variable
gen en_trolley_playeris_men=.
replace en_trolley_playeris_men=0 if en_trolley_treatment!="" & en_trolley_decision!=.
replace en_trolley_playeris_men=1 if en_trolley_treatment=="bystander_male" & en_trolley_decision!=.
replace en_trolley_playeris_men=1 if en_trolley_treatment=="footbridge_male" & en_trolley_decision!=.

tab en_trolley_decision en_trolley_playeris_men, column

graph bar en_trolley_decision, over(en_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type")

graph bar en_trolley_decision, over(en_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment") label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Judge Role")

graph bar en_trolley_decision, over(en_trolley_playeris_men, relabel(1"Female Trolley Treatment" 2"Male Trolley Treatment") label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Prosecutor Role")

//Decisions by footbridge vs. bystander-BASELINE
tab bs_trolley_decision bs_trolley_playeris_footbridge, column

graph bar bs_trolley_decision, over(bs_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type")

graph bar bs_trolley_decision, over(bs_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment") label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Judge Role")

graph bar bs_trolley_decision, over(bs_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment") label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Prosecutor Role")

//Decisions by footbridge vs. bystander-ENDLINE
*Create relevant variable
gen en_trolley_playeris_footbridge=.
replace en_trolley_playeris_footbridge=0 if en_trolley_treatment!="" & en_trolley_decision!=.
replace en_trolley_playeris_footbridge=1 if en_trolley_treatment=="footbridge_female" & en_trolley_decision!=.
replace en_trolley_playeris_footbridge=1 if en_trolley_treatment=="footbridge_male" & en_trolley_decision!=.

tab en_trolley_decision en_trolley_playeris_footbridge, column

graph bar en_trolley_decision, over(en_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type")

graph bar en_trolley_decision, over(en_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment") label(angle(45))) over(judge, relabel(1"Non-Judges" 2"Judges")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Judge Role")

graph bar en_trolley_decision, over(en_trolley_playeris_footbridge, relabel(1"Bystander Treatment" 2"Footbridge Treatment") label(angle(45))) over(prosecutor, relabel(1"Non-Prosecutor" 2"Prosecutor")) ytitle("Mean Trolley Decision- Permissible") title("Trolley Decisions by Treatment Type and Prosecutor Role")

//Decisions by participant gender and treatment-BASELINE
tab Género bs_trolley_decision, row 
bys bs_trolley_playeris_footbridge Género : tab  bs_trolley_decision
bys bs_trolley_playeris_men Género : tab  bs_trolley_decision
bys bs_trolley_treatment: tab Género bs_trolley_decision, row  

//Decisions by participant gender and treatment-ENDLINE
tab Género en_trolley_decision, row 
bys en_trolley_playeris_footbridge Género : tab  en_trolley_decision
bys en_trolley_playeris_men Género : tab  en_trolley_decision
bys en_trolley_treatment: tab Género en_trolley_decision, row  

//Decisions by participant role- BASELINE
bys Cargo: tab bs_trolley_decision
bys bs_trolley_treatment: tab judge bs_trolley_decision if bs_participant_merge
bys bs_trolley_treatment: tab prosecutor bs_trolley_decision if bs_participant_merge

//Decisions by participant role- ENDLINE
bys Cargo: tab en_trolley_decision
bys en_trolley_treatment: tab judge en_trolley_decision if en_participant_merge
bys en_trolley_treatment: tab prosecutor en_trolley_decision if en_participant_merge

//Decisions by age-ENDLINE
label define order2 0 "Not Permissible" 1 "Permissible" 
label values bs_trolley_decision order2

hist Age_rounded if bs_participant_merge==3, by(bs_trolley_decision) wi(1) freq  ytitle("Frequency") xtitle("Age")

hist Age_rounded if bs_participant_merge==3, by(Cargo bs_trolley_decision) wi(1) freq  ytitle("Frequency") xtitle("Age")

//Decisions by age-ENDLINE
label values en_trolley_decision order2

hist Age_rounded if en_participant_merge==3, by(en_trolley_decision) wi(1) freq  ytitle("Frequency") xtitle("Age")

hist Age_rounded if en_participant_merge==3, by(Cargo en_trolley_decision) wi(1) freq  ytitle("Frequency") xtitle("Age")

**************************************************
*IAT Exercise Summary statistics-BASELINE
*****************************************************

//First node-randomization:option to take IAT or not
tab iat_option_take_or_not if bs_participant_merge==3

//Upper branch 2nd node: take or skip IAT
tab bs_iat_player_skipped if bs_participant_merge==3, missing //breakdown of who chose to take IAT including missing (i.e. lower branch)
bys bs_iat_player_skipped: tab Cargo gender_male if bs_participant_merge==3

//RJ
graph bar bs_iat_player_skipped  , over(gender_male, relabel(1" Female" 2"Male"))  ytitle("% who choose to skip IAT") title("% of participants by gender who choose to skip IAT")

graph bar bs_iat_player_skipped, over(Cargo) ytitle("% who choose to skip IAT") title("% of participants by role who choose to skip IAT")

graph bar bs_iat_player_skipped, over(gender_male, relabel(1" Female" 2"Male")) over(Cargo) ytitle("% who choose to skip IAT") title("% of participants by gender and role who choose to skip IAT")

//feedback desire level distribution
tab bs_iat_feedback_level
bys Cargo: sum bs_iat_feedback_level
bys gender_male: sum bs_iat_feedback_level
//RJ
catplot Cargo if bs_participant_merge==3, by(bs_iat_feedback_level) recast(bar) perc ytitle("Desire level of IAT feedback by role") 

catplot Género if bs_participant_merge==3, by(bs_iat_feedback_level) recast(bar) perc ytitle("Desire level of IAT feedback by gender")  

//MC
binscatter bs_iat_feedback_level Age_rounded if bs_participant_merge==3, ytitle ("IAT feedback desire level") xtitle("Age")

binscatter bs_iat_feedback_level Age_rounded if judge==1 & bs_participant_merge==3, ytitle ("IAT feedback desire level") xtitle("Age") title("Desire level for judges")

binscatter bs_iat_feedback_level Age_rounded if prosecutor==1 & bs_participant_merge==3, ytitle ("IAT feedback desire level") xtitle("Age") title("Desire level for prosecutors")

//Whether participant wants feedback 
tab bs_iat_want_feedback if bs_participant_merge==3, missing

//Option to IAT vs. got feedback
tab  iat_option_take_or_not bs_iat_show_feedback if bs_participant_merge==3, row

//wants feedback vs. got feedback
tab bs_iat_want_feedback bs_iat_show_feedback if bs_participant_merge==3, missing

catplot bs_iat_want_feedback if bs_participant_merge==3, by(Cargo)  perc ytitle("% who want IAT feedback by role")  var1opts(relabel(1"Dont want" 2 "Want"))

catplot bs_iat_want_feedback if bs_participant_merge==3, by(Género) perc  ytitle("% who want IAT feedback by gender") var1opts(relabel(1"Dont want" 2 "Want"))

tab bs_iat_show_feedback iat_option_take_or_not if iat_option_take_or_not==1 & bs_participant_merge==3

//Feedback for IAT option, took IAT, didn't get feedback: shows participants who got stuck
tab bs_iat_want_feedback if bs_iat_player_skipped==0 & bs_iat_show_feedback==0 & bs_participant_merge==3 & iat_option_take_or_not==1, missing 

tab bs_participant_index_in_pages if  bs_iat_player_skipped==0 & bs_iat_show_feedback==0 & bs_participant_merge==3 & iat_option_take_or_not==1, missing //page index ->  & iat1playeriat_feedback==""  - shows some stuck on screen 12

tab bs_participant_current_app_name if bs_iat_player_skipped==0 & bs_iat_show_feedback==0 & bs_participant_merge==3 & iat_option_take_or_not==1, missing //exercise name

//How many people got the error: randomization didn't happen, people ended on the IAT screen 
tab bs_participant_index_in_pages if bs_iat_player_skipped==0 & bs_iat_show_feedback==0 & bs_participant_merge==3 & iat_option_take_or_not==1, missing 

//IAT scores
bys Cargo: sum bs_iat_score if bs_participant_merge==3
bys gender_male: sum bs_iat_score
//RJ:
graph hbar bs_iat_score, over(Cargo) ytitle("IAT score") title("Mean IAT scores by Role")

graph hbar bs_iat_score, over(Género) ytitle("IAT score") title("Mean IAT scores by Gender")

//MC
binscatter bs_iat_score Age_rounded if bs_participant_merge==3, ytitle ("IAT score") xtitle("Age") 
binscatter bs_iat_score Age_rounded if gender_male==0 & bs_participant_merge==3, ytitle ("IAT score") xtitle("Age") title (IAT Scores for Women)
binscatter bs_iat_score Age_rounded if gender_male==1 & bs_participant_merge==3, ytitle ("IAT score") xtitle("Age")  title (IAT Scores for Men)

reg  bs_iat_score gender_male Age_rounded  prosecutor asis judge if bs_participant_merge==3, r

********************************************************
*DICE ROLL Exercise Summary statistics/ BASELINE ONLY 
*******************************************************
//Distribution of dice roll vs. decision
tab  bs_die_roll_player_roll_value bs_die_roll_decision

//Dice liar dummy, only 2 liars
gen bs_dice_liar=.
replace bs_dice_liar=0 if bs_participant_merge==3 & bs_die_roll_decision!=.
replace bs_dice_liar=1 if bs_die_roll_player_roll_value!=bs_die_roll_decision
tab bs_dice_liar

//who lied: male prosecutor and assistant
bys Cargo : tab bs_dice_liar gender_male

**********************************************************
*MOTIVATED REASONING Exercise Summary statistics-BASELINE
***********************************************************

//Initial guess vs. fake news chance
//RJ: The way the question was asked the values probably capture the chance it was true news
tab bs_motivated_fakenews if bs_participant_merge==3, missing 
gen bs_motivated_reasoner=.
replace bs_motivated_reasoner=0 if bs_motivated_fakenews==5 & bs_participant_merge==3 
replace bs_motivated_reasoner =1 if bs_motivated_fakenews!=. & bs_motivated_fakenews!=5 & bs_participant_merge==3
tab bs_motivated_reasoner
tab bs_motivated_reasoner bs_motivated_fakenews

gen bs_motivated_reasoner_intensity =.
replace bs_motivated_reasoner_intensity=abs(5-bs_motivated_fakenews) if bs_motivated_fakenews!=. & bs_participant_merge==3
tab bs_motivated_reasoner_intensity

hist bs_motivated_fakenews, wi(1) discrete percent
graph bar bs_motivated_reasoner, over(Género) 
graph bar bs_motivated_reasoner, over(Cargo) 
graph bar bs_motivated_reasoner, over(Curso) 


hist bs_motivated_reasoner_intensity, by(Género) wi(1) discrete freq
hist bs_motivated_reasoner_intensity, by(Cargo) wi(1) discrete freq
hist bs_motivated_reasoner_intensity, by(Curso) wi(1) discrete freq

graph bar bs_motivated_reasoner_intensity, over(Cargo) 
graph bar bs_motivated_reasoner_intensity, over(Curso) 

//RJ:
orth_out bs_motivated_reasoner, by(Curso) pcompare stars se
orth_out bs_motivated_reasoner, by(Cargo) pcompare stars se
orth_out bs_motivated_reasoner, by(judge) pcompare stars se
orth_out bs_motivated_reasoner, by(prosecutor) pcompare stars se
orth_out bs_motivated_reasoner, by(Género) pcompare stars se //significant

//Fake news and message (higher or lower)
bys bs_motivated_newsh: tab bs_motivated_fakenews
//RJ:
orth_out bs_motivated_fakenews, by(bs_motivated_newsh) pcompare stars se

//RJ: confirmation bias
//initial guess and final decision
tab bs_motivated_approvguess bs_motivated_decision, row 
//RJ: need to check with Chris about what 0/1 represents coding
catplot bs_motivated_decision, by(bs_motivated_approvguess) recast(bar)

//RJ: which arguments browsed by initial guess //check with Chris which is link X and A and how to convert to time spent as don't know which link clicked or clicked at all
orth_out bs_motivated_click_arga, by(bs_motivated_approvguess) pcompare stars se
orth_out bs_motivated_click_argb, by(bs_motivated_approvguess) pcompare stars se

//RJ: want to learn or not
tab bs_motivated_info if bs_participant_merge==3
tab  bs_motivated_reasoner bs_motivated_info, row
tab bs_motivated_reasoner_intensity bs_motivated_info, row //less at tails 
tab Curso bs_motivated_info , row nofreq
tab Género bs_motivated_info , row nofreq
tab Cargo bs_motivated_info , row nofreq
tab bs_motivated_approvguess bs_motivated_info , row nofreq
tab bs_motivated_decision bs_motivated_info , row nofreq

************************************************
*SOCRATIC Exercise Summary statistics-BASELINE
************************************************
*Socratic////balance- need to check with Chris which screen number corresponds to the socratic video 
//RJ: it's screen 16
tab socratic_treated
tab socratic_treated if bs_participant_merge==3 & bs_participant_index_in_pages>=16 
tab socratic_treated if bs_participant_merge==3 & bs_participant_index_in_pages>16 

************************************************
*PAYOFFS Exercise Summary statistics-BASELINE
************************************************
tab bs_participant_payoff

//by gender
bys gender_male: sum bs_participant_payoff 

//by role
bys Cargo: sum bs_participant_payoff





