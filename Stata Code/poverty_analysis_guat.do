/*
	
	Columbia University
	February 10, 2025
	Theo Moers

*/

 #d;
 version 17.0; 
 clear; 
 capture log close;
 set more off;
 set logtype text;
 cd "/users/set_working_directory"; // 
 
 log using pov_analysis_guat.log, replace; *
 
 * data from: https://microdata.worldbank.org/index.php/catalog/586/get-microdata
 #d;
 use encovi.dta // 
 
 * Poverty profile
 #d;
 preserve;
 summarize incomepc, detail;
 local p95 = r(p95);
 drop if incomepc > `p95';
 
 gsort -incomepc;
 
 egen incrank = rank(incomepc);
 
 graph twoway line incomepc incrank, sort lcolor(stblue) lwidth(thick)
  yline(4319 1912, lpattern(dash))
  title("Poverty Profile")
  ytitle("households income (Quetzals)") xtitle("income rank")
  ylabel(0(5000)25000, grid)
  text(6000 7000 "Full Povery Line")
  text(3000 7000 "Extreme Povery Line")
  saving(poverty_profile_guat, replace);
  
 graph export poverty_profile_guat.pdf, replace;
  
 restore;
 
 * Poverty indices (P0, P1, P2) using the full poverty line
 #delimit;
 gen fullpoverty = 4319;
 
 #d; 
 count;
 local n_obs = r(N);
 gen y_below = (incomepc<fullpoverty);
 
 * P0
 #d; 
 count if y_below==1;
 local q_full r(N);
 
 #d; 
 local p_0 = `q_full'/`n_obs';
 display `p_0';
 
 * P1
 #delimit;
 gen income_diff_rel_p1 = ((fullpoverty - incomepc)/fullpoverty);
 gen total_income_diff_q_p1 =.;
 replace total_income_diff_q_p1=income_diff_rel_p1 if y_below==1;
 egen p_1_pre = total(total_income_diff_q_p1);
 local p_1 r(sum)/`n_obs';
 display `p_1';
 
  * P2
 #delimit;
 gen income_diff_rel_p2 = ((fullpoverty-incomepc)/fullpoverty)^2;
 gen total_income_diff_q_p2 =.;
 replace total_income_diff_q_p2=income_diff_rel_p2 if y_below==1;
 egen p_2_pre = total(total_income_diff_q_p2);
 local p_2 r(sum)/`n_obs';
 display `p_2';
 
 #d;
 drop income_diff_rel_p1 total_income_diff_q_p1 income_diff_rel_p2 total_income_diff_q_p2 y_below;
 
 * Poverty indices using the extreme poverty line
 #d;
 gen expoverty = 1912;
 count;
 local n_obs = r(N);
 
 #d; 
 gen y_below_ex = (incomepc<expoverty);
 
 * P0
 #d;
 count if y_below_ex==1;
 
 #d; 
 local p_0_ex = `q_full'/`n_obs';
 display `p_0_ex';
 
 * P1
 #d;
 gen income_diff_rel_p1_ex = ((expoverty-incomepc)/expoverty);
 gen total_income_diff_q_p1_ex =.;
 replace total_income_diff_q_p1_ex=income_diff_rel_p1_ex if y_below_ex==1;
 egen p_1_pre_ex = total(total_income_diff_q_p1_ex);
 local p_1_ex r(sum)/`n_obs';
 display `p_1_ex';
 
 * P2
 #d; 
 gen income_diff_rel_p2_ex = ((expoverty-incomepc)/expoverty)^2;
 gen total_income_diff_q_p2_ex =.;
 replace total_income_diff_q_p2_ex=income_diff_rel_p2_ex if y_below_ex==1;
 egen p_2_pre_ex = total(total_income_diff_q_p2_ex);
 local p_2_ex r(sum)/`n_obs';
 display `p_2_ex';
 
 #d;
 drop income_diff_rel_p1_ex total_income_diff_q_p1_ex income_diff_rel_p2_ex total_income_diff_q_p2_ex y_below_ex p_1_pre_ex;
 
 * P2 seperately by urban and rural households (full poverty line)
 #d; 
 gen urbans =.;
 gen rurals =.;
 replace urbans=incomepc if urban==1;
 replace rurals=incomepc if urban==0;
 
 * For urbans:
 #d; 
 count if urban;
 local n_urban = r(N);
 display `n_urban';
 
 #d; 
 gen y_urban = (urbans<fullpoverty);
 
 gen income_diff_urban = ((fullpoverty-urbans)/fullpoverty)^2;
 gen total_income_diff_urban =.;
 replace total_income_diff_urban=income_diff_urban if y_urban==1;
 egen p2_urban = total(total_income_diff_urban);
 local p2_urban r(sum)/`n_urban';
 display `p2_urban';
 
 * For rurals:
 #d; 
 count if !urban;
 local n_rural = r(N);
 display `n_rural';
 
 #d; 
 gen y_rural = (rurals<fullpoverty);
 
 gen income_diff_rural = ((fullpoverty-rurals)/fullpoverty)^2;
 gen total_income_diff_rural =.;
 replace total_income_diff_rural=income_diff_rural if y_rural==1;
 egen p2_rural = total(total_income_diff_rural);
 local p2_rural r(sum)/`n_rural';
 display `p2_rural';
 
 #d;
 drop income_diff_urban total_income_diff_urban income_diff_rural total_income_diff_rural y_urban y_rural p2_urban p2_rural;
 
 * P2 seperately by indigenous and non-indigenous households (full poverty line)
 #d; 
 gen indigs =.;
 gen nonindigs =.;
 replace indigs=incomepc if indig==1;
 replace nonindigs=incomepc if indig==0;
 
 * For indigenous:
 #d; 
 count if indig;
 local n_indig = r(N);
 display `n_indig';
 
 #d; 
 gen y_indig = (indigs<fullpoverty);
 
 gen income_diff_indig = ((fullpoverty-indigs)/fullpoverty)^2;
 gen total_income_diff_indig =.;
 replace total_income_diff_indig=income_diff_indig if y_indig==1;
 egen p2_indig = total(total_income_diff_indig);
 local p2_indig r(sum)/`n_indig';
 display `p2_indig';
 
 * For non-indigenous:
 #d; 
 count if !indig;
 local n_nonindig = r(N);
 display `n_nonindig';
 
 #d; 
 gen y_nonindig = (nonindigs<fullpoverty);
 
 gen income_diff_nonindig = ((fullpoverty-nonindigs)/fullpoverty)^2;
 gen total_income_diff_nonindig =.;
 replace total_income_diff_nonindig=income_diff_nonindig if y_nonindig==1;
 egen p2_nonindig = total(total_income_diff_nonindig);
 local p2_nonindig r(sum)/`n_nonindig';
 display `p2_nonindig';
 
 #d;
 drop income_diff_indig total_income_diff_indig income_diff_nonindig total_income_diff_nonindig y_indig y_nonindig p2_indig p2_nonindig;
 
 * P2 seperately by regions (full poverty line)
 #d; 
 local i=1;
 matrix regionP2s=J(8, 2, 0);
 
 local p2_overall=0.1828;
 local total_pop=7230;
 
 while `i' <= 8 {;
	
	gen region_subset =.;
	replace region_subset=incomepc if region==`i';
	
	#d;
	count if region==`i';
	local n_obsers=r(N);
	local region_share `n_obsers'/`total_pop';
	
	#d;
	gen q_s = (region_subset<fullpoverty);
	gen income_difference = ((fullpoverty-region_subset)/fullpoverty)^2;
	gen total_income_difference =.;
	replace total_income_difference=income_difference if q_s==1;
	egen p2_region = total(total_income_difference);
	local p2_region r(sum)/`n_obsers';
	
	local region_contrib `p2_region'*`region_share'/`p2_overall';
	
	matrix regionP2s[`i', 1] = `p2_region';
	matrix regionP2s[`i', 2] = `region_contrib';
	
	local i=`i'+1;
	drop region_subset q_s income_difference total_income_difference p2_region;
 };
 
 #d; 
 matrix colnames regionP2s = p2 p2_contribution;
 matlist regionP2s;
 
 * Infering consumption index
 #d;
 xi i.region; 
 
 gen lincomepc = ln(incomepc);
 
 reg lincomepc _Iregion_2 _Iregion_3 _Iregion_4 _Iregion_5 _Iregion_6 _Iregion_7 _Iregion_8 urban indig spanish n0_6 n7_24 n25_59 n60_plus hhhfemal hhhage ed_1_5 ed_6 ed_7_10 ed_11 ed_m11, robust;
 
 predict lnpredicted_cons;
 
 gen predicted_cons = exp(lnpredicted_cons);
 
 * Calculating P2 index using predicted values
 #d; 
 count;
 local n_obs = r(N);
 gen y_predict = (predicted_cons<fullpoverty);
 
 #d; 
 gen income_diff_predict = ((fullpoverty-predicted_cons)/fullpoverty)^2;
 gen total_income_diff_predict =.;
 replace total_income_diff_predict=income_diff_predict if y_predict==1;
 egen p2_predict = total(total_income_diff_predict);
 local p2_predict r(sum)/`n_obs';
 display `p2_predict';
 
 #d;
 drop income_diff_predict total_income_diff_predict y_predict p2_predict;
 
 * Income inequality distribution analysis:
 #d;
 * Cumulative income shares
 sort incomepc;
 egen totalincome = total(incomepc);
 gen income_share = incomepc/totalincome;
 sort incomepc;
 gen cumul_incomesh = sum(income_share);
 
 * Cumulative population shares
 #d;
 gen ones = 1;
 gen ones_cu = sum(ones);
 egen total_obs = total(ones);
 gen cumul_pop = (ones_cu-1)/total_obs;
 
 * Calculate Gini index
 #d;
 gen xdiff = cumul_pop - cumul_pop[_n-1];
 gen ysum = cumul_incomesh + cumul_incomesh[_n-1];
 gen trapezoid = (1/2)*ysum*xdiff;
 egen area_B = total(trapezoid);
 local gini = 1-(2*area_B);
 local gini_rounded = round(`gini', 0.0001);

  * Plotting Lorenz curve
 #d;
 graph twoway scatter cumul_incomesh cumul_pop cumul_pop, sort
  msymbol(none none) connect(l l) lpattern(solid dash) lcolor(red gray)
  ysize(7.5) xsize(7)
  plotregion(lcolor(black) lwidth(thin))
  title("Lorenz Curve (Gini coeff: `gini_rounded')")
  ytitle("Cum. share of total income") 
  xtitle("Cum. share of households")
  legend(position(6) rows(1) region(lcolor(black))
  label(1 "Cumulative Income") label(2 "45° (no inequality)"))
  saving(lorenz_curve, replace);
  
 graph export lorenz_curve.pdf, replace;
 
 
 
 
 

 
 
 
 
 
