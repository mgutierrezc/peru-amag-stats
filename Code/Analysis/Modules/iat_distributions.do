

/*=============================
Distribution plots
=============================*/


global plots "/Users/josemariarodriguezvaladez/Documents/DIME/plots"




* Define labels
label define iat_option 0 "No option to skip" 1 "Option to skip"
label values iat_option_take_or_not iat_option
label define want_feedback 0 "Didn't want feedback" 1 "Wanted feedback"
label values en_iat_want_feedback want_feedback
label values bs_iat_want_feedback want_feedback
label var bs_iat_score "IAT Score (Baseline)"
label var en_iat_score "IAT Score (Endline)"
label var iat_score_change "IAT Score Change"


* ---- Descriptive statistics plots


 kdensity z_bs_iat_score, addplot(kdensity z_en_iat_score,  recast(line) lpattern(dash))  /// 
 title("Distribution of IAT scores", size (medsmall)) note("Nb = 402, Ne = 243", size(small)) ///
 caption("mean (base) .50, (en) .49", size(small)) ///
 xline(.5002336, lwidth(vvthin)) ///
 xline(.4908339, lwidth(vvthin) lpattern(dash)) 



 *ssc install blindschemes
 set scheme plotplain
 
 kdensity bs_iat_score if iat_option_take_or_not == 0, addplot(kdensity z_bs_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
 legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
 title("Distribution of IAT scores (Baseline)", size (medsmall))  ///
 note("")

 graph export "$plots/density_bsiat.png"
 
 
 preserve
	 keep if iat_score_change !=.
	 kdensity en_iat_score if iat_option_take_or_not == 0, addplot(kdensity z_en_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
	 legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
	 title("Distribution of IAT scores (Endline)", size (medsmall))  ///
	 note("")

	 graph export "$plots/density_eniat.png"
 restore
 
 	 kdensity iat_score_change if iat_option_take_or_not == 0, addplot(kdensity z_en_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
	 legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
	 title("Distribution of IAT Score Change", size (medsmall))  ///
	 note("")
 

 histogram en_iat_want_feedback, discrete by(iat_option_take_or_not, ///
 title("Want feedback (endline) by Option to Take IAT")) ///
 xlabel(0(1)1.0) 
 
  graph export "$plots/hist_enwantfb_byoption.png"
 


  kdensity z_bs_iat_score if iat_option_take_or_not == 0, ///
  addplot(kdensity z_bs_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
  legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
  title("Distribution of IAT scores, baseline", size (medsmall))  ///
  note("")

  graph export "$plots/density_eniat.png"
 
  kdensity z_en_iat_score if iat_option_take_or_not == 0, ///
  addplot(kdensity z_en_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
  legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
  title("Distribution of IAT scores, endline", size (medsmall))  ///
  note("")

  graph export "$plots/density_eniat.png"


* For those treated: how
  kdensity z_en_iat_score if iat_option_take_or_not == 0 &  bs_iat_player_skipped  == . , ///
  addplot(kdensity z_en_iat_score if iat_option_take_or_not == 1& bs_iat_player_skipped  == 0,  recast(line) lpattern(dash)) ///
  legend(order(1 "Option to Take IAT = 0, skipped baseline = 0 " 2 "Option to Take IAT = 1, skipped baseline = 0") size(small)) ///
  title("Distribution of endline IAT scores", size (medsmall))  ///
  note("")

  graph export "$plots/density_eniat.png" 
 
 
 
 kdensity z_en_iat_score  if iat_option_take_or_not == 1  & bs_iat_player_skipped  == 1,  ///
 addplot(kdensity z_en_iat_score if iat_option_take_or_not == 1 & bs_iat_player_skipped  == 0,  recast(line) lpattern(dash) ///
 || kdensity z_en_iat_score if iat_option_take_or_not == 0,  recast(line) lpattern(shortdash))  ///
 legend(order(1 "Option to Take IAT = 1, Skip Baseline = 1 " 2 "Option to Take IAT = 1, Skip Baseline = 0" 3 "Option to Take IAT = 0") size(small)) ///
 title("Distribution of IAT scores, endline", size (medsmall))  ///
 note("")
 
 
 graph export "$plots/density_eniat_skipbs.png"






histogram en_iat_player_skipped, discrete frequency xtitle("skipped endline") xlabel(0(1)1) by(, title("Skiped endline by skipped baseline") note("plots by whether they skipped baseline or not, Skipped both = 13, Skipped neither = 57", size(vsmall))) scale(1) by(bs_iat_player_skipped)
graph export "$plots/histogram_skipped_fr.png", replace
 
histogram en_iat_player_skipped, discrete xtitle("skipped endline") xlabel(0(1)1) by(, title("Skiped endline by skipped baseline") note("plots by whether they skipped baseline or not, Skipped both = 13, Skipped neither = 57", size(vsmall))) scale(1) by(bs_iat_player_skipped)
graph export "$plots/histogram_skipped.png", replace
  
 
histogram en_iat_want_feedback, discrete xlabel(0(1)1) by(, title(Wanted feedback endline by skipped at baseline) note("plots by whether they skipped baseline or not; Skipped = 6, Didn't skip = 27", size(vsmall))) scale(1) by(bs_iat_player_skipped)
graph export "$plots/histogram_wantfeedback_bsskip.png", replace
 

histogram en_iat_want_feedback, discrete xlabel(0(1)1) by(, title("Wanted Feedback endline by Option to Take treatment") note("plots by treatment status (option to take IAT; N0 = 134, N1 = 58)", size(vsmall))) scale(1) by(iat_option_take)
graph export "$plots/histogram_wantfeedback_treatoption.png", replace
