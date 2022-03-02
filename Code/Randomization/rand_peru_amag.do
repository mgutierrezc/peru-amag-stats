clear
if c(username)=="Ronak" {
global main "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\"
global code "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Clean raw data"
global data "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Data\"
global rand_peru "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Code\Randomization"
global analysis "C:\Users\ronhi\Dropbox (Harvard University)\AMAG courses evaluation 2021\Analysis"
}

cd "$rand_peru"

/*Commenting out previous original randomization to avoid overwriting treatment status
import excel "Matriculados_03.06.2021.xlsx", firstrow

foreach x in Curso Cargo Género Institución { //Departamento
    tab `x'
	encode `x', gen(`x'_en)
}

//stratifying by course, speciality, and position
//for socratic method
randtreat , gen(treat_socratic) strata(Curso_en Cargo_en Género_en Institución_en) setseed(100001) misfits(global) replace
//for iat first option --take iat or not
randtreat , gen(iat_take_or_not) strata(Curso_en Cargo_en Género_en Institución_en) setseed(200001) misfits(global) replace
gen feedback_or_not = .
bys iat_take_or_not: gen rand = runiform()
bys iat_take_or_not: egen ordering = rank(rand)
bys iat_take_or_not: replace feedback_or_not=1 if ordering<= _N/2 & iat_take_or_not==1
bys iat_take_or_not: replace feedback_or_not=0 if ordering>_N/2 & iat_take_or_not==1
bys iat_take_or_not: replace feedback_or_not=1 if ordering> _N/10 & iat_take_or_not==0
bys iat_take_or_not: replace feedback_or_not=0 if ordering<=_N/10 & iat_take_or_not==0

tab treat_socratic
tab iat_take_or_not
tab feedback_or_not
tab iat_take_or_not feedback_or_not
gen label_iat = ""
replace label_iat = "iat option + feedback option" if iat_take_or_not==1 & feedback_or_not==1
replace label_iat = "iat option + random reveal" if iat_take_or_not==1 & feedback_or_not==0
replace label_iat = "no iat option + feedback option" if iat_take_or_not==0 & feedback_or_not==1
replace label_iat = "no iat option + exit" if iat_take_or_not==0 & feedback_or_not==0

drop rand ordering
drop *_en

//keep appellido_paterno appellido_materno Nombres DNI idmatricula Curso treat_socratic iat_take_or_not feedback_or_not label_iat
keep DNI ResAdmisión Curso ApellidoPaterno ApellidoMaterno Nombres Cargo Género treat_socratic iat_take_or_not feedback_or_not label_iat

export delimited using "rand_peru_list_final", replace




***Changes made on 30th June - for Endline 
cd "$rand_peru"
import delimited "rand_peru_list_final", clear

//adding a var for randomly reveal which was missed in basline:
set seed 1000
gen randomly_reveal = .
bys iat_take_or_not feedback_or_not: gen rand2 = runiform() 
bys iat_take_or_not feedback_or_not: egen ordering2 = rank(rand2)
bys iat_take_or_not feedback_or_not: replace randomly_reveal=0 if ordering2<=_N/2 & iat_take_or_not==1 & feedback_or_not==0
bys iat_take_or_not feedback_or_not: replace randomly_reveal=1 if ordering2>_N/2 & iat_take_or_not==1 & feedback_or_not==0

tab iat_take_or_not
tab feedback_or_not
tab randomly_reveal
tab iat_take_or_not feedback_or_not
tab feedback_or_not randomly_reveal if iat_take_or_not==1
tab feedback_or_not randomly_reveal if iat_take_or_not==0
replace label_iat = "iat option + random reveal yes" if iat_take_or_not==1 & feedback_or_not==0 & randomly_reveal==1
replace label_iat = "iat option + random reveal no" if iat_take_or_not==1 & feedback_or_not==0 & randomly_reveal==0
drop rand2 ordering2

//adding in randomization for efficiency and equity tradeoff ex
/* notes:
1.	Full sample to be divided into proposers and responders (to be carried out before the experiment).
•	These roles will remain fixed throughout the 3 games 
•	Half of these will be randomized to get an acceptance framing when eliciting beliefs and half will receive the rejection framing.
2.	The order of the three games to be randomized across participants as well (to be carried out before the experiment).
*/

foreach x in curso cargo género { //Departamento
    tab `x'
	encode `x', gen(`x'_en)
}

randtreat, gen(proposer) strata(curso_en cargo_en género_en) setseed(500001) misfits(global) replace
set seed 5000
gen acceptance_frame=.
bys proposer: gen rand3 = runiform()
bys proposer: egen ordering3 = rank(rand3)
bys proposer: replace acceptance_frame=1 if ordering3<= _N/2 & proposer==1
bys proposer: replace acceptance_frame=0 if ordering3>_N/2 & proposer==1

tab proposer
tab proposer acceptance_frame
tab proposer iat_take_or_not
tab proposer feedback_or_not

//randomizing the order of games - 6 possible sequences
set seed 50005
gen rand4 = runiform()
egen ordering4 = rank(rand4)
randtreat , gen(order_of_ex) multiple(6) setseed(2001) misfits(global) replace
tab order_of_ex
gen label_order_UG = ""
replace label_order_UG = "two, negative ext, positive ext" if order_of_ex==0
replace label_order_UG = "two, positive ext, negative ext" if order_of_ex==1
replace label_order_UG = "negative ext, two, positive ext" if order_of_ex==2
replace label_order_UG = "positive ext, two, negative ext" if order_of_ex==3
replace label_order_UG = "negative ext, positive ext, two" if order_of_ex==4
replace label_order_UG = "positive ext, negative ext, two" if order_of_ex==5

drop rand3 rand4 ordering3 ordering4
export delimited using "rand_peru_list_final_for_endline", replace

***merging with the IAT trolley version seen for those participants who enrolled 
rename dni DNI
duplicates report DNI
save "$data\randomization_treatment_endline.dta", replace


cd "$data"
import delimited "all_apps_wide_2021-06-29.csv",  encoding(UTF-8) clear 
gen source="set2"
tempfile set2
save `set2'

import delimited "all_apps_wide-2021-06-14.csv",  encoding(UTF-8) clear 
gen source="set1"
append using `set2' , force
tab source

*Drop observations without DNI
drop if login1playerdni==.
ren login1playerdni DNI

*Drop demo observations
br if sessionis_demo==1
drop if sessionis_demo==1
drop sessionis_demo

*dropping incorrect demo versions that were accidently done after the launch (Ronak)
drop if participanttime_started=="2021-06-04 23:58:00.716545+00:00" | participanttime_started=="2021-06-05 00:05:18.015527+00:00"

*drop possible test obsevarions with DNIs:23981093, 44587283, 44196897, 40788349, 46751257, 41175760, 70077738, 45455469

tab DNI if DNI==23981093
tab DNI if DNI==44587283
tab DNI if DNI==44196897
tab DNI if DNI==40788349
tab DNI if DNI==46751257
tab DNI if DNI==41175760
tab DNI if DNI==70077738
tab DNI if DNI==45455469 

list participanttime_started participant_current_app_name if DNI==40788349
list participanttime_started participant_current_app_name if DNI==41175760

*Drop demo attempt (RA confirmed this was the attempt that should be dropped)
drop if participanttime_started=="2021-06-07 15:43:55.606536+00:00" & DNI==40788349   

*Drop bot observations
drop if participant_is_bot==1
drop participant_is_bot

*drop duplicate DNI observations
duplicates report DNI
duplicates list DNI
duplicates tag DNI, gen(dup)
sort DNI participant_index_in_pages 
br if dup>0
bys DNI: drop if _n<_N & dup>0 //Note: currently dropping those with lower participation for a duplicate
isid DNI

merge 1:1 DNI using randomization_treatment_endline.dta, force generate(_merge2)
tab _merge2

//dummies for each of the 4 trolley treatments
gen footbridge_male=0
replace footbridge_male=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==1

gen footbridge_female=0
replace footbridge_female=1 if trolley1playeris_footbridge==1 &trolley1playeris_men==0

gen bystander_male=0
replace bystander_male=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==1

gen bystander_female=0 
replace bystander_female=1 if trolley1playeris_footbridge==0 &trolley1playeris_men==0

gen trolley_treatment=""
replace trolley_treatment="footbridge_male" if footbridge_male==1
replace trolley_treatment="footbridge_female" if footbridge_female==1
replace trolley_treatment="bystander_male" if bystander_male==1
replace trolley_treatment="bystander_female" if bystander_female==1
tab trolley_treatment //balance of treatment assignment

drop _merge2
keep DNI curso-trolley_treatment
drop curso_en cargo_en género_en
//export delimited using "$rand_peru\rand_peru_list_final_for_endline.csv", replace
export excel using "$rand_peru\rand_peru_list_final_for_endline.xlsx", firstrow(var) replace
*/

import delimited "$rand_peru\rand_peru_list_final_for_endline.csv", clear
gen new_dni  = string(dni,"%08.0f")
br dni new_dni
sort dni new_dni
drop dni
ren new_dni dni
export excel using "$rand_peru\rand_peru_list_final_for_endlinev2.xlsx", firstrow(var) replace
export delimited using "$rand_peru\rand_peru_list_final_for_endlinev2.csv", replace delimiter(,)  

 
