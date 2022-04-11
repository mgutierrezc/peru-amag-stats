/***********
**Regressions for treatment effects
on Trolley

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

	/*-----
	Trolley regressions
	-----*/
	
	**defining controls
	global controls i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position
	global controls_miss "en_Course, Age_rounded, Age_squared, en_Gender, en_Position"
	
	tab en_trolley_treat, gen(en_trolley_treat_fac)
	
	**Regressions no IAT interaction
	local reg_counter = 1
	foreach y in z_en_trolley_decision { // issue: no obs for decision change
		
		**No controls
		qui:reg `y' en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3, vce(cluster Course) // regression no controls
		if(`reg_counter'==1){ // creating outreg file
			outreg2 using "$tables\en_trolley_treat.xls", replace stats(coef pval ) level(95) addtext("Controls", "No") label keep(en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3) nocons nor2
			} 
		else{ // storing reg output in outreg file
			outreg2 using "$tables\en_trolley_treat.xls", append stats(coef pval ) level(95) addtext("Controls", "No") label keep(en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3) nocons nor2
		}
		
		**Controls
		qui sum `y' if iat_feedback_option_or_not==0 & !missing($controls_miss), d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		qui:reg `y' en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3 $controls, vce(cluster Course) // regression with controls
		outreg2 using "$tables\en_trolley_treat.xls", append stats(coef pval ) level(95) addtext("Controls", "Yes") label keep(en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3) nocons nor2 // storing r
		local reg_counter = `reg_counter' + 1
	}
	
	
	**Regressions IAT interaction
	local reg_counter = 1
	foreach y in z_en_trolley_decision { // issue: no obs for decision change
		
		**No controls
		qui:reg `y' en_trolley_treat_fac1##iat_option_take_or_not en_trolley_treat_fac2 en_trolley_treat_fac3##iat_option_take_or_not, vce(cluster Course) // regression no controls
		if(`reg_counter'==1){ // creating outreg file
			outreg2 using "$tables\en_trolley_treat_iat.xls", replace stats(coef pval ) level(95) addtext("Controls", "No") label keep(en_trolley_treat_fac1 en_trolley_treat_fac2 en_trolley_treat_fac3) nocons nor2
			} 
		else{ // storing reg output in outreg file
			outreg2 using "$tables\en_trolley_treat_iat.xls", append stats(coef pval ) level(95) addtext("Controls", "No") label nocons nor2
		}
		
		**Controls
		qui sum `y' if iat_feedback_option_or_not==0 & !missing($controls_miss), d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		qui:reg `y' en_trolley_treat_fac1##iat_option_take_or_not en_trolley_treat_fac2 en_trolley_treat_fac3##iat_option_take_or_not $controls, vce(cluster Course) // regression with controls
		outreg2 using "$tables\en_trolley_treat_iat.xls", append stats(coef pval ) level(95) addtext("Controls", "Yes") label nocons nor2 // storing r
		local reg_counter = `reg_counter' + 1
	}
	
	
	