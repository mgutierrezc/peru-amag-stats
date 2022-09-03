/***********
**Cleaning and variable
generation Module

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

/*=====
Defining controls for all regressions - later in 
subsections other controls are added
=====*/

	*Renaming vars
	ren Cargo Position
	lab var Position Position
	ren Curso Course
	lab var Course Course
	ren Género Gender
	lab var Gender Gender
	
	*encoding strings
	encode Position, gen(en_Position)
	encode Course, gen(en_Course)
	encode Gender, gen(en_Gender)
	
	*shortening names of game variables
	ren bs_dictator_partner_gender bs_dictator_pgender
	ren en_dictator_partner_gender en_dictator_pgender
	ren bs_redistribute_partner_gender_a bs_redistribute_pgendera
	ren bs_redistribute_partner_gender_b bs_redistribute_pgenderb
	ren en_redistribute_partner_gender_a en_redistribute_pgendera
	ren en_redistribute_partner_gender_b en_redistribute_pgenderb
	
	*defining value labels for main variables
	lab def position 1 Assistant 2 Auxiliary 3 Prosecutor 4 Judge
	lab val en_Position position
	lab def courses 1 Convention_Constitution 2 Constitutional_Interpretation 3 Jurisprudence 4 Reasoning 5 Virtues_Principles 6 Ethics
	lab val en_Course courses 
	lab def gender 1 Female 2 Male
	lab val en_Gender gender

	*encoding game variables
	foreach x in bs_dictator_pgender en_dictator_pgender bs_redistribute_pgendera en_redistribute_pgendera en_redistribute_pgenderb {
		encode `x', gen(`x'_num)
		lab val `x'_num gender
	}

	*creating dummies for main variables
	tab Position, gen(position_)
	tab Course, gen(course_)
	tab Gender, gen(gender_)
	
	
	/*-----
	Merging datasets
	-----*/
	
	*merging with satisfaction clean data
	merge m:1 DNI using sat_clean.dta
	drop _m

	*merging with grades clean data
	merge m:1 DNI using grades_clean.dta
	drop _m
	
	
	/*-----
	Creating variables using merged datasets vars
	-----*/
	
	*renaming satisfaction variables
	rename sat3 sat_instructor
	rename sat5 sat_exp
	rename sat2 sat_course
	rename meansat sat_avg

	*attrition
	gen attrition=.
	replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
	replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
	tab attrition