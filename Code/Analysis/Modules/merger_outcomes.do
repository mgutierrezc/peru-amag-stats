/***********
**Merging with Judges
Outcomes Module

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/


	/*-----
	Creating dtas from csvs
	Note: pres/rest to avoid changing the base dataset with each dta generation
	-----*/
	
	**Month Resolutions	
	preserve
		import delimited "$judges_outcomes\dataset_caseid_month_resolution_post.csv", clear
		rename nrodocumento DNI
		save "$judges_outcomes\month_resol_post", replace
	restore

	**Month Funded Resolutions	
	preserve
		import delimited "$judges_outcomes\dataset_caseid_month_fundada_post.csv", clear
		rename nrodocumento DNI
		save "$judges_outcomes\month_resol_fundada", replace
	restore

	**Month-Days to Resolution
	preserve
		import delimited "$judges_outcomes\dataset_caseid_month_days_to_res_post.csv", clear
		rename nrodocumento DNI
		save "$judges_outcomes\month_resol_days_to_res", replace
	restore
	
	/*-----
	Merging datasets and identifying unique participants
	-----*/
	
	**Month Resolutions	
	preserve
		drop if DNI == .
		qui merge 1:m DNI using "$judges_outcomes\month_resol_post"
			
		keep if _m == 3
		drop _m
		
		duplicates drop DNI, force
		table iat_option_take_or_not 
		table iat_feedback_option_or_not
	restore
		
	**Month Funded Resolutions	
	preserve
		drop if DNI == .
		qui merge 1:m DNI using "$judges_outcomes\month_resol_fundada"
			
		keep if _m == 3
		drop _m
		
		duplicates drop DNI, force
		table iat_option_take_or_not 
		table iat_feedback_option_or_not
	restore
	
	**Month-Days to Resolution
	preserve 
		drop if DNI == .
		qui merge 1:m DNI using "$judges_outcomes\month_resol_days_to_res"
		
		keep if _m == 3
		drop _m
		
		duplicates drop DNI, force
		table iat_option_take_or_not 
		table iat_feedback_option_or_not
	restore
