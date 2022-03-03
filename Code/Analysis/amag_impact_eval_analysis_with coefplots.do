clear all 

global main "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$main\Data"
global output "$main\output"

global eval_analysis "$output\eval_analysis"
cap mkdir "$eval_analysis"
global tables "$eval_analysis\tables"
cap mkdir "$tables"
global graphs "$eval_analysis\graphs"
cap mkdir "$graphs"

use "$data\Clean_Full_Data.dta"  

*****************************************************
*Defining controls for all regressions - later in subsections other controls are added
*****************************************************
	ren Cargo Position
	lab var Position Position
	ren Curso Course
	lab var Course Course
	ren Género Gender
	lab var Gender Gender

	encode Position, gen(en_Position)
	encode Course, gen(en_Course)
	encode Gender, gen(en_Gender)
	//shortening names
	ren bs_dictator_partner_gender bs_dictator_pgender
	ren en_dictator_partner_gender en_dictator_pgender
	ren bs_redistribute_partner_gender_a bs_redistribute_pgendera
	ren bs_redistribute_partner_gender_b bs_redistribute_pgenderb
	ren en_redistribute_partner_gender_a en_redistribute_pgendera
	ren en_redistribute_partner_gender_b en_redistribute_pgenderb

	lab def position 1 Assistant 2 Auxiliary 3 Prosecutor 4 Judge
	lab val en_Position position
	lab def courses 1 Convention_Constitution 2 Constitutional_Interpretation 3 Jurisprudence 4 Reasoning 5 Virtues_Principles 6 Ethics
	lab val en_Course courses 
	lab def gender 1 Female 2 Male
	lab val en_Gender gender
	foreach x in  bs_dictator_pgender en_dictator_pgender bs_redistribute_pgendera en_redistribute_pgendera en_redistribute_pgenderb {
		encode `x', gen(`x'_num)
		lab val `x'_num gender
	}

	tab Position, gen(position_)
	tab Course, gen(course_)
	tab Gender, gen(gender_)

	lab var course_1 Convention_Constitution
	lab var course_2 Constitional_Interpretation
	lab var course_3 Jurisprudence
	lab var course_4 Reasoning
	lab var course_5 Virtues_Principles
	lab var course_6 Ethics

	lab var position_1 Assistant
	lab var position_2 Auxiliary
	lab var position_3 Prosecutor
	lab var position_4 Judge

	lab var gender_1 Female
	lab var gender_2 Male

	//global controls1 i.en_Curso 
	global controls2 i.en_Course Age_rounded i.en_Gender i.en_Position

*****************************************************
**IMPACT EVALUATION OF COURSES 
*****************************************************

*****************************************************
***Generating outcome variables 
*****************************************************
*Attrition for those who completed at baseline but not endline
gen attrition=.
replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
tab attrition

foreach x in bs en {
	*motivated reasoner dummy
	tab `x'_motivated_fakenews if `x'_participant_merge==3, m 
	gen `x'_motivated_reasoner=0 if `x'_motivated_fakenews==5 & `x'_participant_merge==3 
	replace `x'_motivated_reasoner =1 if `x'_motivated_fakenews!=. & `x'_motivated_fakenews!=5 & `x'_participant_merge==3
	tab `x'_motivated_reasoner
	
	*extent of motivated reasoning
	gen `x'_motivated_intensity =abs(5-`x'_motivated_fakenews) if `x'_motivated_fakenews!=. & `x'_participant_merge==3
	tab `x'_motivated_intensity
}

*confirmation bias 
*-> whether clicked on both briefs (and order if can extract time stamps)
//Note: currently also counting those who did not click ay brief as exhibiting confirmation bias
foreach x in bs en {
	gen `x'_conf_bias=1 if  `x'_Estado_de_Cuestionario=="Completo" //& (`x'_motivated_click_arga!=. | `x'_motivated_click_argb!=. )
	replace `x'_conf_bias=0 if `x'_motivated_click_arga!=. & `x'_motivated_click_argb!=. & `x'_Estado_de_Cuestionario=="Completo"
	tab `x'_conf_bias
} 

gen iat_score_change = en_iat_score-bs_iat_score

*creating a dummy for whether they saw their feedback at baseline
gen bs_saw_iat_feedback=0 if bs_iat_score!=.
replace bs_saw_iat_feedback=1 if bs_iat_feedback_descriptive!="" & regex(bs_iat_feedback_descriptive, "No fue")==0
tab bs_saw_iat_feedback
count if bs_iat_score!=. //problem is that there is no variable which demarcates if the person was shown or not shown their feedback as bs_iat_feedback_descriptive is there for all the people so not sure who was not shown their feedback
//need to check with Chris

ren en_dictator_player_decision en_dictator_decision
ren en_redistribute_player_decision en_redistribute_decision
ren bs_dictator_player_decision bs_dictator_decision
ren bs_redistribute_player_decision bs_redistribute_decision

foreach x in dictator_decision redistribute_decision {
    gen `x'_change = en_`x'-bs_`x'
}

***adding ingroup outgroup 
//global controls_ingroup_altruism i.en_Course Age_rounded i.en_Gender#i.en_dictator_pgender_num i.en_Position 

gen ingroup_altruism = .
replace ingroup_altruism =0 if en_dictator_pgender_num!=en_Gender
replace ingroup_altruism =1 if en_dictator_pgender_num==en_Gender //partner is ingroup

**redistribution regs
***Adding controls for in group versus outgroup bias 
gen ingroup_redist = . if (en_Gender==1 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==1) | (en_Gender==2 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==2) //both matched participants same gender as the participant
replace ingroup_redist = 0 if (en_Gender==1 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==1) | (en_Gender==2 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==2) //partner a is outgroup, partner b is ingroup
replace ingroup_redist =1 if (en_Gender==1 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==2) | (en_Gender==2 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==1) //partner a is ingroup

gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
gen trolley_version = bs_trolley_treatment
replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
encode trolley_version, gen(en_trolley_version)
***Adding controls for in group versus outgroup bias 
gen ingroup_trolley = 0 if (en_Gender==1 & regexm(trolley_version, "_male")) | (en_Gender==2 & regexm(trolley_version, "female"))
replace ingroup_trolley =1 if (en_Gender==1 & regexm(trolley_version, "female")) | (en_Gender==2 & regexm(trolley_version, "_male"))

encode en_participant_book_choice, gen(en_book)
lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
lab val en_book endbook
tab en_book, gen(en_book_topic)

exit
*****************************************************
**Selection
*****************************************************
*Selection on observables 
orth_out position_* course_* gender_1 Age_rounded using selection.xlsx, by(en_Estado_de_Cuestionario) pcompare stars se sheet(selection_en) sheetreplace notes(The table tests for selection along observables at endline by survey attempt or completion status)
orth_out position_* course_* gender_1 Age_rounded using selection.xlsx, by(bs_Estado_de_Cuestionario) pcompare stars se sheet(selection_bs) sheetreplace notes(The table tests for selection along observables at baseline by survey attempt or completion status)

*****************************************************
*Attrition and selection on observables
*****************************************************
qui sum attrition, d
local mean = round(`r(mean)', 0.001) 
reg attrition $controls2 ,  cluster(Course) 
outreg2 using attrition.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) addnote(The table shows the impact of courses on attrition which is an indicator that equals 1 if the participant completed the baseline survey but did not complete the endline survey. The regression controls for age, gender and position of the participant. Standard errors are clustered at the course level.) bdec(3)

*****************************************************
*Motivated Reasoning
*****************************************************
//Note: The way the question was asked the values capture the chance it was true news
global controls3 i.en_Course Age_rounded i.en_Gender i.en_Position bs_motivated_reasoner 
global controls4 i.en_Course Age_rounded i.en_Gender i.en_Position en_motivated_newsh#bs_motivated_reasoner ///direction of motivated reasoning on average 

local i = 1
foreach y in en_motivated_reasoner en_motivated_intensity {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
//reg `y' $controls1 ,  cluster(Course) 

//	if(`i'==1){
//outreg2 using motivated_reasoning_regs.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label
//	} 
//	else{
//	    outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label
//			}

//local i = `i' + 1
			
reg `y' $controls2 ,  cluster(Course) 

 	if(`i'==1){
outreg2 using motivated_reasoning_regs.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
	    outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
local i = `i' + 1

			
reg `y' $controls3 ,  cluster(Course) 

	if(`i'==1){
outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
	    outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
			
reg `y' $controls4 ,  cluster(Course) 

	if(`i'==1){
outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
	    outreg2 using motivated_reasoning_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course bs_motivated_reasoner 1.en_motivated_newsh#1.bs_motivated_reasoner) bdec(3) addnote(The table shows the impact of courses on motivated reasoning. Columns 1-3 report the results for whether the participant was a motivated reasoner, which is an indicator that equals 1 if the participant did not report the likelihood of the news shown in the motivated reasoning exercise to be true or false with equal (50-50) chance. Columns 4-6 report the results for the intensity of motivated reasoning i.e. how far from 50-50 in absolute terms the participant guessed the message was true or false. Column 1 controls for age, gender and position of the participant; Column 2 additionally controls for whether the participant was a motivated reasoner in the baseline survey and Column 3 additionally allows for an interaction between whether the news message shown to the pariticipant was one that said the true estimate was "Higher" or "Lower" than their reported median belief. Standard errors are clustered at the course level.) 
			}
}


global controls5 i.en_Course Age_rounded i.en_Gender i.en_Position bs_conf_bias 

foreach y in en_conf_bias {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
//reg `y' $controls1 ,  cluster(Course) 
//outreg2 using conf_bias_regs.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label
			
reg `y' $controls2 ,  cluster(Course) 
outreg2 using conf_bias_regs.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') keep(i.en_Course) bdec(3) label
			
reg `y' $controls5 ,  cluster(Course) 
outreg2 using conf_bias_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
}

*Curiosity

global controls5 i.en_Course Age_rounded i.en_Gender i.en_Position bs_motivated_info

foreach y in en_motivated_info {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
//reg `y' $controls1 ,  cluster(Course) 
//outreg2 using curiosity_regs.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label
			
reg `y' $controls2 ,  cluster(Course) 
outreg2 using curiosity_regs.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			
reg `y' $controls5 ,  cluster(Course) 
outreg2 using curiosity_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
}

**********************************************************************************************************
***IAT take up of exercise and feedback
*Analyze selection on observables for those who choose to take the test 
*Analyze selection on observables for receiving feedback or not 
**********************************************************************************************************
*Selection on observables for takeup
orth_out position_* course_* gender_1 Age_rounded using iat_selection.xlsx if iat_option_take_or_not==1, by(en_iat_player_skipped) pcompare stars se sheet(selection_iat_takeup) sheetreplace notes(The table tests for selection on obaservables for take up of IAT exercise at the endline.) bdec(3)

**Selection on observables for feedback
gen en_ignore_feedback = 0 if en_iat_want_feedback!=.
replace en_ignore_feedback =1 if en_iat_want_feedback==0 | en_iat_feedback_level==0 

orth_out position_* course_* gender_1 Age_rounded using iat_selection.xlsx if iat_feedback_option_or_not==1, by(en_ignore_feedback) pcompare stars se sheet(selection_iat_feedback) sheetreplace notes(The table tests for selection on obaservables for take up of IAT exercise at the endline.)

*****************************************************
*IAT scores
*****************************************************
global controls6 i.en_Course Age_rounded i.en_Gender i.en_Position bs_iat_score
//global controls6iv i.en_Course Age_rounded i.en_Gender i.en_Position (bs_iat_score=iat_option_take_or_not) 
global controls7 i.en_Course Age_rounded i.en_Gender i.en_Position iat_option_take_or_not  //iat_feedback_option_or_not

//global controls6 i.en_Course Age_rounded i.en_Gender i.en_Position bs_saw_iat_feedback //bs_saw_iat_feedback = iat_feedback_option_or_not
*Analyze choice of receiving feedback depending on whether forced to take the IAT or opted in 

local i = 1
foreach y in en_iat_player_skipped en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 ,  cluster(Course) 

reg `y' $controls2 ,  cluster(Course) 

if(`i'==1){
outreg2 using iat_regs.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course) bdec(3)
} 
	else{
outreg2 using iat_regs.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
			
local i = `i' + 1
			
reg `y' $controls6 ,  cluster(Course) 
outreg2 using iat_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course) bdec(3) 

//ivreg2 `y' $controls6iv,  cluster(Course) 
//outreg2 using iat_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

reg `y' $controls7 ,  cluster(Course) 
outreg2 using iat_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course iat_option_take_or_not) bdec(3)
}

***Looking at IAT results of only those who were forced to take the IAT - no selection issues at all
local i = 1
foreach y in en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 if iat_option_take_or_not==0,  cluster(Course) 

			
reg `y' $controls2 if iat_option_take_or_not==0,  cluster(Course)

if(`i'==1){
outreg2 using iat_regs_forced.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
			
local i = `i' + 1 
			
reg `y' $controls6 if iat_option_take_or_not==0,  cluster(Course) 
outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course)

//ivreg2 `y' $controls6iv if iat_option_take_or_not==0,  cluster(Course) 
//outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

//reg `y' $controls7 if iat_option_take_or_not==0,  cluster(Course) 
//outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course)
}

*****************************************************
*Altruism and Redistribution 
*****************************************************
global controls_ingroup_altruism i.en_Course Age_rounded i.en_Gender ingroup_altruism i.en_Position 

**altruism regs
local i = 1
foreach y in en_dictator_decision dictator_decision_change {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 ,  cluster(Course) 
		
reg `y' $controls2 ,  cluster(Course) 
if(`i'==1){
outreg2 using altruism_regs.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
outreg2 using altruism_regs.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
	
local i = `i' + 1

reg `y' $controls_ingroup_altruism ,  cluster(Course) 
outreg2 using altruism_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course i.en_Gender#i.en_dictator_pgender_num) bdec(3)
}


global controls_ingroup_redist i.en_Course Age_rounded i.en_Gender#i.ingroup_redist i.en_Position 

local i = 1
foreach y in en_redistribute_decision redistribute_decision_change {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 ,  cluster(Course) 
		
reg `y' $controls2 ,  cluster(Course) 
if(`i'==1){
outreg2 using resdistribution_regs.xls, replace stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course) bdec(3)
	} 
	else{
outreg2 using resdistribution_regs.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label keep(i.en_Course) bdec(3)
			}
local i = `i' + 1

reg `y' $controls_ingroup_redist,  cluster(Course) 
outreg2 using resdistribution_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(i.en_Course i.en_Gender#i.ingroup_redist) bdec(3)
}


*****************************************************
*Trolley
*****************************************************
global controls8 i.en_Course Age_rounded i.en_Gender i.en_Position i.en_trolley_version
global controls_ingroup i.en_Course Age_rounded i.en_Gender#i.ingroup_trolley i.en_Position i.en_trolley_version 


local i = 1
foreach y in en_trolley_decision trolley_decision_change {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 ,  cluster(Course) 

reg `y' $controls2 ,  cluster(Course) 
if(`i'==1){
outreg2 using trolley.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label  keep(i.en_Course) bdec(3)
	} 
	else{
outreg2 using trolley.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label  keep(i.en_Course) bdec(3)
			}
		local i = `i' + 1


	
reg `y' $controls8 ,  cluster(Course) 
outreg2 using trolley.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course) bdec(3)

reg `y' $controls_ingroup ,  cluster(Course) 
outreg2 using trolley.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(i.en_Course i.en_Gender#i.ingroup_trolley) bdec(3)
}


*****************************************************
*Book choice
*****************************************************

local i = 1
foreach y of varlist en_book_topic* {
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
//reg `y' $controls1 ,  cluster(Course) 
			
reg `y' $controls2 ,  cluster(Course) 
if(`i'==1){
outreg2 using book_choice.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label  keep(i.en_Course)
	} 
	else{
outreg2 using book_choice.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label  keep(i.en_Course)
			}
			
local i = `i' + 1

}

**********************
**Socratic Video
**********************
gen saw_video = . 
replace saw_video=1 if bs_participant_index_in_pages>16 & bs_participant_index_in_pages!=.
replace saw_video=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<=16 & bs_participant_index_in_pages!=.

gen socratic_actual = 0 if saw_video==0 
replace socratic_actual=1 if saw_video==1 & socratic_treated==1

global controls_socitt socratic_treated 
global controls_socitt2 socratic_treated i.en_Course Age_rounded i.en_Gender i.en_Position
global controls_soctot (socratic_actual=socratic_treated) i.en_Course Age_rounded i.en_Gender i.en_Position 
**Interaction between Socratic and Courses 
global controls_socitt_int socratic_treated i.en_Course Age_rounded i.en_Gender i.en_Position i.en_Course#socratic_treated 

*Balance on observables 
orth_out position_* course_* gender_1 Age_rounded using soc_balance.xlsx, by(socratic_treated) pcompare stars se sheet(soc_balance_itt) sheetreplace count
orth_out position_* course_* gender_1 Age_rounded using soc_balance.xlsx, by(socratic_actual) pcompare stars se sheet(socratic_actual) sheetreplace count


***Outcomes
local i = 1
foreach y of varlist attrition en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_trolley_decision trolley_decision_change en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change en_iat_player_skipped en_iat_score en_iat_want_feedback en_iat_feedback_level  en_book_topic2 - en_book_topic5  { //iat_score_change
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
reg `y' $controls_socitt ,  r 
if(`i'==1){
outreg2 using socratic.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated) bdec(3)
	} 
	else{
outreg2 using socratic.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label  keep(socratic_treated) bdec(3)
			}
			
local i = `i' + 1
			
reg `y' $controls_socitt2 ,  r
outreg2 using socratic.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(socratic_treated) bdec(3)

ivreg2 `y' $controls_soctot ,  r
outreg2 using socratic.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(socratic_actual) bdec(3)

reg `y' $controls_socitt_int ,  r
outreg2 using socratic.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep( socratic_treated i.en_Course#socratic_treated) bdec(3)
}


** alternate definition of whether saw the video --whether reached page 16 
gen saw_video2 = . 
replace saw_video2=1 if bs_participant_index_in_pages>=16 & bs_participant_index_in_pages!=.
replace saw_video2=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<16 & bs_participant_index_in_pages!=.

gen socratic_actual2 = 0 if saw_video==0 
replace socratic_actual2=1 if saw_video==1 & socratic_treated==1

**controls with the alt definition 
global controls_soctot_alt (socratic_actual2=socratic_treated) i.en_Course Age_rounded i.en_Gender i.en_Position 


*Balance on observables 
orth_out position_* course_* gender_1 Age_rounded using soc_balance.xlsx, by(socratic_actual2) pcompare stars se sheet(socratic_actual2) sheetreplace count



//global controls_soctot_alt_int (socratic_actual=socratic_treated) i.en_Course Age_rounded i.en_Gender i.en_Position i.en_Course#socratic_actual 

***Outcomes
local i = 1
foreach y of varlist attrition en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_trolley_decision trolley_decision_change en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change en_iat_player_skipped en_iat_score en_iat_want_feedback en_iat_feedback_level  en_book_topic2 - en_book_topic5  { //iat_score_change
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
reg `y' $controls_socitt ,  r 
if(`i'==1){
outreg2 using socratic_alt.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated) bdec(3)
	} 
	else{
outreg2 using socratic_alt.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label  keep(socratic_treated) bdec(3)
			}
			
local i = `i' + 1
			
reg `y' $controls_socitt2 ,  r
outreg2 using socratic_alt.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(socratic_treated) bdec(3)

ivreg2 `y' $controls_soctot_alt ,  r
outreg2 using socratic_alt.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep(socratic_actual2) bdec(3)

reg `y' $controls_socitt_int ,  r
outreg2 using socratic_alt.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label  keep( socratic_treated i.en_Course#socratic_treated) bdec(3)
}


***********
**COEFPLOTS
***********
**all controls: 
global controls_all Age_rounded i.en_Gender i.en_Position
global controls_ingroup_altruism i.en_Course Age_rounded i.en_Gender ingroup_altruism i.en_Position 
global controls_ingroup i.en_Course Age_rounded i.en_Gender#i.ingroup_trolley i.en_Position i.en_trolley_version 
global controls_ingroup_redist i.en_Course Age_rounded i.en_Gender#i.ingroup_redist i.en_Position 


//overall regs
//en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_iat_player_skipped en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level en_dictator_decision dictator_decision_change en_redistribute_decision redistribute_decision_change en_participant_book_choice   en_trolley_decision trolley_decision_change 

//MOTIVATED REASONING
//rescaling motivated intensity to 0-1
tab en_motivated_intensity
replace en_motivated_intensity=en_motivated_intensity/5

foreach x in  motivated_reasoner motivated_intensity conf_bias motivated_info { 
	qui reg en_`x' i.en_Course $controls_all ,  cluster(Course) 
	est store `x'
	qui reg  en_`x' i.en_Course $controls_all bs_`x',  cluster(Course) 
	est store `x'_bs
}

coefplot motivated_reasoner motivated_reasoner_bs ///
motivated_intensity motivated_intensity_bs ///
conf_bias  conf_bias_bs /// 
motivated_info motivated_info_bs ///
, keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) xscale(range(-0.3 0.3)) xlabel(-0.3(0.15)0.3) format(%9.1f) ciopts(recast(rcap)) mlabposition(12) level(95)  offset() coeflabels(,notick labsize(small) labcolor(purple) labgap(2))  graphregion(fcolor(white)) bycoefs xtitle("Point Estimates with 95% CIs")  legend(size(vsmall) label(2 "Motivated Reasoner") label(4 "Incl. Baseline") label(6 "Motivated Reasoning (intensity)") label(8 "Incl. Baseline") label(10 "Confirmation Bias") label(12 "Incl. Baseline") label(14 "Demand for Information")  label(16 "Incl. Baseline") linegap(1.1) row(4) nobox) label(Motivated Reasoning) ytitle("Cognitive Biases") ylabel("")

graph export motivated_reasoning.png, replace

//IAT 
//rescaling en_iat_feedback_level to 0-1
tab en_iat_feedback_level
replace en_iat_feedback_level=en_iat_feedback_level/10
tab iat_score
tab iat_score_change

foreach x in iat_player_skipped iat_score iat_want_feedback iat_feedback_level { 
	
	qui reg en_`x' i.en_Course $controls_all ,  cluster(Course) 
	est store `x'
	qui reg  en_`x' i.en_Course $controls_all bs_`x',  cluster(Course) 
	est store `x'_bs

}

coefplot iat_player_skipped iat_player_skipped_bs ///
iat_score iat_score_bs ///
iat_want_feedback iat_want_feedback_bs ///
iat_feedback_level iat_feedback_level_bs ///
, keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) xscale(range(-0.3 0.3)) xlabel(-0.3(0.15)0.3) format(%9.1f) ciopts(recast(rcap)) mlabposition(12) level(95)  offset() coeflabels(,notick labsize(tiny) labcolor(purple) labgap(5))  graphregion(fcolor(white)) bycoefs xtitle("Point Estimates with 95% CIs")  legend(size(vsmall) label(2 "Skip IAT") label(4 "Incl. Baseline") label(6 "IAT Score") label(8 "Incl. Baseline") label(10 "Want Feedback") label(12 "Incl. Baseline") label(14 "Feedback Desire Level")  label(16 "Incl. Baseline") linegap(1.1) row(4) nobox) label(Motivated Reasoning) ytitle("IAT") ylabel("")

graph export iat.png, replace

///DICTATOR GAME AND REDISTRIBUTION

foreach x in dictator_decision redistribute_decision  { 
	
	qui reg en_`x' i.en_Course $controls_all ,  cluster(Course) 
	est store `x'
	qui reg  en_`x' i.en_Course $controls_all bs_`x',  cluster(Course) 
	est store `x'_bs
}

coefplot dictator_decision dictator_decision_bs  ///
redistribute_decision redistribute_decision_bs ///
, keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) xscale(range(-0.3 0.6)) xlabel(-0.3(0.2)0.8) format(%9.1f) ciopts(recast(rcap)) mlabposition(12) level(95)  offset() coeflabels(,notick labsize(tiny) labcolor(purple) labgap(5))  graphregion(fcolor(white)) bycoefs xtitle("Point Estimates with 95% CIs")  legend(size(vsmall) label(2 "Dictator Game (Keep)") label(4 "Incl. Baseline") label(6 "Redistribution Game") label(8 "Incl. Baseline") linegap(1.1) row(2) nobox) label(Motivated Reasoning) ytitle("Dictator and Redistribution Games") ylabel("")

graph export dictator_redistribution.png, replace


///TROLLEY

foreach x in trolley_decision   { 
	
	qui reg en_`x' i.en_Course $controls_all ,  cluster(Course) 
	est store `x'
	qui reg  en_`x' i.en_Course $controls_all bs_`x',  cluster(Course) 
	est store `x'_bs
}

coefplot trolley_decision trolley_decision_bs , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) xscale(range(-0.3 0.3)) xlabel(-0.3(0.15)0.3) format(%9.2f) ciopts(recast(rcap)) mlabposition(12) level(95)  offset() coeflabels(,notick labsize(tiny) labcolor(purple) labgap(5))  graphregion(fcolor(white)) bycoefs xtitle("Point Estimates with 95% CIs") mlabel legend(size(vsmall) label(2 "Trolley Decision (Yes)") label(4 "Incl. Baseline") linegap(1.1) row(2) nobox) ytitle("Trolley Decision") ylabel("")

graph export trolley.png, replace

//WITH SOCRATIC INTERACTION

global controls_socitt_int socratic_treated i.en_Course Age_rounded i.en_Gender i.en_Position i.en_Course#socratic_treated 

//MOTIVATED REASONING
foreach x in  motivated_reasoner motivated_intensity conf_bias motivated_info iat_player_skipped iat_score iat_want_feedback iat_feedback_level trolley_decision  dictator_decision redistribute_decision {
	//qui reg en_`x' $controls_socitt_int ,  cluster(Course) 
	//est store `x'
	 reg  en_`x' $controls_socitt_int bs_`x',  cluster(Course) 
	est store `x'_bs
}

coefplot (motivated_reasoner_bs, msymbol(o) mlcolor(emerald) color(emerald) mfcolor(emerald*.5) ciopts(recast(rcap) color(emerald*.5)) offset(0.1)) ///
(motivated_intensity_bs, msymbol(o) mlcolor(midgreen) color(midgreen) mfcolor(midgreen*.5) ciopts(recast(rcap) color(midgreen*.5)) offset(-0.1)) ///
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-0.3 0.3)) xlabel(-0.3(0.15)0.3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "Motivated Reasoner") label(4 "Motivated Reasoning (intensity)")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(Motivated Reasoning)
  
  graph export motivated_soc.png, replace

coefplot (conf_bias_bs, msymbol(o) mlcolor(navy) color(navy) mfcolor(navy*.5) ciopts(recast(rcap) color(navy*.5)) offset(0.1)) /// 
(motivated_info_bs, msymbol(o) mlcolor(lavender) color() mfcolor(lavender*.5) ciopts(recast(rcap) color(lavender*.5)) offset(-0.1)) ///
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-0.3 0.3)) xlabel(-0.3(0.15)0.3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "Confirmation Bias") label(4 "Demand for Information")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(Confirmation Bias and Demand for Information)
  
   graph export conf_bias_soc.png, replace
  
    coefplot (iat_player_skipped_bs, msymbol(o) mlcolor(navy) color(navy) mfcolor(navy*.5) ciopts(recast(rcap) color(navy*.5)) offset(0.1)) /// 
(iat_want_feedback_bs, msymbol(o) mlcolor(lavender) color() mfcolor(lavender*.5) ciopts(recast(rcap) color(lavender*.5)) offset(-0.1)) ///
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-0.6 0.3)) xlabel(-0.6(0.15)0.3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "IAT skip") label(4 "Want feedback")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(IAT & Feedback Take-up)
  
   graph export iat_ext_soc.png, replace

       coefplot (iat_score_bs, msymbol(o) mlcolor(navy) color(navy) mfcolor(navy*.5) ciopts(recast(rcap) color(navy*.5)) offset(0.1)) /// 
	   (iat_feedback_level_bs, msymbol(o) mlcolor(midgreen) color(midgreen) mfcolor(midgreen*.5) ciopts(recast(rcap) color(midgreen*.5)) offset(-0.1)) ///
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-0.6 0.3)) xlabel(-0.6(0.15)0.3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "IAT score") label(4 "Feedback Desire Level")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(IAT Score and Feedback Desire)
 
graph export iat_soc.png, replace

///DICTATOR GAME AND REDISTRIBUTION

coefplot (dictator_decision_bs, msymbol(o) mlcolor(navy) color(navy) mfcolor(navy*.5) ciopts(recast(rcap) color(navy*.5)) offset(0.1)) /// 
	   (redistribute_decision_bs, msymbol(o) mlcolor(midgreen) color(midgreen) mfcolor(midgreen*.5) ciopts(recast(rcap) color(midgreen*.5)) offset(-0.1)) ///
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-3 3)) xlabel(-3(1)3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "Dictator (self)") label(4 "Redistribution")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(Dictator Game and Redistribution Decision)
 
graph export dictator_soc.png, replace

coefplot (trolley_decision_bs, msymbol(o) mlcolor(navy) color(navy) mfcolor(navy*.5) ciopts(recast(rcap) color(navy*.5)) offset(0.1)) /// 
  , keep(*.en_Course*) xline(0, lwidth(thin) lpattern(dash) lcolor(black)) offset() xscale(range(-0.6 0.3)) xlabel(-0.6(0.15)0.3) format(%9.2f) ciopts(recast(rcap))  level(95) coeflabels(,notick labsize(*.8) labcolor(purple) labgap(0))  graphregion(fcolor(white)) xtitle("Point Estimates with 95% CIs") legend(size(vsmall) linegap(.5) row(2) nobox label(2 "Trolley Decision")) rename(2.en_Course="Constitution" 5.en_Course="Virtues" 2.en_Course#1.socratic_treated="Constitution#Socratic" 3.en_Course#1.socratic_treated="Jurisprudence#Socratic"  4.en_Course#1.socratic_treated="Reasoning#Socratic"  5.en_Course#1.socratic_treated="Virtues#Socratic" 6.en_Course#1.socratic_treated="Ethics#Socratic")  ytitle(IAT Score and Feedback Desire)
graph export trolley_soc.png, replace

//BOOK CHOICE 
/*
foreach x in en_book_topic2 en_book_topic3 en_book_topic4 en_book_topic5 { 
	
	qui reg `x' i.en_Course $controls_all ,  cluster(Course) 
	est store `x'

}
graph export trolley.png, replace

coefplot en_book_topic2 en_book_topic3 en_book_topic4 en_book_topic5 , xline(0)  drop(_cons Age_rounded i.en_Gender i.en_Position)  xscale(range(-0.5(0.1)0.5)) format(%9.2f) mlabposition(12) level(95)  offset() coeflabels(,notick labsize(small) labcolor(purple) labgap(2))  graphregion(fcolor(white)) bycoefs xtitle("Point Estimates with 95% CIs") mlabel

graph export book_choice.png, replace
*/ 









//PREVIOUS ANALYSIS 
/*
reg en_trolley_decision $controls_trolley ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference by Course") saving(trolley1.gph, replace) 

reg trolley_decision_change $controls2 ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference Change by Course") saving(trolley2.gph, replace) 

graph combine trolley1.gph trolley2.gph, ycommon saving(AmagExhibit1, replace)

reg en_book_topic4 $controls2 ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Just Decision") saving(book1.gph, replace) 

reg en_book_topic5 $controls2 ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Reasoning") saving(book2.gph, replace) 

graph combine book1.gph book2.gph, ycommon saving(AmagExhibit2, replace)

reg iat_score_change $controls2 ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("IAT score change") saving(iat_score_change.gph, replace)

reg en_iat_want_feedback $controls_iatfeedback ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Whether want feedback for IAT") saving(iat_feedback.gph, replace) 

graph combine book1.gph book2.gph, ycommon saving(AmagExhibit3, replace)

reg en_motivated_reasoner $controls_motivated ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Motivated reasoning") saving(motivated.gph, replace) 

reg en_conf_bias $controls_confbias ,  cluster(Course) 
coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Confirmation Bias") saving(conf_bias.gph, replace) 

graph combine motivated.gph conf_bias.gph , ycommon saving(AmagExhibit4, replace)


/*
binscatter en_trolley_decision Course_6, controls(Position_* Age_rounded gender_*) xtitle("Inmates released in March / population") ytitle("Covid-19 cases / population") savegraph(march.gph) replace
binscatter  positivecasesperpop povertyrate, controls(marchreleaseperpop publictransitutilrate  percentblack population) nq(100)  xtitle("Poverty rate") ytitle("Covid-19 cases / population") savegraph(povertyrate.gph) replace
binscatter  positivecasesperpop percentblack, controls(povertyrate publictransitutilrate  marchreleaseperpop population) nq(100)  xtitle("% Black population") ytitle("Covid-19 cases / population") savegraph(percentblack.gph) replace
binscatter  positivecasesperpop publictransitutilrate, controls(povertyrate marchreleaseperpop  percentblack population) nq(100)  xtitle("Public transit utilization rate") ytitle("Covid-19 cases / population") savegraph(publictransitutilrate.gph) replace
binscatter  positivecasesperpop population, controls(povertyrate marchreleaseperpop  percentblack publictransitutilrate) nq(100) xtitle("Population density") ytitle("Covid-19 cases / population") savegraph(density.gph) replace
graph combine march.gph povertyrate.gph percentblack.gph publictransitutilrate.gph density.gph, ycommon saving(AppendixExhibit1, replace)
*/

*/









