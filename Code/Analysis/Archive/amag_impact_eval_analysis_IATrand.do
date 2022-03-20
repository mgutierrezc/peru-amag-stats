clear
cd "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME"

use "Clean_Full_Data12.dta"   /// stata 12 friendly
set more off
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




merge m:m DNI using "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME/participants_iat_feedback.dta"
rename _m mergesawfeedback

tab seen_iat* if DNI != .

merge m:1 DNI using sat_clean.dta
drop _m

merge m:1 DNI using grades_clean.dta
drop _m

rename sat3 sat_instructor
rename sat5 sat_exp
rename sat2 sat_course
rename meansat sat_avg

***** Creating variables

gen attrition=.
replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
tab attrition

ren en_dictator_player_decision en_dictator_decision
ren en_redistribute_player_decision en_redistribute_decision
ren bs_dictator_player_decision bs_dictator_decision
ren bs_redistribute_player_decision bs_redistribute_decision

foreach x in dictator_decision redistribute_decision {
    gen `x'_change = en_`x'-bs_`x'
}

gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
gen trolley_version = bs_trolley_treatment

replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
encode trolley_version, gen(en_trolley_version)

encode en_participant_book_choice, gen(en_book)

lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
lab val en_book endbook

tab en_book, gen(en_book_topic)

gen saw_video = . 
replace saw_video=1 if bs_participant_index_in_pages>16 & bs_participant_index_in_pages!=.
replace saw_video=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<=16 & bs_participant_index_in_pages!=.

gen socratic_actual = 0 if saw_video==0 
replace socratic_actual=1 if saw_video==1 & socratic_treated==1



*****************************************************
*Motivated Reasoning
*****************************************************
//Note: The way the question was asked the values capture the chance it was true news
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

* Generate standarized Dependent variables for models


foreach var of varlist en_iat_score  bs_iat_score iat_score_change en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_trolley_decision trolley_decision_change en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change en_iat_player_skipped   en_book_topic1 - en_book_topic4  sat_instructor sat_exp sat_course sat_avg grade pass {
		qui sum `var'
		gen z_`var' = (`var' - `r(min)') / (`r(max)'-`r(min)')

	}


lab var z_en_iat_score "IAT score endline"
lab var z_bs_iat_score "IAT score baseline"
lab var z_iat_score_change "IAT score change"
lab var z_en_motivated_reasoner "Motivated Reasoner"
lab var z_en_motivated_intensity "Motivated Reasoner (intensity)"
lab var z_en_conf_bias "Confirmation Bias"
lab var z_en_motivated_info "Curiosity"
lab var z_en_trolley_decision "Trolley Decision"
lab var z_trolley_decision_change "Trolley Decision Change"
lab var z_en_dictator_decision "Dictator Decision"
lab var z_dictator_decision_change "Dictator Decision  Change"
lab var z_en_redistribute_decision "Redistribute Decision"
lab var z_redistribute_decision_change "Redistribute Decision Change"
lab var z_en_iat_player_skipped "skipped IAT"
lab var z_en_book_topic1 "Book choice: Corruption"
lab var z_en_book_topic2 "Book choice: Feminist Rights"
lab var z_en_book_topic3 "Book choice: Just Decision"
lab var z_en_book_topic4 "Book choice: Proof and Rationality"
lab var z_sat_instructor "Satisfaction: Instructor"
lab var z_sat_exp "Satisfaction: Learning experience"
lab var z_sat_course "Satisfaction: course"
lab var z_sat_avg "Satisfaction: average"
lab var z_grade "Course Grade "
lab var z_pass "Pass Course"




**********************************************************************************************************
***IAT take up of exercise and feedback
********************************************************************************

**Selection on observables for feedback
gen en_ignore_feedback = 0 if en_iat_want_feedback!=.
replace en_ignore_feedback =1 if en_iat_want_feedback==0 | en_iat_feedback_level==0 

*****************************************************
*IAT scores
*****************************************************
global controls2    i.en_Course Age_rounded i.en_Gender  i.en_Position

global controls6    i.en_Course Age_rounded i.en_Gender i.en_Position z_bs_iat_score
global controls6r   i.en_Course Age_rounded i.en_Gender i.en_Position iat_option_take_or_not   
global controls6iv  i.en_Course Age_rounded i.en_Gender i.en_Position (z_bs_iat_score=iat_option_take_or_not) 


global controls7   i.en_Course Age_rounded i.en_Gender i.en_Position seen_iat_feedback  
global controls7r   i.en_Course Age_rounded i.en_Gender i.en_Position iat_feedback_option_or_not
global controls7iv i.en_Course Age_rounded i.en_Gender i.en_Position (seen_iat_feedback  = iat_feedback_option_or_not)
global controlsint  i.en_Course Age_rounded i.en_Gender i.en_Position iat_feedback_option_or_not##iat_option_take_or_not

gen  iat_interaction = iat_feedback_option_or_not * iat_option_take_or_not
*Analyze choice of receiving feedback depending on whether forced to take the IAT or opted in 
set more off
local i = 1
foreach y in z_en_iat_score z_iat_score_change  z_en_motivated_reasoner z_en_motivated_intensity z_en_conf_bias z_en_motivated_info z_en_trolley_decision z_trolley_decision_change z_en_dictator_decision z_dictator_decision_change  z_en_redistribute_decision z_redistribute_decision_change   z_en_book_topic1   z_en_book_topic2   z_en_book_topic3  z_en_book_topic4  z_sat_instructor z_sat_exp sat_course z_sat_avg z_grade z_pass{ //en_iat_player_skipped  en_iat_want_feedback en_iat_feedback_level
    qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	
reg `y' $controls2 ,  cluster(Course) 
if(`i'==1){
outreg2 using iat_regs.xls, replace stats(coef pval ) level(95) addtext(mean, `mean') label
	} 
	else{
outreg2 using iat_regs.xls, append stats(coef pval ) level(95) addtext(mean, `mean') label
			}
			
local i = `i' + 1
			
reg `y' $controls6 ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label
			
reg `y' $controls6r ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

ivreg2 `y' $controls6iv,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

reg `y' $controls7 ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

reg `y' $controls7r ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

ivreg2 `y' $controls7iv ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

reg `y' $controlsint ,  cluster(Course) 
outreg2 using iat_regs_.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label
}



**********************************************
* IAT: Interaction effects and IV approach
**********************************************


set more off
global controlsint  i.en_Course Age_rounded i.en_Gender i.en_Position iat_feedback_option_or_not##iat_option_take_or_not
global controlsinta  i.en_Course Age_rounded i.en_Gender i.en_Position i.iat_interaction

foreach y of varlist z_en_motivated_reasoner z_en_motivated_intensity z_en_conf_bias z_en_motivated_info z_en_trolley_decision z_trolley_decision_change z_en_dictator_decision z_dictator_decision_change  z_en_redistribute_decision z_redistribute_decision_change z_en_iat_player_skipped   z_en_book_topic1 - z_en_book_topic4  z_sat_instructor z_sat_exp sat_course z_sat_avg z_grade z_pass { 
*labels for plots
local mylabel : variable label `y'

reg `y' $controlsinta ,  cluster(Course)
	* test for significance of interaction
test 1.iat_interaction == 0.iat_interaction 
local pval : di %5.3f `r(p)'
local pval = trim("`pval'")
*------------------------------*
* Model 1: DVs and interaction
*------------------------------ *
reg `y' $controlsint ,  r beta
* Store number of observations and coefficient
local nobs = e(N)
mat coef=e(b)
local coef1: di %5.3f el(coef,1,2)
local coef1 = trim("`coef1'")

*Predicting margins
set scheme s1mono
margins , over(iat_option_take_or_not  iat_feedback_option_or_not)
* Margins plot
marginsplot,  legend(order(3 "no feedback option" 4 "feedback option") size(small)) /// 
 ciopts(recast(rcap) color(black)) ylabel(, labsize(vsmall) angle(horizontal)) x(iat_option_take_or_not) ///
 title("IAT treatments and `mylabel'") ///
  xscale(range(-0.5 1.5)) ///
 xlabel(0 "No option" 1 "Option to take" , labsize(small) noticks) xtitle("Option to skip IAT test", size(small)) ///
 ytitle(`mylabel') ///  
 graphregion(color(white)) ///
 note("Dependent variable is normalized to an index between 0 and 1." "Number of observations = `nobs'. Treatment coefficient: `coef1'." "P-value of F-test for coefficient equality of interaction term is `pval'. ", size(small)) ///
 caption("Estimations obtained from OLS regressions include the following controls: age, gender, course dummies and position dummies" , size(vsmall))
graph export "barcharts/`y'_1_iatint.png", replace

}

*------------------------------*
* Model 2,3: IVreg for selection
* Skip f(option to take), see feedback = f(option to see feedback)
*------------------------------ *
global controls6iv  (i.bs_iat_player_skipped=i.iat_option_take_or_not)  i.en_Course Age_rounded i.en_Gender i.en_Position  
global controls7iv  (i.seen_iat_feedback  = i.iat_feedback_option_or_not) i.en_Course Age_rounded i.en_Gender i.en_Position 

foreach y of varlist  z_en_iat_score  iat_score_change z_en_motivated_reasoner z_en_motivated_intensity z_en_conf_bias z_en_motivated_info z_en_trolley_decision z_trolley_decision_change z_en_dictator_decision z_dictator_decision_change  z_en_redistribute_decision z_redistribute_decision_change z_en_iat_player_skipped   z_en_book_topic1 - z_en_book_topic4  z_sat_instructor z_sat_exp sat_course z_sat_avg z_grade z_pass { 
*labels for plots
local mylabel : variable label `y'
*------------------------------*
* IVreg Model 1: see feedback
*------------------------------ *

ivreg2 `y' $controls7iv ,  cluster(Course)
* Store number of observations and coefficient
local nobs = e(N)
mat coef=e(b)
local coef1: di %5.3f el(coef,1,2)
local coef1 = trim("`coef1'")
* Computing p value of difference between groups

test 1.seen_iat_feedback == 0.seen_iat_feedback
local pval : di %5.3f `r(p)'
local pval = trim("`pval'")
*Predicting margins
set scheme s1mono
margins seen_iat_feedback

* Margins plot
marginsplot, recast(bar ) plotopts(barwidth(0.5) bargap(10)) ///
 ciopts(recast(rcap) color(black)) ylabel(, labsize(vsmall) angle(horizontal)) ///
 title("Saw IAT feedback and `mylabel'") ///
 xlabel(0 "No" 1 "Yes", noticks) xtitle("Saw IAT feedback") ///
 ytitle(`mylabel') ///
 graphregion(color(white)) ///t
 note("Dependent variable is normalized to an index between 0 and 1." "Number of observations = `nobs'. 'Seen IAT feedback'  coefficient: `coef1'." "P-value of F-test for seen IAT feedback coefficient equality across categories is `pval'. ", size(small)) ///
 caption("Instrumental variables regressions where the randomized option to receive feedback" ///
 "is the instrumental variable. Model includes the following independent variables: age, gender, course and position" , size(vsmall))

graph export "barcharts/`y'_3_iviatfeedback.png", replace

}

replace  bs_iat_player_skipped  = 0 if   iat_option_take_or_not ==0

foreach y of varlist  z_en_iat_score  z_en_motivated_reasoner z_en_motivated_intensity z_en_conf_bias z_en_motivated_info z_en_trolley_decision z_trolley_decision_change z_en_dictator_decision z_dictator_decision_change  z_en_redistribute_decision z_redistribute_decision_change   z_en_book_topic1 - z_en_book_topic4  z_sat_instructor z_sat_exp sat_course z_sat_avg z_grade z_pass { 
*labels for plots
local mylabel : variable label `y'
*------------------------------*
* IVreg Model 2: skip test
*------------------------------ *
ivreg2 `y' $controls6iv , r
* Store number of observations and coefficient
local nobs = e(N)
mat coef=e(b)
local coef1: di %5.3f el(coef,1,2)
local coef1 = trim("`coef1'")
* Computing p value of difference between groups

test 1.bs_iat_player_skipped == 0.bs_iat_player_skipped
local pval : di %5.3f `r(p)'
local pval = trim("`pval'")
*Predicting margins
set scheme s1mono
margins bs_iat_player_skipped

* Margins plot
marginsplot, recast(bar ) plotopts(barwidth(0.5) bargap(10)) ///
 ciopts(recast(rcap) color(black)) ylabel(, labsize(vsmall) angle(horizontal)) ///
 title("Skipped IAT and `mylabel'") ///
 xlabel(0 "No" 1 "Yes", noticks) xtitle("Skip IAT") ///
 ytitle(`mylabel') ///
 graphregion(color(white)) ///
 note("Dependent variable is normalized to an index between 0 and 1." "Number of observations = `nobs'. 'Skipped IAT' coefficient: `coef1'." "P-value of F-test for skipped IAT coefficient equality across categories is `pval'. ", size(small)) ///
 caption("Instrumental variables regressions where the randomized option to skip the IAT test" ///
 "is the instrumental variable. Model includes the following independent variables: age, gender, course and position" , size(vsmall))

graph export "barcharts/`y'_2_iviatskip.png", replace

}






