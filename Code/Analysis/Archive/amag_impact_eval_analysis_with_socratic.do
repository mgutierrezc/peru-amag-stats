cls
/***********
**Impact Analysis of Peru Amag project
with Socratic Analysis

Project: Peru-Amag
Programmer: Ronak Jain/Mayumi Cornejo
Editor: Marco Gutierrez
***********/

clear all 

/*--------------
Defining paths
--------------*/

global main "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$main\Data"
global output "$main\output"

global eval_analysis "$output\eval_analysis_w_socratic"
cap mkdir "$eval_analysis"
global tables "$eval_analysis\tables"
cap mkdir "$tables"
global graphs "$eval_analysis\graphs"
cap mkdir "$graphs"

use "$data\Clean_Full_Data.dta"

*****************************************************
*Defining controls for all regressions - later in subsections other controls are added
*****************************************************
	encode Cargo, gen(en_Cargo)
	encode Curso, gen(en_Curso)
	encode Género, gen(en_Gender)

	lab def position 1 Assistant 2 Auxiliary 3 Prosecutor 4 Judge
	lab val en_Cargo position
	lab def courses 1 Convention_Constitution 2 Constitutional_Interpretation 3 Jurisprudence 4 Reasoning 5 Virtues_Principles 6 Ethics
	lab val en_Curso courses 
	lab def gender 1 Female 2 Male
	lab val en_Gender gender

	tab Cargo, gen(cargo_)
	tab Curso, gen(curso_)
	tab Género, gen(gender_)

	lab var curso_1 Convention_Constitution
	lab var curso_2 Constitional_Interpretation
	lab var curso_3 Jurisprudence
	lab var curso_4 Reasoning
	lab var curso_5 Virtues_Principles
	lab var curso_6 Ethics

	lab var cargo_1 Assistant
	lab var cargo_2 Auxiliary
	lab var cargo_3 Prosecutor
	lab var cargo_4 Judge

	lab var gender_1 Female
	lab var gender_2 Male

	global controls1 i.en_Curso 
	global controls2 i.en_Curso Age_rounded i.en_Gender i.en_Cargo


*****************************************************
*Attrition and selection on observables
*****************************************************
	*Attrition for those who completed at baseline but not endline
	gen attrition=.
	replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
	replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
	tab attrition

	qui sum attrition, d
	local mean = round(`r(mean)', 0.001) 
	reg attrition $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\attrition.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label

	*Selection on obaservables 
	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\selection.xlsx", by(en_Estado_de_Cuestionario) pcompare stars se sheet(selection_en) sheetreplace
	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\selection.xlsx", by(bs_Estado_de_Cuestionario) pcompare stars se sheet(selection_bs) sheetreplace

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

	global controls3 i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_motivated_reasoner 
	global controls4 i.en_Curso Age_rounded i.en_Gender i.en_Cargo en_motivated_newsh bs_motivated_reasoner ///direction of motivated reasoning on average 

	local i = 1
	foreach y in en_motivated_reasoner en_motivated_intensity {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
	reg `y' $controls1 ,  cluster(Curso) 

		if(`i'==1){
	outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}

				local i = `i' + 1
				
	reg `y' $controls2 ,  cluster(Curso) 

		if(`i'==1){
	outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
				
	reg `y' $controls3 ,  cluster(Curso) 

		if(`i'==1){
	outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95)  addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
				
	reg `y' $controls4 ,  cluster(Curso) 

		if(`i'==1){
	outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95)  addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
	}

	*confirmation bias 
	*-> whether clicked on both briefs (and order if can extract time stamps)
	//Note: currently also counting those who did not click ay brief as exhibiting confirmation bias
	foreach x in bs en {
		gen `x'_conf_bias=1 if  `x'_Estado_de_Cuestionario=="Completo" //& (`x'_motivated_click_arga!=. | `x'_motivated_click_argb!=. )
		replace `x'_conf_bias=0 if `x'_motivated_click_arga!=. & `x'_motivated_click_argb!=. & `x'_Estado_de_Cuestionario=="Completo"
		tab `x'_conf_bias
	} 

	global controls5 i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_conf_bias 

	foreach y in en_conf_bias {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
	reg `y' $controls1 ,  cluster(Curso) 
	outreg2 using "$tables\conf_bias_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\conf_bias_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				
	reg `y' $controls5 ,  cluster(Curso) 
	outreg2 using "$tables\conf_bias_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

	*Curiosity

	global controls5 i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_motivated_info

	foreach y in en_motivated_info {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
	reg `y' $controls1 ,  cluster(Curso) 
	outreg2 using "$tables\curiosity_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\curiosity_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				
	reg `y' $controls3 ,  cluster(Curso) 
	outreg2 using "$tables\curiosity_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

**********************************************************************************************************
***IAT take up of exercise and feedback
*Analyze selection on observables for those who choose to take the test 
*Analyze selection on observables for receiving feedback or not 
**********************************************************************************************************
	*Selection on observables for takeup
	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_option_take_or_not==1, by(en_iat_player_skipped) pcompare stars se sheet(selection_iat_takeup) sheetreplace

	**Selection on observables for feedback
	gen en_ignore_feedback = 0 if en_iat_want_feedback!=.
	replace en_ignore_feedback =1 if en_iat_want_feedback==0 | en_iat_feedback_level==0 

	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_feedback_option_or_not==1, by(en_ignore_feedback) pcompare stars se sheet(selection_iat_feedback) sheetreplace

*****************************************************
*IAT scores
*****************************************************
	gen iat_score_change = en_iat_score-bs_iat_score

	*creating a dummy for whether they saw their feedback at baseline
	gen bs_saw_iat_feedback=0 if bs_iat_score!=.
	replace bs_saw_iat_feedback=1 if bs_iat_feedback_descriptive!="" & regex(bs_iat_feedback_descriptive, "No fue")==0
	tab bs_saw_iat_feedback
	count if bs_iat_score!=. //problem is that there is no variable which demarcates if the person was shown or not shown their feedback as bs_iat_feedback_descriptive is there for all the people so not sure who was not shown their feedback
	//need to check with Chris

	global controls6 i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_iat_score
	//global controls6iv i.en_Curso Age_rounded i.en_Gender i.en_Cargo (bs_iat_score=iat_option_take_or_not) 
	global controls7 i.en_Curso Age_rounded i.en_Gender i.en_Cargo iat_option_take_or_not  //iat_feedback_option_or_not

	//global controls6 i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_saw_iat_feedback //bs_saw_iat_feedback = iat_feedback_option_or_not
	*Analyze choice of receiving feedback depending on whether forced to take the IAT or opted in 

	local i = 1
	foreach y in en_iat_player_skipped en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls1 ,  cluster(Curso) 
	if(`i'==1){
	outreg2 using "$tables\iat_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				
	reg `y' $controls6 ,  cluster(Curso) 
	outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

	//ivreg2 `y' $controls6iv,  cluster(Curso) 
	//outreg2 using iat_regs.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

	reg `y' $controls7 ,  cluster(Curso) 
	outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

	***Looking at IAT results of only those who were forced to take the IAT - no selection issues at all
	local i = 1
	foreach y in en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls1 if iat_option_take_or_not==0,  cluster(Curso) 
	if(`i'==1){
	outreg2 using "$tables\iat_regs_forced.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls2 if iat_option_take_or_not==0,  cluster(Curso) 
	outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				
	reg `y' $controls6 if iat_option_take_or_not==0,  cluster(Curso) 
	outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

	//ivreg2 `y' $controls6iv if iat_option_take_or_not==0,  cluster(Curso) 
	//outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

	reg `y' $controls7 if iat_option_take_or_not==0,  cluster(Curso) 
	outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}


*****************************************************
*Altruism and Redistribution 
*****************************************************
	ren en_dictator_player_decision en_dictator_decision
	ren en_redistribute_player_decision en_redistribute_decision
	ren bs_dictator_player_decision bs_dictator_decision
	ren bs_redistribute_player_decision bs_redistribute_decision

	foreach x in dictator_decision redistribute_decision {
		gen `x'_change = en_`x'-bs_`x'
	}


	local i = 1
	foreach y in en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls1 ,  cluster(Curso) 
	if(`i'==1){
	outreg2 using "$tables\altruism_redistri_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\altruism_redistri_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\altruism_redistri_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}



*****************************************************
*Trolley
*****************************************************
	gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
	gen trolley_version = bs_trolley_treatment
	replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
	encode trolley_version, gen(en_trolley_version)
	global controls8 i.en_Curso Age_rounded i.en_Gender i.en_Cargo i.en_trolley_version

	local i = 1
	foreach y in en_trolley_decision trolley_decision_change {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls1 ,  cluster(Curso) 
	if(`i'==1){
	outreg2 using "$tables\trolley.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

				
	reg `y' $controls8 ,  cluster(Curso) 
	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}


*****************************************************
*Book choice
*****************************************************
	encode en_participant_book_choice, gen(en_book)

	lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
	lab val en_book endbook

	tab en_book, gen(en_book_topic)

	local i = 1
	foreach y of varlist en_book_topic* {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls1 ,  cluster(Curso) 
	if(`i'==1){
	outreg2 using "$tables\book_choice.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\book_choice.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls2 ,  cluster(Curso) 
	outreg2 using "$tables\book_choice.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

	}

***********
**GRAPHS
***********
**all controls: 
//controls(cargo_* Age_rounded gender_*) 
**some favorable + interesting effects of courses (variable en_Curso) are:
//en_trolley_decision 
//trolley_decision_change 
//en_book_topic4
//en_book_topic5 
//iat_score_change 
//en_iat_want_feedback
//conf_bias

	global controls1 i.en_Curso 
	global controls2 i.en_Curso Age_rounded i.en_Gender i.en_Cargo
	global controls_trolley i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_trolley_decision
	global controls_iatfeedback i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_iat_want_feedback
	global controls_confbias i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_conf_bias
	global controls_motivated i.en_Curso Age_rounded i.en_Gender i.en_Cargo bs_motivated_reasoner

	reg en_trolley_decision $controls_trolley ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference by Course") saving("$graphs\trolley1.gph", replace) 

	reg trolley_decision_change $controls2 ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference Change by Course") saving("$graphs\trolley2.gph", replace) 

	graph combine "$graphs\trolley1.gph" "$graphs\trolley2.gph", ycommon saving("$graphs\AmagExhibit1", replace)

	reg en_book_topic4 $controls2 ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Just Decision") saving("$graphs\book1.gph", replace) 

	reg en_book_topic5 $controls2 ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Reasoning") saving("$graphs\book2.gph", replace) 

	graph combine "$graphs\book1.gph" "$graphs\book2.gph", ycommon saving("$graphs\AmagExhibit2", replace)

	reg iat_score_change $controls2 ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("IAT score change") saving("$graphs\iat_score_change.gph", replace)

	reg en_iat_want_feedback $controls_iatfeedback ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Whether want feedback for IAT") saving("$graphs\iat_feedback.gph", replace) 

	graph combine "$graphs\book1.gph" "$graphs\book2.gph", ycommon saving("$graphs\AmagExhibit3", replace)

	reg en_motivated_reasoner $controls_motivated ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Motivated reasoning") saving("$graphs\motivated.gph", replace) 

	reg en_conf_bias $controls_confbias ,  cluster(Curso) 
	coefplot, drop(Age_rounded i.en_Gender i.en_Cargo) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Confirmation Bias") saving("$graphs\conf_bias.gph", replace) 

	graph combine "$graphs\motivated.gph" "$graphs\conf_bias.gph" , ycommon saving("$graphs\AmagExhibit4", replace)


	/*
	binscatter en_trolley_decision curso_6, controls(cargo_* Age_rounded gender_*) xtitle("Inmates released in March / population") ytitle("Covid-19 cases / population") savegraph(march.gph) replace
	binscatter  positivecasesperpop povertyrate, controls(marchreleaseperpop publictransitutilrate  percentblack population) nq(100)  xtitle("Poverty rate") ytitle("Covid-19 cases / population") savegraph(povertyrate.gph) replace
	binscatter  positivecasesperpop percentblack, controls(povertyrate publictransitutilrate  marchreleaseperpop population) nq(100)  xtitle("% Black population") ytitle("Covid-19 cases / population") savegraph(percentblack.gph) replace
	binscatter  positivecasesperpop publictransitutilrate, controls(povertyrate marchreleaseperpop  percentblack population) nq(100)  xtitle("Public transit utilization rate") ytitle("Covid-19 cases / population") savegraph(publictransitutilrate.gph) replace
	binscatter  positivecasesperpop population, controls(povertyrate marchreleaseperpop  percentblack publictransitutilrate) nq(100) xtitle("Population density") ytitle("Covid-19 cases / population") savegraph(density.gph) replace
	graph combine march.gph povertyrate.gph percentblack.gph publictransitutilrate.gph density.gph, ycommon saving(AppendixExhibit1, replace)
	*/

**********************
**Socratic Video
**********************
	gen saw_video = . 
	replace saw_video=1 if bs_participant_index_in_pages>16 & bs_participant_index_in_pages!=.
	replace saw_video=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<=16 & bs_participant_index_in_pages!=.

	gen socratic_actual = 0 if saw_video==0 
	replace socratic_actual=1 if saw_video==1 & socratic_treated==1

	global controls_socitt socratic_treated 
	global controls_socitt2 socratic_treated i.en_Curso Age_rounded i.en_Gender i.en_Cargo
	global controls_soctot (socratic_actual=socratic_treated) i.en_Curso Age_rounded i.en_Gender i.en_Cargo 

	*Balance on observables 
	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\soc_balance.xlsx", by(socratic_treated) pcompare stars se sheet(soc_balance_itt) sheetreplace count
	orth_out cargo_* curso_* gender_1 Age_rounded using "$tables\soc_balance.xlsx", by(socratic_actual) pcompare stars se sheet(socratic_actual) sheetreplace count


	***Outcomes
	local i = 1
	foreach y of varlist attrition en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_trolley_decision trolley_decision_change en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change en_iat_player_skipped en_iat_score en_iat_want_feedback en_iat_feedback_level  en_book_topic2 - en_book_topic5  { //iat_score_change
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
	reg `y' $controls_socitt ,  r 
	if(`i'==1){
	outreg2 using "$tables\socratic.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
	outreg2 using "$tables\socratic.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}
				
	local i = `i' + 1
				
	reg `y' $controls_socitt2 ,  r
	outreg2 using "$tables\socratic.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

	ivreg2 `y' $controls_soctot ,  r
	outreg2 using "$tables\socratic.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

















