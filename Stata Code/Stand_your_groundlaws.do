* Code to investigate the effect of stand your ground laws on homicide rates 
* using state-year fixed effects

clear all

use "castle_expanded.dta", clear
gen homicide_r = (homicide_c/population*100000)
gen homicide_r_ln = ln(homicide_r)
save "castle_modified.dta", replace

sum homicide_r homicide_r_ln [aw=population]
ssc install distinct
distinct year state

preserve
	collapse (max) D, by(state)
	tab D
restore

tab evertreated if year==2000 [aw=population], sum(homicide_r)
hist homicide_r if year==2000, frequency width(1)
hist homicide_r_ln  if year==2000, frequency width(.25)

twoway	(hist homicide_r if year == 2000, frequency width(1) color(green%30)) ///
		(hist homicide_r if year == 2010, frequency width(1)  ///
		color(purple%30)),  ///
		legend(order(1 "2000" 2 "2010")) ///
		xlabel(0(2)16) ///
		xtitle("Homicide Rate (per 100,000 people)")
		
keep if state == "Florida" | missing(treatment_date)
tabulate state treatment_date
list state treatment_date

* Compare homicide rates in Florida with states that never had stand your ground
* Laws
preserve
	collapse (mean) homicide_r homicide_r_ln [aw=population], by(year evertreated)
	list year evertreated homicide_r 
	xtset evertreated year 
	xtline homicide_r_ln, overlay xline(2005) ///
			xlabel(2000(1)2010) ///
			legend(order(1 "States without Stand Your Ground laws" 2 "Florida (with Stand Your Ground law in 2005)") pos(6)) ///
			ytitle("Log of homicide rate (per 100,000 people)") ///
			xtitle("Year")
restore

* Compare homicide rates in all states that adoped SYG laws in 2006 compared to
* control group
clear all
use "castle_modified.dta", clear

tab state treatment_date if treatment_date == 2006


keep if treatment_date == 2006 | missing(treatment_date)
tabulate state treatment_date
preserve
	collapse (mean) homicide_r homicide_r_ln [aw=population], by(year evertreated)
	list year evertreated homicide_r
	
	xtset evertreated year
	xtline homicide_r_ln, overlay xline(2006) ///
		xlabel(2000(1)2010) ///
		legend(order(1 "States without Stand Your Ground laws" 2 "States that adopted Stand Your Ground laws in 2006") pos(6)) ///
			ytitle("Log of homicide rate (per 100,000 people)") ///
			xtitle("Year")
restore

* Create DiD regression and test parallel trends (unweighted)
clear all
use "castle_modified.dta", clear

keep if treatment_date == 2006 | missing(treatment_date)

gen after = (year >= 2006)
tab year after

gen treated = treatment_date == 2006
tab after treated

gen did = after*treated
encode state, gen(state1)

xtset state1 year

xtdidregress (homicide_r_ln) (did), group(state1) time(year) 
estat ptrends
estat trendplots

clear all
use "castle_modified.dta", clear

* Regression using state-year fixed effects
ssc install reghdfe
reghdfe homicide_r_ln D, absorb(state year) cluster(state)

* Create plot for event study TWFE mmodel:
gen event_time = year - treatment_date if !missing(treatment_date)
drop if missing(event_time)

gen treated = !missing(treatment_date)
reghdfe homicide_r_ln i.event_time##i.treated, absorb(state year) cluster(state)

estat summarize

matrix b = e(b)
matrix V = e(V)

local rows = rowsof(b)
gen event_time_coeff = .
gen event_time_se = .

forval i = 1/`rows' {
    gen event_time_coeff[_n] = _b[event_time[`i']]
    gen event_time_se[_n] = _se[event_time[`i']]
}

gen lower_bound = event_time_coeff - 1.96 * event_time_se
gen upper_bound = event_time_coeff + 1.96 * event_time_se

twoway (scatter event_time_coeff event_time, msymbol(o)) ///
       (rcap lower_bound upper_bound event_time), ///
       xline(0) yline(0) ///
       xtitle("Years before and after Stand Your Ground law takes effect") ///
       ytitle("log(murder rate)") ///
       legend(off)

* Implement Goodman-Bacon decomposition
net install ddtiming, from(https://raw.githubusercontent.com/tgoldring/ddtiming/master)

use "castle_modified.dta", clear
ddtiming homicide_r_ln D, i(sid) t(year)

matrix results = e(results)
matrix list results
