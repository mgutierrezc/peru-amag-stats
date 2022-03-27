cls
/*=============================
Statistics for Peru Amag IAT

---
author: Jose Maria Rodriguez Valadez
editor: Marco Gutierrez
=============================*/

clear all
set more off

/*=====
Setting up directories
=====*/

*di `"Please, input the main path where the required data for running this dofile is stored into the COMMAND WINDOW and then press ENTER  "'  _request(path)
global path "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$path\Data"
global output "$path\output"
global modules "$path\Code\Analysis\Modules"

global docs "$output\eval_analysis_docs"
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
	
	
/*=====
IAT take up of exercise and feedback
=====*/

	
	/*-----
	IAT Scores
	-----*/
	
	*defining macros for controls
	global controls2    i.en_Course Age_rounded age2 i.en_Gender i.en_Position
	global controls6    i.en_Course Age_rounded age2 i.en_Gender i.en_Position z_bs_iat_score
	global controls62   i.en_Course Age_rounded age2 i.en_Gender i.en_Position z_bs_iat_score z_bs_iat_score2
	global controls6r   i.en_Course Age_rounded age2 i.en_Gender i.en_Position iat_option_take_or_not   
	global controls6iv  i.en_Course Age_rounded age2 i.en_Gender i.en_Position (z_bs_iat_score=iat_option_take_or_not)
	global controls7    i.en_Course Age_rounded age2 i.en_Gender i.en_Position seen_iat_feedback  
	global controls7r   i.en_Course Age_rounded age2 i.en_Gender i.en_Position iat_feedback_option_or_not
	global controls7iv i.en_Course Age_rounded age2 i.en_Gender i.en_Position (seen_iat_feedback  = iat_feedback_option_or_not)
	global controlsint  i.en_Course Age_rounded age2 i.en_Gender i.en_Position iat_feedback_option_or_not##iat_option_take_or_not
	
	
	*Regressions for standardized variables
	local i = 1
	foreach y in z_en_iat_score z_iat_score_change  z_en_motivated_reasoner z_en_motivated_intensity z_en_conf_bias z_en_motivated_info z_en_trolley_decision z_trolley_decision_change z_en_dictator_decision z_dictator_decision_change  z_en_redistribute_decision z_redistribute_decision_change   z_en_book_topic1   z_en_book_topic2   z_en_book_topic3  z_en_book_topic4  z_sat_instructor z_sat_exp sat_course z_sat_avg z_grade z_pass{ //en_iat_player_skipped  en_iat_want_feedback en_iat_feedback_level
		
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
		reg `y' $controls2 ,  cluster(Course) 

		if(`i'==1){
		outreg2 using "$tables/iat_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
			} 
			else{
		outreg2 using "$tables/iat_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
					}
					
		local i = `i' + 1
					
		reg `y' $controls6 ,  cluster(Course) 
		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
					
		reg `y' $controls6r ,  cluster(Course) 
		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
		
		reg `y' $controls62 ,  cluster(Course) 
		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
		
		*can't use IAT feedback variable
// 		ivreg2 `y' $controls6iv,  cluster(Course) 
// 		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

// 		reg `y' $controls7 ,  cluster(Course) 
// 		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

		reg `y' $controls7r ,  cluster(Course) 
		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

// 		ivreg2 `y' $controls7iv ,  cluster(Course) 
// 		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

		reg `y' $controlsint ,  cluster(Course) 
		outreg2 using "$tables/iat_regs_.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}
	
	
	/*-----
	IAT Interaction effects and IV approach
	-----*/
	
	*defining controls for regressions
	global controlsint   i.en_Course Age_rounded age2 i.en_Gender i.en_Position iat_feedback_option_or_not##iat_option_take_or_not
	global controlsinta  i.en_Course Age_rounded age2 i.en_Gender i.en_Position i.iat_interaction
	
	*Regressions for standardized variables
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
		 xlabel(0 "No option" 1 "Option to skip" , labsize(small) noticks) xtitle("RHS: Option to skip IAT test (base/end)", size(small)) ///
		 ytitle("LHS: `mylabel' (end)") ///  
		 graphregion(color(white)) ///
		 note("Dependent variable is normalized to an index between 0 and 1." "Number of observations = `nobs'. Treatment coefficient: `coef1'." "P-value of F-test for coefficient equality of interaction term is `pval'. ", size(small)) ///
		 caption("Estimations obtained from OLS regressions include the following controls: age, age squared, gender, course dummies and position dummies" , size(vsmall))
		graph export "$graphs/`y'_1_iatint.png", replace
	}
	
	
	global controls6iv  (i.bs_iat_player_skipped=i.iat_option_take_or_not)  i.en_Course Age_rounded age2 i.en_Gender i.en_Position  
// 		global controls7iv  (i.seen_iat_feedback  = i.iat_feedback_option_or_not) i.en_Course Age_rounded i.en_Gender i.en_Position 
	
	*if player didn't choose whether to take the iat, it'll be considered as if he didn't skip it on baseline
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
		 xlabel(0 "No" 1 "Yes", noticks) xtitle("RHS: Player skipped IAT (baseline)") ///
		 ytitle("LHS: `mylabel' (end)") ///
		 graphregion(color(white)) ///
		 note("Dependent variable is normalized to an index between 0 and 1." "Number of observations = `nobs'. 'Skipped IAT' coefficient: `coef1'." "P-value of F-test for skipped IAT coefficient equality across categories is `pval'. ", size(small)) ///
		 caption("Instrumental variables regressions where the randomized option to skip the IAT test" ///
		 "is the instrumental variable. Model includes the following independent variables: age, age squared, gender, course and position" , size(vsmall))

		graph export "$graphs/`y'_2_iviatskip.png", replace

	}