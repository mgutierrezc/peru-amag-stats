cls
/*=============================
Regressions for Peru Amag II

---
author: Ronak Jain, Mayumi Cornejo, 
Jose Maria Rodriguez Valadez
editor: Marco Gutierrez
=============================*/

clear all
set more off
program drop _all

/*=====
Setting up directories
=====*/

*di `"Please, input the main path where the required data for running this dofile is stored into the COMMAND WINDOW and then press ENTER  "'  _request(path)
global path "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$path\Data"
global output "$path\output"
global modules "$path\Code\Analysis\Modules"

global docs "$output\eval_regs"
cap mkdir "$docs"

global tables "$docs\tables"
cap mkdir "$tables"

global graphs "$docs\graphs"
cap mkdir "$graphs"

cd "$data"
use "Clean_Full_Data12.dta"   /// stata 12 friendly


/*=====
Cleaning and variable generation
=====*/
	do "$modules\cleaner_gen.do"
	rename age2 Age_squared
	

/*=====
Selection on observables
=====*/
	orth_out position_* course_* gender_1 Age_rounded using "$tables\selection.xlsx", by(en_Estado_de_Cuestionario) pcompare stars se sheet(selection_en) sheetreplace
	orth_out position_* course_* gender_1 Age_rounded using "$tables\selection.xlsx", by(bs_Estado_de_Cuestionario) pcompare stars se sheet(selection_bs) sheetreplace


/*=====
Changes in Behavior: Motivated reasoning, 
Curiosity and Confirmation Bias
=====*/	

	do "$modules\motiv_curios_conf_bias.do"

	
/*=====
Changes in Behavior: Gender Biases
IAT
=====*/

	do "$modules\iat_treatment_effs.do"
	
	
/*=====
Trolley 
=====*/

	do "$modules\trolley_regs.do"


/*=====
Book Choices 
=====*/

	do "$modules\book_regs.do"
	
	
e
// *****************************************************
// *Altruism and Redistribution 
// *****************************************************
// 	ren en_dictator_player_decision en_dictator_decision
// 	ren en_redistribute_player_decision en_redistribute_decision
// 	ren bs_dictator_player_decision bs_dictator_decision
// 	ren bs_redistribute_player_decision bs_redistribute_decision
//
// 	foreach x in dictator_decision redistribute_decision {
// 		gen `x'_change = en_`x'-bs_`x'
// 	}
//
//
// 	local i = 1
// 	foreach y in en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change {
// 		qui sum `y', d
// 		local mean = round(`r(mean)', 0.001) 
//		
// 	reg `y' $controls1 ,  cluster(Course) 
// 	if(`i'==1){
// 	outreg2 using "$tables\altruism_redistri_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
// 		} 
// 		else{
// 	outreg2 using "$tables\altruism_redistri_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
// 				}
//				
// 	local i = `i' + 1
//				
// 	reg `y' $controls2 ,  cluster(Course) 
// 	outreg2 using "$tables\altruism_redistri_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
// 	}
//
//
//
// 	*****************************************************
// 	*Trolley
// 	*****************************************************
// 	gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
// 	gen trolley_version = bs_trolley_treatment
// 	replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
// 	encode trolley_version, gen(en_trolley_version)
// 	global controls8 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position i.en_trolley_version
//
// 	local i = 1
// 	foreach y in en_trolley_decision trolley_decision_change {
// 		qui sum `y', d
// 		local mean = round(`r(mean)', 0.001) 
//		
// 	reg `y' $controls1 ,  cluster(Course) 
// 	if(`i'==1){
// 	outreg2 using "$tables\trolley.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
// 		} 
// 		else{
// 	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
// 				}
//				
// 	local i = `i' + 1
//				
// 	reg `y' $controls2 ,  cluster(Course) 
// 	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
//
//				
// 	reg `y' $controls8 ,  cluster(Course) 
// 	outreg2 using "$tables\trolley.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
// 	}
//
//
// 	*****************************************************
// 	*Book choice
// 	*****************************************************
// 	encode en_participant_book_choice, gen(en_book)
//
// 	lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
// 	lab val en_book endbook
//
// 	tab en_book, gen(en_book_topic)
//
// 	local i = 1
// 	foreach y of varlist en_book_topic* {
// 		qui sum `y', d
// 		local mean = round(`r(mean)', 0.001) 
//		
// 	reg `y' $controls1 ,  cluster(Course) 
// 	if(`i'==1){
// 	outreg2 using "$tables\book_choice.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
// 		} 
// 		else{
// 	outreg2 using "$tables\book_choice.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
// 				}
//				
// 	local i = `i' + 1
//				
// 	reg `y' $controls2 ,  cluster(Course) 
// 	outreg2 using "$tables\book_choice.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
//
// 	}
//
// ***********
// **GRAPHS
// ***********
// **all controls: 
// //controls(cargo_* Age_rounded gender_*) 
// **some favorable + interesting effects of courses (variable en_Curso) are:
// //en_trolley_decision 
// //trolley_decision_change 
// //en_book_topic4
// //en_book_topic5 
// //iat_score_change 
// //en_iat_want_feedback
// //conf_bias
//
// 	global controls1 i.en_Course 
// 	global controls2 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position
// 	global controls_trolley i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_trolley_decision
// 	global controls_iatfeedback i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_iat_want_feedback
// 	global controls_confbias i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_conf_bias
// 	global controls_motivated i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_motivated_reasoner
//
// 	reg en_trolley_decision $controls_trolley ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference by Course") saving("$graphs\trolley1.gph", replace) 
//
// 	reg trolley_decision_change $controls2 ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Utilitarian Preference Change by Course") saving("$graphs\trolley2.gph", replace) 
//
// 	graph combine "$graphs\trolley1.gph" "$graphs\trolley2.gph", ycommon saving("$graphs\AmagExhibit1", replace)
//
// 	reg en_book_topic4 $controls2 ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Just Decision") saving("$graphs\book1.gph", replace) 
//
// 	reg en_book_topic5 $controls2 ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Book: Reasoning") saving("$graphs\book2.gph", replace) 
//
// 	graph combine "$graphs\book1.gph" "$graphs\book2.gph", ycommon saving("$graphs\AmagExhibit2", replace)
//
// 	reg iat_score_change $controls2 ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("IAT score change") saving("$graphs\iat_score_change.gph", replace)
//
// 	reg en_iat_want_feedback $controls_iatfeedback ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Whether want feedback for IAT") saving("$graphs\iat_feedback.gph", replace) 
//
// 	graph combine "$graphs\book1.gph" "$graphs\book2.gph", ycommon saving("$graphs\AmagExhibit3", replace)
//
// 	reg en_motivated_reasoner $controls_motivated ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Motivated reasoning") saving("$graphs\motivated.gph", replace) 
//
// 	reg en_conf_bias $controls_confbias ,  cluster(Course) 
// 	coefplot, drop(Age_rounded i.en_Gender i.en_Position) xline(0) subtitle(, size(large) margin(medium) justification(left) color(white) bcolor(black) bmargin(top_bottom)) title("Confirmation Bias") saving("$graphs\conf_bias.gph", replace) 
//
// 	graph combine "$graphs\motivated.gph" "$graphs\conf_bias.gph" , ycommon saving("$graphs\AmagExhibit4", replace)
//
//
// 	/*
// 	binscatter en_trolley_decision curso_6, controls(cargo_* Age_rounded gender_*) xtitle("Inmates released in March / population") ytitle("Covid-19 cases / population") savegraph(march.gph) replace
// 	binscatter  positivecasesperpop povertyrate, controls(marchreleaseperpop publictransitutilrate  percentblack population) nq(100)  xtitle("Poverty rate") ytitle("Covid-19 cases / population") savegraph(povertyrate.gph) replace
// 	binscatter  positivecasesperpop percentblack, controls(povertyrate publictransitutilrate  marchreleaseperpop population) nq(100)  xtitle("% Black population") ytitle("Covid-19 cases / population") savegraph(percentblack.gph) replace
// 	binscatter  positivecasesperpop publictransitutilrate, controls(povertyrate marchreleaseperpop  percentblack population) nq(100)  xtitle("Public transit utilization rate") ytitle("Covid-19 cases / population") savegraph(publictransitutilrate.gph) replace
// 	binscatter  positivecasesperpop population, controls(povertyrate marchreleaseperpop  percentblack publictransitutilrate) nq(100) xtitle("Population density") ytitle("Covid-19 cases / population") savegraph(density.gph) replace
// 	graph combine march.gph povertyrate.gph percentblack.gph publictransitutilrate.gph density.gph, ycommon saving(AppendixExhibit1, replace)
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
