**----Cleaning Satisfaction DATA----**
** -- JMRV -- **
* Create satisfaction variables at the individual level
clear all 
set more off
cd "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME"


insheet using "Grades_Cursos Junio Julio PAP.csv", comma  clear 


gen pass = .
replace pass = 1 if regex(acreditado, "S")
replace pass = 0 if regex(acreditado, "N")
lab var pass "passed course 1:yes"

gen retired  = .
replace retired = 1 if regex(retiro, "R")

gen trained = .
replace trained = 1 if regex(capacitado, "S")
replace trained = 0 if regex(capacitado, "N")

replace promedio = " " if promedio == "Null"
destring promedio, gen(grade)


encode gnero, gen(gender)
lab def gen 1 "Female" 2 "Male"
lab val gender gen
lab var gender "gender"


encode institucin, gen(institution)
lab def ins 1 "Public Ministry" 2 "Judicial Power"
lab val institution ins

rename dni DNI
rename nasis attendance

keep DNI pass retired trained grade attendance gender institution


* Mean grade female : 15.55 (15.23, 15.88), male 16.00 (15.71, 16.3)
* Mean pass  .83 (.80,. 859) .88 (.85, .90)
bys gender: ci grade trained pass

drop gender
save "grades_clean.dta", replace
