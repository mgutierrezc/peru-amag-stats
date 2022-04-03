log using codebook.smcl, replace
codebook,compact
log close
translate codebook.smcl coodebook.pdf

global controls writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup

/*****************************************************************************************************
						Table 1 - Balance of Treatment on Individual Characteristics (not matching slightly off)
*****************************************************************************************************/
use "cleaned data.dta",clear

eststo clear
global controls1  interviewmarks gender birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup
eststo:qui:reg writtenmarks metrics_assigned metrics_selected $controls1 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls3 writtenmarks interviewmarks birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup
eststo:qui:reg gender metrics_assigned metrics_selected $controls3 if in_model_2 == 1 , vce(cluster participantid_in_session) 
global controls4 writtenmarks interviewmarks gender land income age dedu4 out pas psp fbr fsp othersgroup
eststo:qui:reg birthpcapital metrics_assigned metrics_selected $controls4 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls5 writtenmarks interviewmarks gender birthpcapital land age dedu4 out pas psp fbr fsp othersgroup
eststo:qui:reg income metrics_assigned metrics_selected $controls5 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls6 writtenmarks interviewmarks gender birthpcapital land income dedu4 out pas psp fbr fsp othersgroup
eststo:qui:reg age metrics_assigned metrics_selected $controls6 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls7 writtenmarks interviewmarks gender birthpcapital land income age out pas psp fbr fsp othersgroup
eststo:qui:reg dedu4 metrics_assigned metrics_selected $controls7 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls8 writtenmarks interviewmarks gender birthpcapital land income age dedu4 pas psp fbr fsp othersgroup
eststo:qui:reg out metrics_assigned metrics_selected $controls8 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls9 writtenmarks interviewmarks gender birthpcapital land income age dedu4 out psp fbr fsp othersgroup
eststo:qui:reg pas metrics_assigned metrics_selected $controls9 if in_model_2 == 1 , vce(cluster participantid_in_session)
global controls10 writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas fbr fsp othersgroup
eststo:qui:reg psp metrics_assigned metrics_selected $controls10 if in_model_2 == 1 , vce(cluster participantid_in_session)
// drop othergroups
// gen othergroups = 0 if fbr == 0 | fsp == 0 | othersgroup
// replace othergroups = 1 if othersgroup == 1 | fbr == 1 | fsp == 1
// br othersgroup fbr fsp othergroups
global controls11 writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas
eststo:qui:reg othergroups metrics_assigned metrics_selected $controls11 if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg writtenmarks metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg interviewmarks metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
esttab using table1.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum writtenmarks gender birthpcapital income age dedu4 out pas psp othergroups writtenmarks interviewmarks

/*****************************************************************************************************
						Table 2 - Effect of Metrics Training on Beliefs - Original
*****************************************************************************************************/
use "cleaned data.dta",clear

eststo clear
eststo:qui:reg Rating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
sum Rating_Quant_Imp if metrics_assigned == 0
eststo:qui:reg PostVideoRating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
sum PostVideoRating_Quant_Imp if metrics_assigned == 0
eststo:qui:reg qualitative metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
sum qualitative if metrics_assigned == 0
eststo:qui:reg postqualitative metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
sum postqualitative if metrics_assigned == 0
eststo:qui:reg RCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_1 == 1 , vce(cluster participantid_in_session)
sum RCTdummy_publicpolicy if metrics_assigned == 0
eststo:qui:reg NewRCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_1 == 1 , vce(cluster participantid_in_session)
sum NewRCTdummy_publicpolicy if metrics_assigned == 0
eststo:qui:reg WhyRCT_dummy metrics_assigned metrics_selected $controls if in_model_1 == 1 , vce(cluster participantid_in_session)
sum WhyRCT_dummy if metrics_assigned == 0
eststo:qui:reg NewWhyRCT_dummy metrics_assigned metrics_selected $controls if in_model_1 == 1 , vce(cluster participantid_in_session)
sum NewWhyRCT_dummy if metrics_assigned == 0
esttab using table2.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

/*****************************************************************************************************
						Table 3 - Impact on Policymaking assesments - standardized (not matching)
*****************************************************************************************************/
use "WTP data file by defier.dta", clear

sum Score_Public_Goods
gen st_public_score = ( Score_Public_Goods-6.112676)/1.481483
sum Score_Teamwork
gen st_teamwork = ( Score_Teamwork - 6.455399)/1.47435
sum Score_Research_Method
gen st_reseacrh = ( Score_Research_Method- 6.347418)/ 1.536185

eststo clear
eststo:qui:reg st_public_score Metrics_assigned Metrics_chosen if in_model_4 ==1, vce(cluster RollNo)
eststo:qui:reg st_public_score Metrics_assigned Metrics_chosen $controls if in_model_4 ==1, vce(cluster RollNo)
eststo:qui:reg st_reseacrh Metrics_assigned Metrics_chosen if in_model_4 ==1, vce(cluster RollNo)
eststo:qui:reg st_reseacrh Metrics_assigned Metrics_chosen $controls if in_model_4 ==1, vce(cluster RollNo)
eststo:qui:reg st_teamwork Metrics_assigned Metrics_chosen if in_model_4 ==1, vce(cluster RollNo)
eststo:qui:reg st_teamwork Metrics_assigned Metrics_chosen $controls if in_model_4 ==1, vce(cluster RollNo)
esttab using table3.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum st_public_score st_reseacrh st_teamwork if Metrics_assigned == 0

/*****************************************************************************************************
						Table 4 - Effect of Metrics Training on Policy
*****************************************************************************************************/
use "cleaned data.dta",clear

eststo clear
eststo:qui:reg LetterNo metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg AmountforDeworming metrics_assigned metrics_selected  $controls if in_model_2 == 1, vce(cluster participantid_in_session)
eststo:qui:reg LetterNumber2 metrics_assigned metrics_selected  $controls if in_model_2 == 1, vce(cluster participantid_in_session)
eststo:qui:reg OrphanageRenovation metrics_assigned metrics_selected  $controls if in_model_2 == 1, vce(cluster participantid_in_session)
eststo:qui:reg LetterNumber3 metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
eststo:qui:reg SchoolRenovation metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
esttab using table4.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum LetterNo if metrics_assigned==0
sum AmountforDeworming if metrics_assigned==0
sum LetterNumber2 if metrics_assigned==0
sum OrphanageRenovation if metrics_assigned==0
sum LetterNumber3 if metrics_assigned==0
sum SchoolRenovation if metrics_assigned==0

/*****************************************************************************************************
						Table 5 - Shifting from initial beliefs on policy decisions
*****************************************************************************************************/
use "cleaned data.dta",clear

gen prior_13_dummy = 1 if Prior_Belief>13
replace prior_13_dummy = 0 if Prior_Belief<=13
gen delta_beliefs = Posterior_belief - Prior_Belief
gen int_delta_beliefs_prior = (delta_beliefs)*(prior_13_dummy)
gen int_metrics_prior = (metrics_assigned)*(prior_13_dummy)

global controls1 metrics_selected writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup
eststo clear
qui:eststo:ivreg LetterNo1 (  int_delta_beliefs_prior delta_beliefs  prior_13_dummy  = int_metrics_prior metrics_assigned   prior_13_dummy) if in_model_2==1, robust first
qui:eststo:ivreg LetterNo1 ( int_delta_beliefs_prior delta_beliefs prior_13_dummy = int_metrics_prior metrics_assigned prior_13_dummy) $controls1 if in_model_2==1, robust

qui:eststo:ivreg AmountforDeworming (int_delta_beliefs_prior delta_beliefs prior_13_dummy = int_metrics_prior metrics_assigned prior_13_dummy)  if in_model_2==1, robust first
qui:eststo:ivreg AmountforDeworming (int_delta_beliefs_prior delta_beliefs prior_13_dummy = int_metrics_prior metrics_assigned prior_13_dummy)  $controls1 if in_model_2==1, robust
esttab using table5.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum LetterNo1 if metrics_assigned==0
sum AmountforDeworming if metrics_assigned==0

/*****************************************************************************************************
						Table 6 - Effect of Metrics Training on WTP
*****************************************************************************************************/
use "WTP data file by defier.dta", clear

eststo clear
eststo:qui:reg Posterior1_Amount_RCT Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Posterior1_Amount_Admindata Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Posterior1_Amount_bureaucrat Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
esttab using table6_private.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

eststo clear
eststo:qui:reg Posterior2_Amount_RCT Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Prosterior2_Amount_Admindata Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Posterior2_Amount_bureaucrat Metrics_assigned Metrics_chosen  $controls if in_model_4 == 1 , vce(cluster RollNo )
esttab using table6_public.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum Posterior1_Amount_RCT if Metrics_assigned == 0
sum Posterior1_Amount_Admindata if Metrics_assigned == 0
sum Posterior1_Amount_bureaucrat if Metrics_assigned == 0
sum Posterior2_Amount_RCT if Metrics_assigned == 0
sum Prosterior2_Amount_Admindata if Metrics_assigned == 0
sum Posterior2_Amount_bureaucrat if Metrics_assigned == 0


/*****************************************************************************************************
						Table 7 - Effect of Metrics Training on WTP - by Defiers (Never-takers not in data)
*****************************************************************************************************/
use "WTP data file by defier.dta", clear

eststo clear
eststo:qui:reg Posterior1_Amount_RCT DefierXMetricsassigned Metrics_assigned DefierXMetricschoose Defier Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Posterior2_Amount_RCT DefierXMetricsassigned Metrics_assigned DefierXMetricschoose Defier Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
esttab using table7_defier.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

/*****************************************************************************************************
						Table B3 - Impact of Metrics Training on attrition
*****************************************************************************************************/

use "WTP data file by defier.dta", clear

gen Attritionnew2 =1 if causalinferenceisimportant  ==.
replace Attritionnew2 =0 if causalinferenceisimportant  !=.
replace Metrics_chosen =0 if Metrics_chosen==. // this was the problem, values were missing

eststo clear
eststo:qui:reg Attritionnew2 Metrics_assigned Metrics_chosen , vce(cluster RollNo)
eststo:qui:reg Attritionnew2 Metrics_assigned Metrics_chosen  $controls , vce(cluster RollNo)
esttab using tableb3_sample1.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace
sum Attritionnew2 if Metrics_assigned==0

use "cleaned data.dta",clear

gen Attritionnew1 =1 if Rating_Quant_Imp  ==.
replace Attritionnew1 =0 if Rating_Quant_Imp  !=.

eststo clear
eststo:qui:reg Attritionnew1 metrics_assigned metrics_selected , vce(cluster participantid_in_session)
eststo:qui:reg Attritionnew1 metrics_assigned metrics_selected $controls , vce(cluster participantid_in_session)
esttab using tableb3_sample2.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace
sum Attritionnew1 


/*****************************************************************************************************
						Table B4 - Impact of Metrics Training on deworming policy by demand
*****************************************************************************************************/
use "cleaned data.dta",clear

eststo clear
eststo:qui:reg LetterNo1 metrics_assigned $controls if in_model_2 == 1 & metrics_selected == 1, vce(cluster participantid_in_session )
eststo:qui:reg AmountforDeworming metrics_assigned $controls if in_model_2 == 1 & metrics_selected == 1, vce(cluster participantid_in_session )
eststo:qui:reg LetterNo1 metrics_assigned $controls if in_model_2 == 1 & metrics_selected == 0, vce(cluster participantid_in_session )
eststo:qui:reg AmountforDeworming metrics_assigned $controls if in_model_2 == 1 & metrics_selected == 0, vce(cluster participantid_in_session )
esttab using tableb4.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

/*****************************************************************************************************
						Table B5 - Impact of Metrics Training by Compliers (not matching)
*****************************************************************************************************/
use "cleaned data.dta",clear
gen Metrics_assXChosen = metrics_assigned * metrics_selected

eststo clear
eststo:qui:reg Rating_Quant_Imp Metrics_assXChosen metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session )
eststo:qui:reg RCTdummy_publicpolicy Metrics_assXChosen metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session )
eststo:qui:reg WhyRCT_dummy Metrics_assXChosen metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session )
eststo:qui:reg NewWhyRCT_dummy Metrics_assXChosen metrics_assigned metrics_selected $controls if in_model_2 == 1 , vce(cluster participantid_in_session )
esttab using tableb5_a.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum Rating_Quant_Imp RCTdummy_publicpolicy WhyRCT_dummy NewWhyRCT_dummy if metrics_assigned==0

use "WTP data file by defier.dta", clear
gen Metrics_assXChosen = Metrics_assigned * Metrics_chosen

eststo clear
eststo:qui:reg Posterior1_Amount_RCT Metrics_assXChosen Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Posterior2_Amount_RCT Metrics_assXChosen Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Score_Research_Method Metrics_assXChosen Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
eststo:qui:reg Rating_Quant_Imp Metrics_assXChosen Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 , vce(cluster RollNo )
esttab using tableb5_b.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

sum Posterior1_Amount_RCT Posterior2_Amount_RCT Score_Research_Method Rating_Quant_Imp if metrics_assigned==0

/*****************************************************************************************************
						Table B6 - Heterogeneity by Pretreatment Assessment scores (RCT variable not known)
*****************************************************************************************************/

use "cleaned data.dta",clear

summ Rating_Quant_Imp if in_model_2 == 1, de
return list
gen RQ_median = r(p50)
gen RQ_abovemedian = Rating_Quant_Imp>RQ_median

// summ RCTdummy_publicpolicy if in_model_2 == 1, de
// return list
// gen RCT_median = r(mean)
// gen RCT_abovemedian = RCTdummy_publicpolicy >= RCT_median

// summ NewRCTdummy_publicpolicy if in_model_2 == 1, de
// return list
// gen NewRCT_median = r(mean)
// gen NewRCT_abovemedian = NewRCTdummy_publicpolicy >= NewRCT_median

eststo clear
eststo:qui:reg Rating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1 & RQ_abovemedian == 0 , vce(cluster participantid_in_session )
eststo:qui:reg Rating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1 & RQ_abovemedian == 1 , vce(cluster participantid_in_session )
// eststo:qui:reg RCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_2 == 1 & RCT_abovemedian == 0 , vce(cluster participantid_in_session )
// eststo:qui:reg RCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_2 == 1 & RCT_abovemedian == 1 , vce(cluster participantid_in_session )
// eststo:qui:reg NewRCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_2 == 1 & NewRCT_abovemedian == 0 , vce(cluster participantid_in_session )
// eststo:qui:reg NewRCTdummy_publicpolicy metrics_assigned metrics_selected $controls if in_model_2 == 1 & NewRCT_abovemedian == 1 , vce(cluster participantid_in_session )
esttab using tableb6_a.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace


use "WTP data file by defier.dta", clear

summ Rating_Quant_Imp if in_model_4 == 1, de
return list
gen RQ_median = r(p50)
gen RQ_abovemedian = Rating_Quant_Imp>RQ_median if in_model_4 == 1

summ Posterior1_Amount_RCT if in_model_4 == 1, de
return list
gen RCTamt1_median = r(p50)
gen RCTamt1_abovemedian = Posterior1_Amount_RCT>RCTamt1_median if in_model_4 == 1

summ Posterior2_Amount_RCT if in_model_4 == 1, de
return list
gen RCTamt2_median = r(p50)
gen RCTamt2_abovemedian = Posterior2_Amount_RCT>RCTamt2_median if in_model_4 == 1

eststo clear
eststo:qui:reg Posterior1_Amount_RCT Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RCTamt1_abovemedian==0, vce(cluster RollNo )
eststo:qui:reg Posterior1_Amount_RCT Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RCTamt1_abovemedian==1, vce(cluster RollNo )
eststo:qui:reg Posterior2_Amount_RCT Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RCTamt2_abovemedian==0, vce(cluster RollNo )
eststo:qui:reg Posterior2_Amount_RCT Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RCTamt2_abovemedian==1, vce(cluster RollNo )
eststo:qui:reg Rating_Quant_Imp Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RQ_abovemedian==0, vce(cluster RollNo )
eststo:qui:reg Rating_Quant_Imp Metrics_assigned Metrics_chosen $controls if in_model_4 == 1 & RQ_abovemedian==1, vce(cluster RollNo )
esttab using tableb6_b.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace

/*****************************************************************************************************
						Table B7 - Effect of Metrics Training on Policy – Randomization Inference (not matching)
*****************************************************************************************************/
use "cleaned data.dta",clear

local varlist Rating_Quant_Imp PostVideoRating_Quant_Imp qualitative postqualitative RCTdummy_publicpolicy NewRCTdummy_publicpolicy WhyRCT_dummy NewWhyRCT_dummy

foreach v of var `varlist' {
   qui su `v'
  g double z_`v' = (`v' - r(mean))/r(sd)
  }
 
eststo clear
eststo:qui:reg z_Rating_Quant_Imp  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_PostVideoRating_Quant_Imp metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_qualitative metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_postqualitative metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_RCTdummy_publicpolicy metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_NewRCTdummy_publicpolicy metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_WhyRCT_dummy metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)
eststo:qui:reg z_NewWhyRCT_dummy metrics_assigned metrics_selected  $controls if in_model_2 == 1 , vce(cluster participantid_in_session)

esttab using tableb7.csv, r2 se nogaps noomitted nobaselevel star(* 0.1 ** 0.05 *** 0.01) replace
 
sum z_* if metrics_assigned==0
