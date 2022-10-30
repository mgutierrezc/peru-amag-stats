cls
/*=============================
Summary statistics based on PNAS
paper of Social Preferences

---
author: Marco Gutierrez
=============================*/

clear all
set more off
program drop _all

/*=====
Setting up directories
=====*/

*di `"Please, input the main path where the required data for running this dofile is stored into the COMMAND WINDOW and then press ENTER  "'  _request(path)
global path "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$path\Data"
global judges_outcomes "$data\judges-outcomes\final"
global output "$path\output"
global modules "$path\Code\Analysis\Modules"

global docs "$output\eval_regs"
cap mkdir "$docs"

global tables "$docs\tables"
cap mkdir "$tables"

global graphs "$docs\graphs"
cap mkdir "$graphs"

cd "$data"
use "Clean_Full_Data12.dta"   /// stata 12 friendly

/*
Descriptive statistics from all judges
social preferences
*/

	**Dictator**
	sum bs_dictator_player_decision
	sum en_dictator_player_decision	

	**Creating standardized version of the variables
	gen bs_dictator_dec = bs_dictator_player_decision*10
	gen en_dictator_dec = en_dictator_player_decision*10
	
	table (var) (Cargo), statistic(mean bs_dictator_dec) statistic(mean en_dictator_dec) nototals nformat(%9.2f)
	
	/**Redistribution**
	*partner a: Male
	*partner b: Female
	The same applies to Dictator
	
	were all people participants in the experiment?
	were the partners assigned at random?
	proposed: work with outcomes of Dictator and Redistribution by partner pairs
	
	- Dictator: compare results of partner male vs female
		- for all participants
		- differentiating if participant has same sex
		- bs: 552
		- en: 354
	
	- Redistribution
		- compare results when partners where same sex vs different sex
		- check if participants were biased to same sex partners
		- bs: 573
		- en: 448
	
	**Die roll**
	- Die roll (baseline only)
	- 546 obs
	
	Ultimatum
	- aprox 200
	
	Based on PNAS, we could run some regressions using the sex pf partners and participants, as well as their demographical characteristics for the outcomes of Redistribution and Dictator.
	
	Ultimatum and Die could be run 
	
	Moritz will be checking what can be done for the data based on the Science paper @Daniel shared
	*/
	
	
	