cd "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\"   //Enter your own path where the REPLICATION folder is unzipped

/*****************************************************************************************************
******************************************************************************************************
                                           Figures
******************************************************************************************************
******************************************************************************************************/



/*****************************************************************************************************
			   	Figure 1 - Impact of Metrics Training on Beliefs – Standardized  (edit in graph editer)
*****************************************************************************************************/

use ".\Input\Training Metrics.dta", clear

cd "./Output/Figures"

set scheme s1mono 

global controls writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup
set scheme s1color
reg st_Rating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store st_Rating_Quant_Imp
reg st_PostVideoRating_Quant_Imp metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store st_PostVideoRating_Quant
reg st_qualitative metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store st_qualitative
reg st_postqualitative metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store st_postqualitative
reg st_rctdummy metrics_assigned metrics_selected $controls if in_model_1 == 1, vce(cluster participantid_in_session)
estimate store st_rctdummy
reg st_newrctdummy metrics_assigned metrics_selected $controls if in_model_1 == 1, vce(cluster participantid_in_session)
estimate store st_newrctdummy
reg st_whyrctdummy metrics_assigned metrics_selected $controls if in_model_1 == 1, vce(cluster participantid_in_session)
estimate store st_whyrctdummy
reg st_newwhyrctdummy metrics_assigned metrics_selected $controls if in_model_1 == 1, vce(cluster participantid_in_session)
estimate store st_newwhyrctdummy
coefplot st_Rating_Quant_Imp st_PostVideoRating_Quant st_qualitative st_postqualitative st_rctdummy st_newrctdummy st_whyrctdummy st_newwhyrctdummy, drop(_cons || $controls || metrics_selected ) xline(0) order( metrics_assigned ) title("Potential Mechanisms") xtitle("Point Estimates with 95% CIs (Metrics Assigned)") ylabel(0.56 "Pre Lecture Rating Quantitative Important" 0.68 "Post Lecture Rating Quantitative Important" 0.79 "Pre Lecture Rating Qualitative Important" 0.88 "Post Lecture Rating Qualitative Important" 1.00 "Pre Lecture Run RCT" 1.15 "Post Lecture Run RCT" 1.24 "Pre Lecture Why RCT" 1.35 "Post Lecture Why RCT") xlabel(-2.5(1)2.5) xscale(range(-2.5(1)2.5)) mlabel format(%9.3f) mlabposition(12) mlabgap(*2) level(95)
set scheme s1mono
coefplot st_Rating_Quant_Imp st_PostVideoRating_Quant st_qualitative st_postqualitative st_rctdummy st_newrctdummy st_whyrctdummy st_newwhyrctdummy, drop(_cons || $controls || metrics_selected ) xline(0) order( metrics_assigned ) title("Potential Mechanisms") xtitle("Point Estimates with 95% CIs (Metrics Assigned)") ylabel(0.56 "Pre Lecture Rating Quantitative Important" 0.68 "Post Lecture Rating Quantitative Important" 0.79 "Pre Lecture Rating Qualitative Important" 0.88 "Post Lecture Rating Qualitative Important" 1.00 "Pre Lecture Run RCT" 1.15 "Post Lecture Run RCT" 1.24 "Pre Lecture Why RCT" 1.35 "Post Lecture Why RCT") xlabel(-2.0(1)2.0) xscale(range(-2.0(1)2.0)) mlabel format(%9.3f) mlabposition(12) mlabgap(*2) level(95) legend(pos(4) col(1))
graph display, ysize(3) xsize(6)


gr_edit legend.plotregion1.label[1].text = {}
gr_edit legend.plotregion1.label[1].text.Arrpush Pre Lecture Rating Quantitative
// label[1] edits

gr_edit legend.plotregion1.label[2].text = {}
gr_edit legend.plotregion1.label[2].text.Arrpush Post Lecture Rating Quantitative
// label[2] edits

gr_edit legend.plotregion1.label[3].text = {}
gr_edit legend.plotregion1.label[3].text.Arrpush Pre Lecture Rating Qualitative
// label[3] edits

gr_edit legend.plotregion1.label[4].text = {}
gr_edit legend.plotregion1.label[4].text.Arrpush Post Lecture Rating Qualitative
// label[4] edits

gr_edit legend.plotregion1.label[5].text = {}
gr_edit legend.plotregion1.label[5].text.Arrpush Pre Lecture Run RCT
// label[5] edits

gr_edit legend.plotregion1.label[6].text = {}
gr_edit legend.plotregion1.label[6].text.Arrpush Post Lecture Run RCT
// label[6] edits

gr_edit legend.plotregion1.label[7].text = {}
gr_edit legend.plotregion1.label[7].text.Arrpush Pre Lecture Why RCT
// label[7] edits

gr_edit legend.plotregion1.label[8].text = {}
gr_edit legend.plotregion1.label[8].text.Arrpush Post Lecture Why RCT
// label[8] edits

gr_edit title.text = {}
gr_edit title.text.Arrpush Effect on Beliefs

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure1.png", replace


/*****************************************************************************************************
   	Figure 2 - Impact of Metrics Training on Prosociality and Causal Language - Standardized (edit in graph editer)
*****************************************************************************************************/
cd ../..

clear all 


use ".\Input\Training Metrics.dta", clear

cd "./Output/Figures"

set scheme s1mono 

drop z_*
global controls writtenmarks interviewmarks gender birthpcapital land income age dedu4 out pas psp fbr fsp othersgroup
set scheme s1color
egen float z_orphanage = std(orphanage), mean(0) std(1)
egen float z_volunteering = std( PENvisit ), mean(0) std(1)
egen float z_ = std( donatingforpublicgood ), mean(0) std(1)
egen float z_donatingpublicgood = std( donatingforpublicgood ), mean(0) std(1)
egen float z_organizecommunityevent = std( organizecommunityevent ), mean(0) std(1)
egen float z_volunteeringatoldagehome = std( volunteeringatoldagehome ), mean(0) std(1)
egen float z_emotionallysupportive = std( emotionallysupportive ), mean(0) std(1)
egen float z_donatingtoanorphanage = std( donatingtoanorphanage ), mean(0) std(1)
egen float z_sharingfood = std( sharingfood ), mean(0) std(1)
egen float z_we = std( we ), mean(0) std(1)
egen float z_I = std( I ), mean(0) std(1)
egen float z_causalinferenceisimportant = std( causalinferenceisimportant ), mean(0) std(1)
egen float z_correlationisnotcausation = std( correlationisnotcausation ), mean(0) std(1)
egen float z_quantitativeevidence = std( quantitativeevidence ), mean(0) std(1)
egen float z_applestoapples = std( observationalstudiesarenotap ), mean(0) std(1)
reg z_orphanage metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_orphanage
reg z_volunteering metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_volunteering
reg z_donatingpublicgood metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_donatingpublicgood
reg z_organizecommunityevent metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_organizecommunityevent
reg z_volunteeringatoldagehome metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_volunteeringatoldagehome
reg z_emotionallysupportive metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_emotionallysupportive
reg z_donatingtoanorphanage metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_donatingtoanorphanage
reg z_sharingfood metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_donatingtoanorphanage
reg z_sharingfood metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_sharingfood
reg z_we metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_we
reg z_I metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_I
reg z_causalinferenceisimportant metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_causalinference
reg z_correlationisnotcausation metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_correlationisnotcausation
reg z_quantitativeevidence metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_quantitativeevidence
reg z_applestoapples metrics_assigned metrics_selected $controls if in_model_2 == 1, vce(cluster participantid_in_session)
estimate store z_applestoapples
set scheme s1mono
coefplot z_orphanage z_volunteering z_donatingpublicgood z_organizecommunityevent z_volunteeringatoldagehome z_emotionallysupportive z_donatingtoanorphanage z_sharingfood z_we z_I z_causalinference z_correlationisnotcausation z_quantitativeevidence z_applestoapples , drop(_cons || $controls || metrics_selected ) xline(0) order( metrics_assigned ) title("Potential Mechanisms") xtitle("Point Estimates with 95% CIs (Metrics Assigned)") ylabel(0.53 "Orphanage" 0.61 "Volunteering" 0.68 "Donating Public Good" 0.75 "Organizing Community Event" 0.81 "Volunteering to oldage home" 0.89 "Emotionally Supportive" 0.95 "Donating Orphanage" 1.02 "Sharing food" 1.08 "We" 1.14 "I" 1.21 "Causal Inference is important" 1.29 "Correlation is not causation" 1.34 "Quantitative Evidence" 1.40 "Apples to Apples Comparisons") xlabel(-2.0(1)2.0) xscale(range(-2.0(1)2.0)) mlabel format(%9.3f) mlabposition(12) mlabgap(*2) level(95) legend(pos(4) col(1))
graph display, ysize(3) xsize(6)

gr_edit legend.plotregion1.label[1].text = {}
gr_edit legend.plotregion1.label[1].text.Arrpush Orphanage
// label[1] edits

gr_edit legend.plotregion1.label[2].text = {}
gr_edit legend.plotregion1.label[2].text.Arrpush Volunteering
// label[2] edits

gr_edit legend.plotregion1.label[3].text = {}
gr_edit legend.plotregion1.label[3].text.Arrpush Donating Public Good
// label[3] edits

gr_edit legend.plotregion1.label[4].text = {}
gr_edit legend.plotregion1.label[4].text.Arrpush Organizing Community Event
// label[4] edits

gr_edit legend.plotregion1.label[5].text = {}
gr_edit legend.plotregion1.label[5].text.Arrpush Volunteering to oldage home
// label[5] edits

gr_edit legend.plotregion1.label[6].text = {}
gr_edit legend.plotregion1.label[6].text.Arrpush Emotionally Supportive
// label[6] edits

gr_edit legend.plotregion1.label[7].text = {}
gr_edit legend.plotregion1.label[7].text.Arrpush Donating Orphanage
// label[7] edits

gr_edit legend.plotregion1.label[8].text = {}
gr_edit legend.plotregion1.label[8].text.Arrpush Sharing food
// label[8] edits

gr_edit legend.plotregion1.label[9].text = {}
gr_edit legend.plotregion1.label[9].text.Arrpush We
// label[9] edits

gr_edit legend.plotregion1.label[10].text = {}
gr_edit legend.plotregion1.label[10].text.Arrpush I
// label[10] edits

gr_edit legend.plotregion1.label[11].text = {}
gr_edit legend.plotregion1.label[11].text.Arrpush causal inference is important
// label[11] edits

gr_edit legend.plotregion1.label[12].text = {}
gr_edit legend.plotregion1.label[12].text.Arrpush correlation is not causation
// label[12] edits

gr_edit legend.plotregion1.label[13].text = {}
gr_edit legend.plotregion1.label[13].text.Arrpush quantitative evidence
// label[13] edits

gr_edit legend.plotregion1.label[14].text = {}
gr_edit legend.plotregion1.label[14].text.Arrpush apples to apples comperisons
// label[14] edits

gr_edit title.text = {}
// title edits

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure2.png", replace




/*****************************************************************************************************
         	Figure 3 - Distribution of Initial Beliefs and Post-Signal Beliefs
*****************************************************************************************************/
cd ../..

clear all 


use ".\Input\WTP data file by defiers.dta", clear

cd "./Output/Figures"

set scheme s1mono 

twoway (kdensity Prior_Belief if Metrics_assigned == 0, lpattern(solid) lwidth(medthick) lcolor(gs5))(kdensity Prior_Belief if Metrics_assigned == 1, lpattern(longdash) lwidth(medthick) lcolor(gs5))(kdensity Posterior_belief if Metrics_assigned == 0 , lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior_belief if Metrics_assigned == 1, lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("Prior and Posterior Beliefs")legend(order(1 "Prior Belief (Placebo)" 2 "Prior Belief (Metrics Assigned)"3 "Posterior Belief (Placebo)" 4 "Posterior Belief (Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))


gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy
// yaxis1 edits

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure3.png", replace




/*****************************************************************************************************
         	Figure 4 - Distribution of Post-Signal WTP for RCT (edit in graph editer)
*****************************************************************************************************/
cd ../..

clear all 


use ".\Input\WTP data file by defiers.dta", clear

cd "./Output/Figures"

set scheme s1mono 

////Panel A: Private Spending////
twoway (kdensity Posterior1_Amount_RCT if Metrics_assigned == 0 & Posterior1_Amount_RCT <= 10000 , lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior1_Amount_RCT if Metrics_assigned == 1 & Posterior1_Amount_RCT <= 10000 , lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP to obtain result on an RCT(Private Spending)")legend(order(1 "WTP to obtain a result on an RCT(Placebo)" 2 "WTP to obtain a result on an RCT(Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy


graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure4-PanelA.png", replace

////Panel B: Public Spending////
twoway (kdensity Posterior2_Amount_RCT if Metrics_assigned == 0 & Posterior2_Amount_RCT <= 400000 , lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior2_Amount_RCT if Metrics_assigned == 1 & Posterior2_Amount_RCT <= 400000,lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP to obtain result on an RCT(Public Spending)")legend(order(1 " WTP to obtain result on an RCT (Placebo)" 2 " WTP to obtain result on an RCT(Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

gr_edit yaxis1.major.num_rule_ticks = 6
gr_edit yaxis1.edit_tick 2 2e-06 `"2"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 5
gr_edit yaxis1.edit_tick 2 4e-06 `"4"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 4
gr_edit yaxis1.edit_tick 2 6e-06 `"6"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 3
gr_edit yaxis1.edit_tick 2 8e-06 `"8"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 2
gr_edit yaxis1.edit_tick 2 1e-05 `"1"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 1
gr_edit yaxis1.edit_tick 6 1e-05 `"10"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy
// yaxis1 edits

gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush Density (10^-6)
// title edits


graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure4-PanelB.png", replace



/*****************************************************************************************************
         	Figure 5 - Distribution of Post-Signal WTP for Correlational Data (edit in graph editer)
*****************************************************************************************************/
cd ../..

clear all 


use ".\Input\WTP data file by defiers.dta", clear

cd "./Output/Figures"

set scheme s1mono 

////Panel A: Private Spending////

twoway (kdensity Posterior1_Amount_Admindata if Metrics_assigned == 0 & Posterior1_Amount_Admindata <= 10000 , lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior1_Amount_Admindata if Metrics_assigned == 1 & Posterior1_Amount_Admindata <= 10000 , lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP for Correlational Data(Private Spending)")legend(order(1 "WTP for Correlational Data(Placebo)" 2 "WTP for Correlational Data(Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure5-PanelA.png", replace
////Panel B: Public Spending////
twoway (kdensity Prosterior2_Amount_Admindata if Metrics_assigned == 0 & Prosterior2_Amount_Admindata <= 300000, lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Prosterior2_Amount_Admindata if Metrics_assigned == 1& Prosterior2_Amount_Admindata <= 300000 ,lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP for Correlational Data(Public Spending)")legend(order(1 "WTP for Correlational Data(Placebo)" 2 "WTP for Correlational Data(Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy
// yaxis1 edits

gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush Density (10^-6)
// title edits

gr_edit yaxis1.major.num_rule_ticks = 5
gr_edit yaxis1.edit_tick 2 2e-06 `"2"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 4
gr_edit yaxis1.edit_tick 2 4e-06 `"4"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 3
gr_edit yaxis1.edit_tick 2 6e-06 `"6"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 2
gr_edit yaxis1.edit_tick 2 8e-06 `"8"', tickset(major)
// yaxis1 edits

// xaxis1 edits

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure5-PanelB.png", replace





/*****************************************************************************************************
        	Figure 6 - Distribution of Post-Signal WTP for Bureaucrat’s Advice (edit in graph editer)
*****************************************************************************************************/
cd ../..

clear all 


use ".\Input\WTP data file by defiers.dta", clear

cd "./Output/Figures"

set scheme s1mono 

////Panel A: Private Spending////
 twoway (kdensity Posterior1_Amount_bureaucrat if Metrics_assigned == 0 & Posterior1_Amount_bureaucrat <= 10000 , lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior1_Amount_bureaucrat if Metrics_assigned == 1 & Posterior1_Amount_bureaucrat <= 10000 , lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP from Bureaucrat's Advice(Private Spending)")legend(order(1 "WTP from Bureaucrat's Advice(Placebo)" 2 "WTP from Bureaucrat's Advice (Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))
 
gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure6-PanelA.png", replace

 /////Panel B: Public Spending///

drop if Posterior2_Amount_bureaucrat > 900000
drop if Posterior2_Amount_bureaucrat >= 900000
drop if Posterior2_Amount_RCT >= 900000
drop if Prosterior2_Amount_Admindata >= 900000
 twoway (kdensity Posterior2_Amount_bureaucrat if Metrics_assigned == 0, lpattern(shortdash) lwidth(thick) lcolor(gs8))(kdensity Posterior2_Amount_bureaucrat if Metrics_assigned == 1,lpattern(dash) lwidth(thick) lcolor(gs0)), ytitle("Density") xtitle("WTP from Bureaucrat’s Advice(Public Spending)")legend(order(1 "WTP from Bureaucrat’s Advice(Placebo)" 2 "WTP from Bureaucrat’s Advice(Metrics Assigned)") cols(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

gr_edit yaxis1.style.editstyle draw_major_grid(yes) editcopy
// yaxis1 edits

gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush Density (10^-6)
// title edits

gr_edit yaxis1.major.num_rule_ticks = 5
gr_edit yaxis1.edit_tick 2 2e-06 `"2"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 4
gr_edit yaxis1.edit_tick 2 4e-06 `"4"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 3
gr_edit yaxis1.edit_tick 2 6e-06 `"6"', tickset(major)
// yaxis1 edits

gr_edit yaxis1.major.num_rule_ticks = 2
gr_edit yaxis1.edit_tick 2 8e-06 `"8"', tickset(major)
// yaxis1 edits

gr_edit xaxis1.reset_rule 0 600000 100000 , tickset(major) ruletype(range) 
// xaxis1 edits

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure6-PanelB.png", replace





/***********************************************************************************************************************
        	Figure 7 - Effect of Metrics Training on Deworming Project Choice by Initial Beliefs (edit in graph editer)
***********************************************************************************************************************/
cd ../..

clear all 


use ".\Input\WTP data file by defiers.dta", clear

cd "./Output/Figures"

set scheme s2color

////Panel A: Parametric Estimation////
br prior_less_13new deworming_dummy_updated
br prior_less_13new Prior_Belief
ttest deworming_dummy_updated if prior_less_13new == 1, by( Metrics_assigned)
ttest deworming_dummy_updated if prior_less_13new == 0, by( Metrics_assigned)
preserve
gen deworming_dummy_a13 = deworming_dummy_updated if prior_less_13new == 0
gen deworming_dummy_b13 = deworming_dummy_updated if prior_less_13new == 1
collapse (mean) m0 = deworming_dummy_a13 m1 = deworming_dummy_b13 (sd) sd0 = deworming_dummy_a13 sd1 = deworming_dummy_b13 (count) c0 = deworming_dummy_a13 c1 = deworming_dummy_b13 , by( Metrics_assigned )
reshape long m sd c, i( Metrics_assigned ) j(below13)
gen h = m + invttail(c-1,0.05)*(sd / sqrt(c))
gen l = m - invttail(c-1,0.05)*(sd / sqrt(c))
gen bt_graph = 1.5 if Metrics_assigned == 0 & below13 == 1
replace bt_graph = 2.5 if Metrics_assigned == 1 & below13 == 1
replace bt_graph = 4 if Metrics_assigned == 0 & below13 == 0
replace bt_graph = 5 if Metrics_assigned == 1 & below13 == 0
twoway (bar m bt_graph if below13 == 1, barwidth(0.85) color(ltblue) fintensity(100))(bar m bt_graph if below13 == 0, barwidth(0.85) color(cranberry) fintensity(60))(rcap h l bt_graph),ytitle("% participated in July 1st March, 2016") xtitle("") xlabel(1.5 "Control" 2.5 "Treatment" 4 "Control" 5 "Treatment") text(6 2 "p-value = 0.077") text(9 4.5 "p-value = 0.001") legend(order(1 "Prior belief re: planned particip. below truth" 2 "Prior belief re: planned particip. above truth") col(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))
twoway (bar m bt_graph if below13 == 1, barwidth(0.85) color(ltblue) fintensity(100))(bar m bt_graph if below13 == 0, barwidth(0.85) color(cranberry) fintensity(60))(rcap h l bt_graph),ytitle("% participated in July 1st March, 2016") xtitle("") xlabel(1.5 "Control" 2.5 "Treatment" 4 "Control" 5 "Treatment") text(9 2 "p-value = 0.077") text(9 4.5 "p-value = 0.001") legend(order(1 "Prior belief re: planned particip. below truth" 2 "Prior belief re: planned particip. above truth") col(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))
set scheme s2color
twoway (bar m bt_graph if below13 == 1, barwidth(0.85) color(ltblue) fintensity(100))(bar m bt_graph if below13 == 0, barwidth(0.85) color(cranberry) fintensity(60))(rcap h l bt_graph),ytitle("% Choosing Deworming Project") xtitle("") xlabel(1.5 "Control" 2.5 "Treatment" 4 "Control" 5 "Treatment") text(9.2 2 "p-value < 0.01") text(9 4.5 "p-value = 0.824") legend(order(1 "Prior belief < 13" 2 "Prior belief > 13") col(1))graphregion(fcolor(white) ilcolor(white) lcolor(white))

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure7-PanelA.png", replace


////Panel B; Semi-Parametric Estimation////

gen deworming_dummy_updated_control = deworming_dummy_updated if Metrics_assigned == 0
gen deworming_dummy_updated_treat = deworming_dummy_updated if Metrics_assigned == 1
egen prior_bin = cut( Prior_Belief ), at(0 5 10 15 20 25 30 100)
drop if prior_bin == .
collapse (mean) m0 = deworming_dummy_updated_control m1 = deworming_dummy_updated_treat (sd) sd0 = deworming_dummy_updated_control sd1 = deworming_dummy_updated_treat (count) n0 = deworming_dummy_updated_control n1 = deworming_dummy_updated_treat , by(prior_bin)
gen diff = m1 - m0
gen se = sqrt(sd0*sd0/n0 + sd1*sd1/n1)
gen h = diff + 1.96 * se
gen l = diff - 1.96 * se
twoway (connected diff prior_bin, msymbol(diamond) mcolor(gs0) msize(medlarge) lpattern(solid) lwidth(thick) lcolor(gs0))(rcap h l prior_bin),ytitle("Treatment effect on % participated")xtitle("Prior belief re: planned participation") xlabel(0(5)30)xline(17) yline(0) text(13 19.3 "Truth" "(treatment)")legend(off)graphregion(fcolor(white) ilcolor(white) lcolor(white))
twoway (connected diff prior_bin, msymbol(diamond) mcolor(gs0) msize(medlarge) lpattern(solid) lwidth(thick) lcolor(gs0))(rcap h l prior_bin),ytitle("Treatment effect on % participated")xtitle("Prior belief re: planned participation") xlabel(0(5)30)xline(13.01) yline(0) text(13 19.3 "Truth" "(treatment)")legend(off)graphregion(fcolor(white) ilcolor(white) lcolor(white))
twoway (connected diff prior_bin, msymbol(diamond) mcolor(gs0) msize(medlarge) lpattern(solid) lwidth(thick) lcolor(gs0))(rcap h l prior_bin),ytitle("Treatment effect on % participated")xtitle("Prior belief re: planned participation") xlabel(0(5)30)xline(13.01) yline(0) text(13 19.3 "Truth" "(treatment)")legend(off)graphregion(fcolor(white) ilcolor(white) lcolor(white))
twoway (connected diff prior_bin, msymbol(diamond) mcolor(gs0) msize(medlarge) lpattern(solid) lwidth(thick) lcolor(gs0))(rcap h l prior_bin),ytitle("Treatment effect on % participated")xtitle("Prior belief re: planned participation") xlabel(0(5)30)xline(13.01) yline(0)legend(off)graphregion(fcolor(white) ilcolor(white) lcolor(white))
twoway (connected diff prior_bin, msymbol(diamond) mcolor(gs0) msize(medlarge) lpattern(solid) lwidth(thick) lcolor(gs0))(rcap h l prior_bin),ytitle("Treatment effect on % Choosing Deworming Project")xtitle("Prior Beliefs (on Effect of Deworming)") xlabel(0(5)30)xline(13.01) yline(0)legend(off)graphregion(fcolor(white) ilcolor(white) lcolor(white))

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\Figure7-PanelB.png", replace



/***********************************************************************************************************************
        	             Figure B3 - Impact of Metrics Training (edit in graph editer)
***********************************************************************************************************************/
cd ../..

clear all 


use ".\Input\Training Metrics.dta", clear

cd "./Output/Figures"

encode bookassigned, gen(bookassigned1)
drop bookassigned
rename bookassigned1 bookassigned

set scheme s1mono

////Panel A:  Beliefs on Importance of Quantitative Evidence////
cibar Rating_Quant_Imp , over1( bookassigned ) vce (cluster participantid_in_session ) graphopts(ytitle(Pre Lecture Rating Quantitative Important) title(, size(small)) ylabel(0(1)5) yscale(range(0(1)5)) graphregion(fcolor(white)) xsize(5)) ciopts(lcolor(black)) bargap(15) barlabel(on) blf(%9.3f) blgap(0.45) blsize(small)

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB3-PanelA1.png", replace


cibar PostVideoRating_Quant_Imp , over1( bookassigned ) vce (cluster participantid_in_session ) graphopts(ytitle(Post Lecture Rating Quantitative Important) title(, size(small)) ylabel(0(1)5) yscale(range(0(1)5)) graphregion(fcolor(white)) xsize(5)) ciopts(lcolor(black)) bargap(15) barlabel(on) blf(%9.3f) blgap(0.45) blsize(small)

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB3-PanelA2.png", replace


/////Panel B:  Beliefs on Importance of Qualitative Evidence///
cibar qualitative , over1( bookassigned ) vce (cluster participantid_in_session ) graphopts(ytitle(Pre Lecture Rating Qualitative Important) title(, size(small)) ylabel(0(1)5) yscale(range(0(1)5)) graphregion(fcolor(white)) xsize(5)) ciopts(lcolor(black)) bargap(15) barlabel(on) blf(%9.3f) blgap(0.45) blsize(small)

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB3-PanelB1.png", replace


cibar postqualitative , over1( bookassigned ) vce (cluster participantid_in_session ) graphopts(ytitle(Post Lecture Rating Qualitative Important) title(, size(small)) ylabel(0(1)5) yscale(range(0(1)5)) graphregion(fcolor(white)) xsize(5)) ciopts(lcolor(black)) bargap(15) barlabel(on) blf(%9.3f) blgap(0.45) blsize(small)

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB3-PanelB2.png", replace



/***********************************************************************************************************************
        	Figure B4 - Shifts in Beliefs versus Initial Beliefs by Metrics Selection (edit in graph editer)
***********************************************************************************************************************/
cd ../..

clear all 


use ".\Input\Training Metrics.dta", clear

cd "./Output/Figures"

set scheme s2color

* Panel A
drop deltabelief delta0 delta1
gen deltabelief = Posterior_belief- Prior_Belief
gen delta2 = deltabelief if metrics_assigned == 0
gen delta3 = deltabelief if metrics_assigned == 1

set scheme s2color
twoway (scatter delta2 Prior_Belief if metrics_selected == 1, msymbol(Oh) jitter (5) ) (scatter delta3 Prior_Belief if metrics_selected == 1, msymbol(Th) jitter(5) )(lfit delta2 Prior_Belief, lwidth(medium) lcolor(black) ) (lfit delta3 Prior_Belief, lwidth(medium) lcolor(gs11)), xline(13, lcolor(red) lwidth(thin)) ytitle(Delta Beliefs) xtitle(Prior Beliefs) legend(order(1 "Placebo" 2 "Metrics Assigned" 3 "Fitted Line Placebo" 4 "Fitted Line Metrics Assigned"))
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit .style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit .plotregion1.plot2.style.editstyle marker(size(small)) editcopy
gr_edit .plotregion1.plot1.style.editstyle marker(size(small)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(color(gs16)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(pattern(dash)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(color(gs9)) editcopy
gr_edit .plotregion1.plot4.style.editstyle line(color(black)) editcopy

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB4-PanelA.png", replace


////seprate metrics_selected == 0

//seprate metrics_selected == 1
cd ../..

clear all 


use ".\Input\Training Metrics.dta", clear

cd "./Output/Figures"

set scheme s2color

*Panel B
drop deltabelief delta0 delta1
gen deltabelief = Posterior_belief- Prior_Belief
gen delta2 = deltabelief if metrics_assigned == 0
gen delta3 = deltabelief if metrics_assigned == 1

twoway (scatter delta2 Prior_Belief if metrics_selected == 0, msymbol(Oh) jitter (5) ) (scatter delta3 Prior_Belief if metrics_selected == 0, msymbol(Th) jitter(5) )(lfit delta2 Prior_Belief, lwidth(medium) lcolor(black) ) (lfit delta3 Prior_Belief, lwidth(medium) lcolor(gs11)), xline(13, lcolor(red) lwidth(thin)) ytitle(Delta Beliefs) xtitle(Prior Beliefs) legend(order(1 "Placebo" 2 "Metrics Assigned" 3 "Fitted Line Placebo" 4 "Fitted Line Metrics Assigned"))
gr_edit .style.editstyle boxstyle(shadestyle(color(white))) editcopy
gr_edit .style.editstyle boxstyle(linestyle(color(white))) editcopy
gr_edit .plotregion1.plot2.style.editstyle marker(size(small)) editcopy
gr_edit .plotregion1.plot1.style.editstyle marker(size(small)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(color(gs16)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(pattern(dash)) editcopy
gr_edit .plotregion1.plot3.style.editstyle line(color(gs9)) editcopy
gr_edit .plotregion1.plot4.style.editstyle line(color(black)) editcopy

graph export "C:\Users\tariq\OneDrive\Desktop\Repliaction Training Metrics\Output\Figures\FigureB4-PanelB.png", replace


