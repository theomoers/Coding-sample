/*
	
	Program Evaluation of PROGRESA
	Columbia University
	April 22, 2025
	Theo Moers

*/


 #d;
 version 17.0; 
 clear; 
 capture log close;
 set more off;
 set logtype text;
 * cd
 
 log using tlm2160_AED_4.log, replace; *
 
 #d;
 use ps4.dta;
 describe;
 
 
 * Q2.2;
 
 #d;
 preserve;
	 drop if program==1;
	 sort age97;
	 by age97: summarize enroll97;

 * Q2.3;
	 by age97: summarize work97;
	 
 restore;
 
 * Q3.1-3;
 #d;
 drop if age97 == 5;

 preserve;

 collapse 
    (mean) age97mean = age97 grade97mean = grade97 enroll97mean = enroll97 
    (sd) age97sd = age97 grade97sd = grade97 enroll97sd = enroll97 
    (count) age97count = age97 grade97count = grade97 enroll97count = enroll97, 
    by(program);

 gen age97se = age97sd / sqrt(age97count) ;
 gen grade97se = grade97sd / sqrt(grade97count) ;
 gen enroll97se = enroll97sd / sqrt(enroll97count) ;

 tempfile collapsed_stats ;
 save `collapsed_stats' ;

 list program age97mean age97sd age97count age97se
     grade97mean grade97sd grade97count grade97se
     enroll97mean enroll97sd enroll97count enroll97se ;

 restore ;

 use `collapsed_stats', clear;

 preserve;

 keep if program == 1 ;
 gen treat_age97mean = age97mean ;
 gen treat_age97se = age97se ;
 gen treat_grade97mean = grade97mean ;
 gen treat_grade97se = grade97se ;
 gen treat_enroll97mean = enroll97mean ;
 gen treat_enroll97se = enroll97se ;
 keep treat_* ;
 tempfile treat ;
 save `treat' ;

 restore;

 use `collapsed_stats', clear;
 keep if program == 0;
 gen ctrl_age97mean = age97mean;
 gen ctrl_age97se = age97se;
 gen ctrl_grade97mean = grade97mean;
 gen ctrl_grade97se = grade97se;
 gen ctrl_enroll97mean = enroll97mean;
 gen ctrl_enroll97se = enroll97se;
 keep ctrl_*;

 cross using `treat';

 gen diff_age97 = treat_age97mean - ctrl_age97mean;
 gen se_diff_age97 = sqrt(treat_age97se^2 + ctrl_age97se^2);
 gen ci_low_age97 = diff_age97 - 1.96 * se_diff_age97;
 gen ci_high_age97 = diff_age97 + 1.96 * se_diff_age97;
 
 gen diff_grade97 = treat_grade97mean - ctrl_grade97mean;
 gen se_diff_grade97 = sqrt(treat_grade97se^2 + ctrl_grade97se^2);
 gen ci_low_grade97 = diff_grade97 - 1.96 * se_diff_grade97;
 gen ci_high_grade97 = diff_grade97 + 1.96 * se_diff_grade97;

 gen diff_enroll97 = treat_enroll97mean - ctrl_enroll97mean;
 gen se_diff_enroll97 = sqrt(treat_enroll97se^2 + ctrl_enroll97se^2);
 gen ci_low_enroll97 = diff_enroll97 - 1.96 * se_diff_enroll97;
 gen ci_high_enroll97 = diff_enroll97 + 1.96 * se_diff_enroll97;

 list diff_* se_diff_* ci_low_* ci_high_*;

 * Q3.4;
 #d;
 clear;
 use ps4.dta;
 drop if age97 == 5;
 ttest age97, by(program) unequal reverse;
 ttest grade97, by(program) unequal reverse;
 ttest enroll97, by(program) unequal reverse;

 * Q3.6;
 #d;
 sureg (age97 program) (grade97 program) (enroll97 program), small dfk;
 test ([age97]program = 0) ([grade97]program = 0) ([enroll97]program = 0);
 
 * Q4.1;
 #d;
 clear; use ps4.dta;
 drop if age98 == 17;

 ttest enroll98 if age98 >= 6 & age98 <= 11, by(program) unequal;

 ttest work98 if age98 >= 6 & age98 <= 11, by(program) unequal;

 ttest enroll98 if age98 >= 12 & age98 <= 16, by(program) unequal;

 ttest work98 if age98 >= 12 & age98 <= 16, by(program) unequal;
 
 * Q4.2;
 #d;
 ttest continued98, by(program) unequal;
 
 * Q4.3;
 * boys;
 #d;
 clear; use ps4.dta;
 drop if age98 == 17;
 keep if male == 1;
 ttest enroll98 if age98 >= 6 & age98 <= 11, by(program) unequal;
 ttest work98 if age98 >= 6 & age98 <= 11, by(program) unequal;
 ttest enroll98 if age98 >= 12 & age98 <= 16, by(program) unequal;
 ttest work98 if age98 >= 12 & age98 <= 16, by(program) unequal;
 ttest continued98, by(program) unequal;
 
 * girls;
 clear; use ps4.dta;
 drop if age98 == 17;
 drop if male == 1;
 ttest enroll98 if age98 >= 6 & age98 <= 11, by(program) unequal;
 ttest work98 if age98 >= 6 & age98 <= 11, by(program) unequal;
 ttest enroll98 if age98 >= 12 & age98 <= 16, by(program) unequal;
 ttest work98 if age98 >= 12 & age98 <= 16, by(program) unequal;
 ttest continued98, by(program) unequal;
 
 
 
