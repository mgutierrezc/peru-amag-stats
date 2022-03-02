**************************************************************
**AMAG 2: Summary Stats fo redistribution, altruism, and IAT
**************************************************************

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

*******************

use "$data/Clean_Full_Data.dta"

*********************************************************
*Gen control variables
*********************************************************
gen judge=.
replace judge=0 if Cargo!=""
replace judge=1 if Cargo=="JUEZ"

gen prosecutor=.
replace prosecutor=0 if Cargo!=""
replace prosecutor=1 if Cargo=="FISCAL"

gen asis=.
replace  asis=0 if Cargo!=""
replace asis=1 if Cargo=="ASIS"

gen men=.
replace men=0 if Género!=""
replace men=1 if Género=="Masculino"
*********************************************************
*DICTATOR GAME
*********************************************************
//BASELINE
*Particpant Distribution of decision, no tail here
tab bs_dictator_player_decision 

*Does player know partner, only 13 participants do
tab bs_dictator_knows_partner

*Graphs of participant decisions by gender, position, age
graph hbar bs_dictator_player_decision, over(Cargo) ytitle("# of credits (out of 10) allocated to participant") title("Mean Altruism Decisions by Role")

graph hbar bs_dictator_player_decision, over(Género) ytitle("# of credits (out of 10) allocated to participant") title("Mean Altruism Decisions by Gender")

binscatter bs_dictator_player_decision Age_rounded if bs_participant_merge==3, ytitle("# of credits (out of 10) participant kept") xtitle("Age")

binscatter bs_dictator_player_decision Age_rounded if bs_participant_merge==3 & men==0, ytitle("# of credits (out of 10) participant kept") xtitle("Age") title(Altruism decisions of women)

binscatter bs_dictator_player_decision Age_rounded if bs_participant_merge==3 & men==1, ytitle("# of credits (out of 10) participant kept") xtitle("Age") title(Altruism decisions of men)

reg  bs_dictator_player_decision Age_rounded men prosecutor asis judge if bs_participant_merge==3, r

//ENDLINE
*Particpant Distribution of decision
tab en_dictator_player_decision 

*Does player know partner, 
tab en_dictator_knows_partner

*Graphs of participant decisions by gender, position, age
graph hbar en_dictator_player_decision, over(Cargo) ytitle("# of credits (out of 10) allocated to participant") title("Mean Altruism Decisions by Role")

graph hbar en_dictator_player_decision, over(Género) ytitle("# of credits (out of 10) allocated to participant") title("Mean Altruism Decisions by Gender")

binscatter en_dictator_player_decision Age_rounded if en_participant_merge==3, ytitle("# of credits (out of 10) participant kept") xtitle("Age")

binscatter en_dictator_player_decision Age_rounded if en_participant_merge==3 & men==0, ytitle("# of credits (out of 10) participant kept") xtitle("Age") title(Altruism decisions of women)

binscatter en_dictator_player_decision Age_rounded if en_participant_merge==3 & men==1, ytitle("# of credits (out of 10) participant kept") xtitle("Age") title(Altruism decisions of men)

reg  en_dictator_player_decision Age_rounded men prosecutor asis judge if en_participant_merge==3, r


//Analysis based on whether participant had female or male partner
*Baseline
tab bs_dictator_partner_gender bs_dictator_partner_position if bs_dictator_player_decision!=.

tab bs_dictator_player_decision bs_dictator_partner_gender if bs_dictator_player_decision!=.

tab bs_dictator_player_decision bs_dictator_partner_gender if bs_dictator_player_decision!=. & Género=="Masculino"

tab bs_dictator_player_decision bs_dictator_partner_gender if bs_dictator_player_decision!=. & Género=="Femenino"

*Endline
tab en_dictator_partner_gender en_dictator_partner_position if en_dictator_player_decision!=.

tab en_dictator_player_decision en_dictator_partner_gender if bs_dictator_player_decision!=.

tab en_dictator_player_decision en_dictator_partner_gender if bs_dictator_player_decision!=. & Género=="Masculino"

tab en_dictator_player_decision en_dictator_partner_gender if en_dictator_player_decision!=. & Género=="Femenino"

//Graphs Baseline
catplot bs_dictator_player_decision if bs_dictator_player_decision!=., over (bs_dictator_partner_gender) recast(bar)

catplot bs_dictator_player_decision if bs_dictator_player_decision!=. & Género=="Masculino", over (bs_dictator_partner_gender) recast(bar)

catplot bs_dictator_player_decision if bs_dictator_player_decision!=. & Género=="Femenino", over (bs_dictator_partner_gender) recast(bar)

//Graphs Endline
catplot en_dictator_player_decision if en_dictator_player_decision!=., over (en_dictator_partner_gender) recast(bar)

catplot en_dictator_player_decision if en_dictator_player_decision!=. & Género=="Masculino", over (en_dictator_partner_gender) recast(bar)

catplot en_dictator_player_decision if en_dictator_player_decision!=. & Género=="Femenino", over (en_dictator_partner_gender) recast(bar)


*********************************************************
*REDISTRIBUTION GAME
*********************************************************

//Distribution of decisions, tail dues to slider set up in survey? - variable shows number of credits allocated to partner A
tab bs_redistribute_player_decision if bs_participant_merge==3 //Baseline 
tab en_redistribute_player_decision if en_participant_merge==3 //Baseline

//Player knows partners? Most didn't
*Baseline
tab bs_redistribute_knows_partner_a bs_redistribute_knows_partner_b

*Endline
tab en_redistribute_knows_partner_a en_redistribute_knows_partner_b

//Participant Decisions based on gender and role
*Baseline
destring bs_redistribute_player_decision, replace
graph hbar bs_redistribute_player_decision, over(Cargo) ytitle("# of credits (out of 10) allocated to Partner A") title("Mean Redistribution Decisions by Role") 

graph hbar bs_redistribute_player_decision, over(Género) ytitle("# of credits (out of 10) allocated to Partner A") title("Mean Redistribution Decisions by Gender")

binscatter bs_redistribute_player_decision Age_rounded if bs_participant_merge==3, ytitle("# of credits (out of 10) allocated to Partner A") xtitle("Age")

*Endline
destring en_redistribute_player_decision, replace
graph hbar en_redistribute_player_decision, over(Cargo) ytitle("# of credits (out of 10) allocated to Partner A") title("Mean Redistribution Decisions by Role") 

graph hbar en_redistribute_player_decision, over(Género) ytitle("# of credits (out of 10) allocated to Partner A") title("Mean Redistribution Decisions by Gender")

binscatter en_redistribute_player_decision Age_rounded if en_participant_merge==3, ytitle("# of credits (out of 10) allocated to Partner A") xtitle("Age")

//Analysis on whether participants had to choose between same gender partners or different genders
//BASELINE
//variable for both partners are female
gen bs_redistribute_partners_female=.

replace bs_redistribute_partners_female=0 if bs_redistribute_player_decision!=.

replace bs_redistribute_partners_female=1 if bs_redistribute_partner_gender_a=="Femenino" & bs_redistribute_partner_gender_b=="Femenino" & bs_redistribute_player_decision!=.

//variable for both partners are male
gen bs_redistribute_partners_male=.

replace bs_redistribute_partners_male=0 if bs_redistribute_player_decision!=.

replace bs_redistribute_partners_male=1 if bs_redistribute_partner_gender_a=="Masculino" & bs_redistribute_partner_gender_b=="Masculino" & bs_redistribute_player_decision!=.

//variable for female partner and male partner 

*variable indicator for partner A male and partner B female
gen bs_redistribure_MF_partners=.
replace bs_redistribure_MF_partners=1 if bs_redistribute_partner_gender_a=="Masculino" & bs_redistribute_partner_gender_b=="Femenino" & bs_redistribute_player_decision!=.

*calculate number of credits awarded to females when partner A male and partner B female
gen bs_redistribute_decision_MF=.
replace bs_redistribute_decision_MF= bs_redistribute_player_decision if bs_redistribure_MF_partners==1 & bs_redistribute_player_decision!=.
replace bs_redistribute_decision_MF=10-bs_redistribute_player_decision if bs_redistribute_decision_MF!=.

*generate variable for # of credits awarded to female partner for mixed partnerships
gen bs_redistribute_decision_mixed=.
replace bs_redistribute_decision_mixed=bs_redistribute_player_decision if bs_redistribute_partner_gender_a=="Femenino" & bs_redistribute_partner_gender_b=="Masculino" & bs_redistribute_player_decision!=.
replace bs_redistribute_decision_mixed=bs_redistribute_decision_MF if bs_redistribure_MF_partners==1

drop bs_redistribute_decision_MF bs_redistribure_MF_partners

*indicator variable for mixed partnerships
gen bs_redistribute_partners_mixed=.
replace bs_redistribute_partners_mixed=0 if bs_redistribute_player_decision!=.

replace bs_redistribute_partners_mixed=1 if bs_redistribute_decision_mixed!=.

//graphs overall comparison by gender
*female partners
catplot bs_redistribute_player_decision if bs_redistribute_player_decision!=. &bs_redistribute_partners_female==1, over (Género) recast(bar) title("Female partners (credits allocated to partner A by Participant Gender)", span size(medium))

*male partners
catplot bs_redistribute_player_decision if bs_redistribute_player_decision!=. & bs_redistribute_partners_male==1, over (Género) recast(bar) title("Male partners (credits allocated to partner A by Participant Gender)", span size(medium))

*mixed partners
catplot bs_redistribute_decision_mixed if bs_redistribute_decision_mixed!=. & bs_redistribute_partners_mixed==1, over (Género) recast(bar) title("Mixed partners (credits allocated to female partner by Participant Gender)", span size(medium))

ttest bs_redistribute_decision_mixed, by(Género )

//ENDLINE
//variable for both partners are female
gen en_redistribute_partners_female=.

replace en_redistribute_partners_female=0 if en_redistribute_player_decision!=.

replace en_redistribute_partners_female=1 if en_redistribute_partner_gender_a=="Femenino" & en_redistribute_partner_gender_b=="Femenino" & en_redistribute_player_decision!=.

//variable for both partners are male
gen en_redistribute_partners_male=.

replace en_redistribute_partners_male=0 if en_redistribute_player_decision!=.

replace en_redistribute_partners_male=1 if en_redistribute_partner_gender_a=="Masculino" & en_redistribute_partner_gender_b=="Masculino" & en_redistribute_player_decision!=.

//variable for female and male partner
*variable indicator for partner A male and partner B female
gen en_redistribure_MF_partners=.
replace en_redistribure_MF_partners=1 if en_redistribute_partner_gender_a=="Masculino" & en_redistribute_partner_gender_b=="Femenino" & en_redistribute_player_decision!=.

*calculate number of credits awarded to females when partner A male and partner B female
gen en_redistribute_decision_MF=.
replace en_redistribute_decision_MF= en_redistribute_player_decision if en_redistribure_MF_partners==1 & en_redistribute_player_decision!=.
replace en_redistribute_decision_MF=10-en_redistribute_player_decision if en_redistribute_decision_MF!=.

*generate variable for # of credits awarded to female partner for mixed partnerships
gen en_redistribute_decision_mixed=.
replace en_redistribute_decision_mixed=en_redistribute_player_decision if en_redistribute_partner_gender_a=="Femenino" & en_redistribute_partner_gender_b=="Masculino" & en_redistribute_player_decision!=.
replace en_redistribute_decision_mixed=en_redistribute_decision_MF if en_redistribure_MF_partners==1

drop en_redistribute_decision_MF en_redistribure_MF_partners

*indicator variable for mixed partnerships
gen en_redistribute_partners_mixed=.
replace en_redistribute_partners_mixed=0 if en_redistribute_player_decision!=.

replace en_redistribute_partners_mixed=1 if en_redistribute_decision_mixed!=.


//graphs overall comparison by gender
*female partners
catplot en_redistribute_player_decision if en_redistribute_player_decision!=. &en_redistribute_partners_female==1, over (Género) recast(bar) title("Female partners (credits allocated to partner A by Participant Gender)", span size(medium))

*male partners
catplot en_redistribute_player_decision if en_redistribute_player_decision!=. & en_redistribute_partners_male==1, over (Género) recast(bar) title("Male partners (credits allocated to partner A by Participant Gender)", span size(medium))

*mixed partners
catplot en_redistribute_decision_mixed if en_redistribute_decision_mixed!=. & en_redistribute_partners_mixed==1, over (Género) recast(bar) title("Mixed partners (credits allocated to female partner by Participant Gender)", span size(medium))

ttest en_redistribute_decision_mixed, by(Género )

*********************************************************
*IAT SCORES
*********************************************************
//Indicator for participants who completed base and endline IAT

gen bs_en_completed_iat=.
replace bs_en_completed_iat=0 if bs_iat_score==. & en_iat_score!=.
replace bs_en_completed_iat=0 if en_iat_score==. & bs_iat_score!=.
replace bs_en_completed_iat=1 if en_iat_score!=. & bs_iat_score!=.

tab   Cargo  if bs_en_completed_iat==1
tab   Género  if bs_en_completed_iat==1
tab   Curso  if bs_en_completed_iat==1

//Dummy Variable for all iat scores that overall got less biased (closer to 0)

gen bs_iat_score_ov_improve=.
replace bs_iat_score_ov_improve=0 if bs_en_completed_iat==1
replace bs_iat_score_ov_improve=1 if bs_iat_score<en_iat_score & en_iat_score<0 & bs_en_completed_iat==1
replace bs_iat_score_ov_improve=1 if bs_iat_score>en_iat_score & en_iat_score>0 & bs_en_completed_iat==1
tab bs_iat_score_ov_improve

tab   Cargo  if bs_iat_score_ov_improve==1
tab   Género  if bs_iat_score_ov_improve==1
tab   Curso  if bs_iat_score_ov_improve==1

//Dummy Variable for iat scores that started negative and got less biased (closer to 0)
gen bs_iat_score_neg_improve=.
replace bs_iat_score_neg_improve=0 if bs_en_completed_iat==1
replace bs_iat_score_neg_improve=1 if bs_iat_score<en_iat_score & en_iat_score<0 & bs_en_completed_iat==1

//Dummy Variable for all iat scores that overall got more biased (away from 0)
gen bs_iat_score_ov_worse=.
replace bs_iat_score_ov_worse=0 if bs_en_completed_iat==1
replace bs_iat_score_ov_worse=1 if bs_iat_score>en_iat_score & bs_iat_score<0 & bs_en_completed_iat==1
replace bs_iat_score_ov_worse=1 if bs_iat_score<en_iat_score & bs_iat_score>0 & bs_en_completed_iat==1

tab   Cargo  if bs_iat_score_ov_worse==1
tab   Género  if bs_iat_score_ov_worse==1
tab   Curso  if bs_iat_score_ov_worse==1

//Dummy Variable for iat scores that started negative and got more biased (away from 0)
gen bs_iat_score_neg_worse=.
replace bs_iat_score_neg_worse=0 if bs_en_completed_iat==1
replace bs_iat_score_neg_worse=1 if bs_iat_score>en_iat_score & bs_iat_score<0 & bs_en_completed_iat==1

//Dummy Variable for iat scores that started positive and got more biased (away from 0)
gen bs_iat_score_pos_worse=.
replace bs_iat_score_pos_worse=0 if bs_en_completed_iat==1
replace bs_iat_score_pos_worse=1 if bs_iat_score<en_iat_score & bs_iat_score>0 & bs_en_completed_iat==1

//Dummy Variable for iat scores that started negative and became positive- biased in opposite direction
gen bs_iat_score_neg_pos=.
replace bs_iat_score_neg_pos=0 if bs_en_completed_iat==1
replace bs_iat_score_neg_pos=1 if en_iat_score>0 & bs_iat_score<0 & bs_en_completed_iat==1


//Dummy Variable for iat scores that started postive and became negative- biased in opposite direction
gen bs_iat_score_pos_neg=.
replace bs_iat_score_pos_neg=0 if bs_en_completed_iat==1
replace bs_iat_score_pos_neg=1 if en_iat_score<0 & bs_iat_score>0 & bs_en_completed_iat==1


*IAT scores and redistribution exercise correlations
binscatter  bs_redistribute_decision_mixed bs_iat_score

binscatter  bs_redistribute_decision_mixed bs_iat_score if men==1 & bs_redistribute_decision_mixed!=.

binscatter  bs_redistribute_decision_mixed bs_iat_score if men==0  & bs_redistribute_decision_mixed!=.


