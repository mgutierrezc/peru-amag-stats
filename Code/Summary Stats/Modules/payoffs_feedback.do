/***********
**Payoffs feedback module

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

/*=====
Labeling data and var
=====*/

	label var bs_iat_feedback_level "Credits spent feedback (Baseline)"
	label var en_iat_feedback_level "Credits spent feedback (Endline)"

/*=====
Stats and plots
=====*/

	*ssc install blindschemes
	set scheme plotplain

	*Filtering for all participants in both bs and end
	preserve
	
		*applying filter
		keep if bs_iat_feedback_level != . & en_iat_feedback_level != .
		
		*Feedback level (baseline)
		sum bs_iat_feedback_level
		hist bs_iat_feedback_level
		
		*Feedback level (endline)
		sum en_iat_feedback_level
		hist en_iat_feedback_level
	
	restore