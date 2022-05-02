/***********
**Regressions for treatment effects
on Trolley

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

	/*-----
	Trolley regressions
	-----*/
	
	**defining controls
	global controls i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position
	global controls_miss "en_Course, Age_rounded, Age_squared, en_Gender, en_Position"
	
	**generating book choice (if 3 and 4, outcome = 1, else outcome = 0)
	gen simplified_book_ch = 1 if en_book == 3 | en_book == 4
	replace simplified_book_ch = 0 if en_book == 1 | en_book == 2
	
	reg simplified_book_ch iat_option_take_or_not, vce(cluster Course) // regression no controls
	outreg2 using "$tables\en_book_regs.xls", replace stats(coef pval ) level(95) addtext("Controls", "No") label keep(iat_option_take_or_not) nocons nor2
	leebounds simplified_book_ch iat_option_take_or_not
	
	reg simplified_book_ch iat_option_take_or_not $controls, vce(cluster Course) // regression controls
	outreg2 using "$tables\en_book_regs.xls", stats(coef pval ) level(95) addtext("Controls", "Yes") label keep(iat_option_take_or_not) nocons nor2
	