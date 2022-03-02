**----Cleaning Satisfaction DATA----**
** -- JMRV -- **
* Create satisfaction variables at the individual level
clear all 
set more off
cd "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME"


insheet using "Satisaccion_Cursos_PAP.csv", comma  clear 




*Keep needed variables to merge with master dataset

rename nrodocumento DNI

* satisfaction answer
gen sat = substr(respuesta, 1,1)
drop respuesta
destring sat, replace
encode categora, gen(qtype)
label define qtypelab 1 "coordinator"  2 "course" 3 "instructor" 4 "platform" 5 "learning experience" 6  "expectation" 7 "educational resources"
label values qtype qtypelab
label var qtype category

save sat.dta, replace 
* principal components to summarize satisfaction scores at question level

	* drop classifiers ignoring categories for PCA to reshape
drop idpreguntapadre categora pregunta qtype
reshape wide sat, i(DNI) j(idpregunta)
	* PCA 
		* 1) all questions pooled
	pca sat1187-sat1227
		*prediction to get 1 composite score
	predict PCsat
		* 2) all questions pooled but multiple pcs
	pca sat1187-sat1227
		*prediction to reach 95 of variation
	predict pc1 pc2 pc3 pc4 pc5 pc6 pc7, score
		* 3) by question category
	pca sat1187-sat1199
	predict pcc1, score
	pca sat1201-sat1204
	predict pcc2, score
	pca sat1206-sat1210
	predict pcc3, score
	pca sat1212-sat1213
	predict pcc4, score
	pca sat1215-sat1220
	predict pcc5, score
	pca sat1222-sat1224
	predict pcc6, score
	pca sat1226-sat1227
	predict pcc7, score
		* standarize pcs
sum PCsat
gen PCsat_s = (PCsat- r(mean))/r(sd)
sum PCsat_s
forvalues i = 1/7{
sum pc`i'
gen pc`i'_s = (pc`i'- r(mean))/r(sd)
sum pc`i'_s
sum pcc`i'
gen pcc`i'_s = (pcc`i'- r(mean))/r(sd)
sum pcc`i'_s
}

keep DNI pc* pcc* PC*
save satpc.dta, replace
***--------****




* reshape to 1 obs per individual

* pregunta constant within preguntapadre and categoria constant, not needed for reshape
use sat.dta, clear
bys DNI: egen meansat = mean(sat)
gen count = 1


* Plots of categories *
graph bar (count) count, ytitle(count) ylabel(#3, labsize(vsmall)) by(, title(Distribution of satisfaction scores, size(medsmall))) over(sat) by(qtype)
graph export satbarplot.pdf, replace


* Reshape at individual level
	* collapse at question category level
collapse(mean) sat meansat, by (DNI qtype)
* for reference
* 1 coordinator, 2 course, 3 instructor, 4, platform, 5 learning experience, 6 expectation, 7 educational resources

reshape wide sat, i(DNI) j(qtype)

lab var sat1 coordinator
lab var sat2 course
lab var sat3 instructor
lab var sat4 platform
lab var sat5 "learning experience"
lab var sat6 expectations
lab var sat7 "educational resources"


merge 1:1 DNI using satpc.dta
drop _m
save "sat_clean.dta", replace




*** Some plots
histogram PCsat_s, bin(8) percent title(Distribution of PC satisfaction variable) subtitle(pooled standarized) saving(pcc, replace)
graph export "histpcs.pdf", replace

forvalues i = 1/7{
histogram pcc`i'_s, bin(8) percent   xlabel(, labsize(vsmall))  ytitle(.)  ylabel(, labsize(vsmall))  legend(size(vsmall)) subtitle(pc`i' and standarized , size(tiny)) saving(pcc`i', replace)
}


gr combine pcc1.gph pcc2.gph pcc3.gph pcc4.gph pcc5.gph pcc6.gph pcc7.gph , col(3) iscale(1)
graph export "matrixpcs.pdf"




histogram meansat, bin(5) percent title(Distribution of mean satisfaction variable) subtitle(mean by individual) saving(histmean, replace)
graph export "histmeansat.pdf", replace

forvalues i = 1/7{
histogram sat`i', bin(5) percent   xlabel(, labsize(vsmall))  ytitle(.)  ylabel(, labsize(vsmall))  legend(size(vsmall)) subtitle(sat`i', size(tiny)) saving(sat`i', replace)
}

gr combine sat1.gph sat2.gph sat3.gph sat4.gph sat5.gph sat6.gph sat7.gph  , col(3) iscale(1)
