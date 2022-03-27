/***********
**Motivated reasoning, Curiosity 
and Confirmation Bias Module

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

	/*-----
	Motivated Reasoning
	
	===
	Note: The way the question was asked the 
	values capture the chance it was true news
	-----*/	

	**Second set of controls
	global controls3 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_motivated_reasoner 
	global controls4 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position en_motivated_newsh bs_motivated_reasoner ///direction of motivated reasoning on average 

	local i = 1
	foreach y in en_motivated_reasoner en_motivated_intensity {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		reg `y' $controls1 ,  cluster(Course) 

		if(`i'==1){
	outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
				}

				local i = `i' + 1
				
		reg `y' $controls2 ,  cluster(Course) 

		if(`i'==1){
			outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
				
		reg `y' $controls3 ,  cluster(Course) 

		if(`i'==1){
			outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95)  addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
				
		reg `y' $controls4 ,  cluster(Course) 

		if(`i'==1){
			outreg2 using "$tables\motivated_reasoning_regs.xls", replace stats(coef pval ) level(95)  addtext(mean, `mean') label
		} 
		else{
			outreg2 using "$tables\motivated_reasoning_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
				}
	}

	
	/*-----
	Confirmation Bias
	
	===
	Notes: 	
	- Not biased if clicked on both briefs 
	- Currently also counting those who did not 
	click any brief as exhibiting confirmation bias
	- TODO: check order if available from time stamps)
	-----*/	

	**Third set of controls
	global controls5 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_conf_bias 

	**Confirmation bias regressions
	foreach y in en_conf_bias {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		reg `y' $controls1 ,  cluster(Course) 
		outreg2 using "$tables\conf_bias_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
					
		reg `y' $controls2 ,  cluster(Course) 
		outreg2 using "$tables\conf_bias_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
					
		reg `y' $controls5 ,  cluster(Course) 
		outreg2 using "$tables\conf_bias_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

	
	/*-----
	Curiosity
	-----*/
	
	**Third set of controls (redefined)
	global controls5 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_motivated_info

	foreach y in en_motivated_info {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		reg `y' $controls1 ,  cluster(Course) 
		outreg2 using "$tables\curiosity_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
					
		reg `y' $controls2 ,  cluster(Course) 
		outreg2 using "$tables\curiosity_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
					
		reg `y' $controls3 ,  cluster(Course) 
		outreg2 using "$tables\curiosity_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}