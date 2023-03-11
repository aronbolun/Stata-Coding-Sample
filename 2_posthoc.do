*******************************************
*Date created: 9/20/2022
*Date modified: 9/29/2022
*Description: Post-hoc analyses supplementary
*******************************************
/*TABLE OF CONTENTS
0) Setup
1) For each Study, provide the mean of transition time (Non-logged) across the whole sample (R1.2c)
2) Summary statistics of all measures of interest across the treatments (R3.6)
3) Robust regressions (R3.10)
4) Impact of queue configuration on variability of processing time (R3.11)
5) Additional mediation analysis (Mediation re: impact of queue on performance)
*/

********************************************************************************
*0) Setup

/*  Please ensure you install the robust regression packages before.
    ssc install robreg, replace
	ssc install moremata, replace
	
    Please ensure you install the mediation package before.
    ssc install mediation 
*/
********************************************************************************
log using "$Output/Logs/MedRoutine/2_posthoc.txt", text replace
global repnum 1000
global seednum 02138


********************************************************************************
*1) For each Study, provide the mean of transition time (Non-logged) across the whole sample (R1.2c) ********************************************************************************
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

summarize transtime_imp

*Limit analysis to session 2 data
keep if session==2

summarize transtime_imp


********************************************************************************
*2) Summary statistics of all measures of interest across the treatments (R3.6)
/*
    Experimental round 2 for Study 1 and 2; and Experimental round for Study 3
    4 different versions: 
   (a) mean across subjects, median within subject; non-logged
   (b) median across subjects, median within subject; non-logged
   (c) mean across subjects, median within subject; logged
   (d) median across subjects, median within subject; logged
*/
********************************************************************************

********************************************************************************
*2-1) Performance DVs summary statistics
********************************************************************************
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_subject_20220919.dta", clear

**Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

**Limit analysis to session 2 data
keep if session==2

*Calculate mean, median, standard error across & within subjects for each DV
collapse (mean) mean_mean_serv_proctime=mean_serv_proctime mean_med_serv_proctime=med_serv_proctime mean_ln_mean_serv_proctime=ln_mean_serv_proctime mean_ln_med_serv_proctime=ln_med_serv_proctime mean_mean_waittime_imp=mean_waittime_imp mean_med_waittime_imp=med_waittime_imp mean_ln_mean_waittime_imp=ln_mean_waittime_imp mean_ln_med_waittime_imp=ln_med_waittime_imp mean_mean_thrutime_imp=mean_thrutime_imp mean_med_thrutime_imp=med_thrutime_imp mean_ln_mean_thrutime_imp=ln_mean_thrutime_imp mean_ln_med_thrutime_imp=ln_med_thrutime_imp mean_mean_accuracy=mean_accuracy mean_med_accuracy=med_accuracy mean_ln_mean_accuracy=ln_mean_accuracy mean_ln_med_accuracy=ln_med_accuracy mean_mean_serv_thrurate=mean_serv_thrurate mean_med_serv_thrurate=med_serv_thrurate mean_ln_mean_serv_thrurate=ln_mean_serv_thrurate mean_ln_med_serv_thrurate=ln_med_serv_thrurate (median) med_mean_serv_proctime=mean_serv_proctime med_med_serv_proctime=med_serv_proctime med_ln_mean_serv_proctime=ln_mean_serv_proctime med_ln_med_serv_proctime=ln_med_serv_proctime med_mean_waittime_imp=mean_waittime_imp med_med_waittime_imp=med_waittime_imp med_ln_mean_waittime_imp=ln_mean_waittime_imp med_ln_med_waittime_imp=ln_med_waittime_imp med_mean_thrutime_imp=mean_thrutime_imp med_med_thrutime_imp=med_thrutime_imp med_ln_mean_thrutime_imp=ln_mean_thrutime_imp med_ln_med_thrutime_imp=ln_med_thrutime_imp med_mean_accuracy=mean_accuracy med_med_accuracy=med_accuracy med_ln_mean_accuracy=ln_mean_accuracy med_ln_med_accuracy=ln_med_accuracy med_mean_serv_thrurate=mean_serv_thrurate med_med_serv_thrurate=med_serv_thrurate med_ln_mean_serv_thrurate=ln_mean_serv_thrurate med_ln_med_serv_thrurate=ln_med_serv_thrurate (semean) semean_mean_serv_proctime=mean_serv_proctime semean_med_serv_proctime=med_serv_proctime semean_ln_mean_serv_proctime=ln_mean_serv_proctime semean_ln_med_serv_proctime=ln_med_serv_proctime semean_mean_waittime_imp=mean_waittime_imp semean_med_waittime_imp=med_waittime_imp semean_ln_mean_waittime_imp=ln_mean_waittime_imp semean_ln_med_waittime_imp=ln_med_waittime_imp semean_mean_thrutime_imp=mean_thrutime_imp semean_med_thrutime_imp=med_thrutime_imp semean_ln_mean_thrutime_imp=ln_mean_thrutime_imp semean_ln_med_thrutime_imp=ln_med_thrutime_imp semean_mean_accuracy=mean_accuracy semean_med_accuracy=med_accuracy semean_ln_mean_accuracy=ln_mean_accuracy semean_ln_med_accuracy=ln_med_accuracy semean_mean_serv_thrurate=mean_serv_thrurate semean_med_serv_thrurate=med_serv_thrurate semean_ln_mean_serv_thrurate=ln_mean_serv_thrurate semean_ln_med_serv_thrurate=ln_med_serv_thrurate, by(DQ)

/*Calculate corresponding error bars with 95% CI for each DV
/* The standard error of the median for large samples and normal distributions is about 25% larger than that for the mean. */
gen mean_mean_serv_proctime_hi = mean_mean_serv_proctime + (1.96*semean_mean_serv_proctime)
gen mean_mean_serv_proctime_lo = mean_mean_serv_proctime - (1.96*semean_mean_serv_proctime)
gen mean_mean_waittime_imp_hi = mean_mean_waittime_imp + (1.96*semean_mean_waittime_imp)
gen mean_mean_waittime_imp_lo = mean_mean_waittime_imp - (1.96*semean_mean_waittime_imp)
gen mean_mean_thrutime_imp_hi = mean_mean_thrutime_imp + (1.96*semean_mean_thrutime_imp)
gen mean_mean_thrutime_imp_lo = mean_mean_thrutime_imp - (1.96*semean_mean_thrutime_imp)
gen mean_mean_accuracy_hi = mean_mean_accuracy + (1.96*semean_mean_accuracy)
gen mean_mean_accuracy_lo = mean_mean_accuracy - (1.96*semean_mean_accuracy)
gen mean_mean_serv_thrurate_hi = mean_mean_serv_thrurate + (1.96*semean_mean_serv_thrurate)
gen mean_mean_serv_thrurate_lo = mean_mean_serv_thrurate - (1.96*semean_mean_serv_thrurate)

gen mean_ln_mean_serv_proctime_hi = mean_ln_mean_serv_proctime + (1.96*semean_ln_mean_serv_proctime)
gen mean_ln_mean_serv_proctime_lo = mean_ln_mean_serv_proctime - (1.96*semean_ln_mean_serv_proctime)
gen mean_ln_mean_waittime_imp_hi = mean_ln_mean_waittime_imp + (1.96*semean_ln_mean_waittime_imp)
gen mean_ln_mean_waittime_imp_lo = mean_ln_mean_waittime_imp - (1.96*semean_ln_mean_waittime_imp)
gen mean_ln_mean_thrutime_imp_hi = mean_ln_mean_thrutime_imp + (1.96*semean_ln_mean_thrutime_imp)
gen mean_ln_mean_thrutime_imp_lo = mean_ln_mean_thrutime_imp - (1.96*semean_ln_mean_thrutime_imp)
gen mean_ln_mean_accuracy_hi = mean_ln_mean_accuracy + (1.96*semean_ln_mean_accuracy)
gen mean_ln_mean_accuracy_lo = mean_ln_mean_accuracy - (1.96*semean_ln_mean_accuracy)
gen mean_ln_mean_serv_thrurate_hi = mean_ln_mean_serv_thrurate + (1.96*semean_ln_mean_serv_thrurate)
gen mean_ln_mean_serv_thrurate_lo = mean_ln_mean_serv_thrurate - (1.96*semean_ln_mean_serv_thrurate)

gen med_mean_serv_proctime_hi = med_mean_serv_proctime + (1.96*1.25*semean_mean_serv_proctime)
gen med_mean_serv_proctime_lo = med_mean_serv_proctime - (1.96*1.25*semean_mean_serv_proctime)
gen med_mean_waittime_imp_hi = med_mean_waittime_imp + (1.96*1.25*semean_mean_waittime_imp)
gen med_mean_waittime_imp_lo = med_mean_waittime_imp - (1.96*1.25*semean_mean_waittime_imp)
gen med_mean_thrutime_imp_hi = med_mean_thrutime_imp + (1.96*1.25*semean_mean_thrutime_imp)
gen med_mean_thrutime_imp_lo = med_mean_thrutime_imp - (1.96*1.25*semean_mean_thrutime_imp)
gen med_mean_accuracy_hi = med_mean_accuracy + (1.96*1.25*semean_mean_accuracy)
gen med_mean_accuracy_lo = med_mean_accuracy - (1.96*1.25*semean_mean_accuracy)
gen med_mean_serv_thrurate_hi = med_mean_serv_thrurate + (1.96*1.25*semean_mean_serv_thrurate)
gen med_mean_serv_thrurate_lo = med_mean_serv_thrurate - (1.96*1.25*semean_mean_serv_thrurate)

gen med_ln_mean_serv_proctime_hi = med_ln_mean_serv_proctime + (1.96*1.25*semean_ln_mean_serv_proctime)
gen med_ln_mean_serv_proctime_lo = med_ln_mean_serv_proctime - (1.96*1.25*semean_ln_mean_serv_proctime)
gen med_ln_mean_waittime_imp_hi = med_ln_mean_waittime_imp + (1.96*1.25*semean_ln_mean_waittime_imp)
gen med_ln_mean_waittime_imp_lo = med_ln_mean_waittime_imp - (1.96*1.25*semean_ln_mean_waittime_imp)
gen med_ln_mean_thrutime_imp_hi = med_ln_mean_thrutime_imp + (1.96*1.25*semean_ln_mean_thrutime_imp)
gen med_ln_mean_thrutime_imp_lo = med_ln_mean_thrutime_imp - (1.96*1.25*semean_ln_mean_thrutime_imp)
gen med_ln_mean_accuracy_hi = med_ln_mean_accuracy + (1.96*1.25*semean_ln_mean_accuracy)
gen med_ln_mean_accuracy_lo = med_ln_mean_accuracy - (1.96*1.25*semean_ln_mean_accuracy)
gen med_ln_mean_serv_thrurate_hi = med_ln_mean_serv_thrurate + (1.96*1.25*semean_ln_mean_serv_thrurate)
gen med_ln_mean_serv_thrurate_lo = med_ln_mean_serv_thrurate - (1.96*1.25*semean_ln_mean_serv_thrurate)

gen mean_med_serv_proctime_hi = mean_med_serv_proctime + (1.96*semean_med_serv_proctime)
gen mean_med_serv_proctime_lo = mean_med_serv_proctime - (1.96*semean_med_serv_proctime)
gen mean_med_waittime_imp_hi = mean_med_waittime_imp + (1.96*semean_med_waittime_imp)
gen mean_med_waittime_imp_lo = mean_med_waittime_imp - (1.96*semean_med_waittime_imp)
gen mean_med_thrutime_imp_hi = mean_med_thrutime_imp + (1.96*semean_med_thrutime_imp)
gen mean_med_thrutime_imp_lo = mean_med_thrutime_imp - (1.96*semean_med_thrutime_imp)
gen mean_med_accuracy_hi = mean_med_accuracy + (1.96*semean_med_accuracy)
gen mean_med_accuracy_lo = mean_med_accuracy - (1.96*semean_med_accuracy)
gen mean_med_serv_thrurate_hi = mean_med_serv_thrurate + (1.96*semean_med_serv_thrurate)
gen mean_med_serv_thrurate_lo = mean_med_serv_thrurate - (1.96*semean_med_serv_thrurate)

gen mean_ln_med_serv_proctime_hi = mean_ln_med_serv_proctime + (1.96*semean_ln_med_serv_proctime)
gen mean_ln_med_serv_proctime_lo = mean_ln_med_serv_proctime - (1.96*semean_ln_med_serv_proctime)
gen mean_ln_med_waittime_imp_hi = mean_ln_med_waittime_imp + (1.96*semean_ln_med_waittime_imp)
gen mean_ln_med_waittime_imp_lo = mean_ln_med_waittime_imp - (1.96*semean_ln_med_waittime_imp)
gen mean_ln_med_thrutime_imp_hi = mean_ln_med_thrutime_imp + (1.96*semean_ln_med_thrutime_imp)
gen mean_ln_med_thrutime_imp_lo = mean_ln_med_thrutime_imp - (1.96*semean_ln_med_thrutime_imp)
gen mean_ln_med_accuracy_hi = mean_ln_med_accuracy + (1.96*semean_ln_med_accuracy)
gen mean_ln_med_accuracy_lo = mean_ln_med_accuracy - (1.96*semean_ln_med_accuracy)
gen mean_ln_med_serv_thrurate_hi = mean_ln_med_serv_thrurate + (1.96*semean_ln_med_serv_thrurate)
gen mean_ln_med_serv_thrurate_lo = mean_ln_med_serv_thrurate - (1.96*semean_ln_med_serv_thrurate)

gen med_med_serv_proctime_hi = med_med_serv_proctime + (1.96*1.25*semean_med_serv_proctime)
gen med_med_serv_proctime_lo = med_med_serv_proctime - (1.96*1.25*semean_med_serv_proctime)
gen med_med_waittime_imp_hi = med_med_waittime_imp + (1.96*1.25*semean_med_waittime_imp)
gen med_med_waittime_imp_lo = med_med_waittime_imp - (1.96*1.25*semean_med_waittime_imp)
gen med_med_thrutime_imp_hi = med_med_thrutime_imp + (1.96*1.25*semean_med_thrutime_imp)
gen med_med_thrutime_imp_lo = med_med_thrutime_imp - (1.96*1.25*semean_med_thrutime_imp)
gen med_med_accuracy_hi = med_med_accuracy + (1.96*1.25*semean_med_accuracy)
gen med_med_accuracy_lo = med_med_accuracy - (1.96*1.25*semean_med_accuracy)
gen med_med_serv_thrurate_hi = med_med_serv_thrurate + (1.96*1.25*semean_med_serv_thrurate)
gen med_med_serv_thrurate_lo = med_med_serv_thrurate - (1.96*1.25*semean_med_serv_thrurate)

gen med_ln_med_serv_proctime_hi = med_ln_med_serv_proctime + (1.96*1.25*semean_ln_med_serv_proctime)
gen med_ln_med_serv_proctime_lo = med_ln_med_serv_proctime - (1.96*1.25*semean_ln_med_serv_proctime)
gen med_ln_med_waittime_imp_hi = med_ln_med_waittime_imp + (1.96*1.25*semean_ln_med_waittime_imp)
gen med_ln_med_waittime_imp_lo = med_ln_med_waittime_imp - (1.96*1.25*semean_ln_med_waittime_imp)
gen med_ln_med_thrutime_imp_hi = med_ln_med_thrutime_imp + (1.96*1.25*semean_ln_med_thrutime_imp)
gen med_ln_med_thrutime_imp_lo = med_ln_med_thrutime_imp - (1.96*1.25*semean_ln_med_thrutime_imp)
gen med_ln_med_accuracy_hi = med_ln_med_accuracy + (1.96*1.25*semean_ln_med_accuracy)
gen med_ln_med_accuracy_lo = med_ln_med_accuracy - (1.96*1.25*semean_ln_med_accuracy)
gen med_ln_med_serv_thrurate_hi = med_ln_med_serv_thrurate + (1.96*1.25*semean_ln_med_serv_thrurate)
gen med_ln_med_serv_thrurate_lo = med_ln_med_serv_thrurate - (1.96*1.25*semean_ln_med_serv_thrurate)

*/

/*Generate a variable: "type" to represent mean_mean (nonlog) (type == 1), mean_mean (log) (type == 2), med_mean (nonlog) (type == 3), med_mean (log) (type = 4), mean_med (nonlog) (type == 5), mean_med (log) (type == 6), med_med (nonlog) (type == 7), med_med (log) (type == 8), and then split the data to 8 parts */

** mean_mean (nonlog)
preserve
tempfile mean_mean_nonlog
local mean_mean_nonlog_vars mean_mean_serv_proctime mean_mean_waittime_imp mean_mean_thrutime_imp mean_mean_accuracy mean_mean_serv_thrurate
keep DQ `mean_mean_nonlog_vars'
gen type = 1
foreach mean_mean_nonlog_var of local mean_mean_nonlog_vars {
	replace `mean_mean_nonlog_var' = round(`mean_mean_nonlog_var', 0.01)
	local varnewname = substr("`mean_mean_nonlog_var'", 11, .)
	rename `mean_mean_nonlog_var' `varnewname'
}
save `mean_mean_nonlog'
restore

** mean_mean (log)
preserve
tempfile mean_mean_log
local mean_mean_log_vars mean_ln_mean_serv_proctime mean_ln_mean_waittime_imp mean_ln_mean_thrutime_imp mean_ln_mean_accuracy mean_ln_mean_serv_thrurate
keep DQ `mean_mean_log_vars'
gen type = 2
foreach mean_mean_log_var of local mean_mean_log_vars {
	replace `mean_mean_log_var' = round(`mean_mean_log_var', 0.01)
	local varnewname = substr("`mean_mean_log_var'", 14, .)
	rename `mean_mean_log_var' `varnewname'
}
save `mean_mean_log'
restore

** med_mean (nonlog)
preserve
tempfile med_mean_nonlog
local med_mean_nonlog_vars med_mean_serv_proctime med_mean_waittime_imp med_mean_thrutime_imp med_mean_accuracy med_mean_serv_thrurate
keep DQ `med_mean_nonlog_vars'
gen type = 3
foreach med_mean_nonlog_var of local med_mean_nonlog_vars {
	replace `med_mean_nonlog_var' = round(`med_mean_nonlog_var', 0.01)
	local varnewname = substr("`med_mean_nonlog_var'", 10, .)
	rename `med_mean_nonlog_var' `varnewname'
}
save `med_mean_nonlog'
restore

** med_mean (log)
preserve
tempfile med_mean_log
local med_mean_log_vars med_ln_mean_serv_proctime med_ln_mean_waittime_imp med_ln_mean_thrutime_imp med_ln_mean_accuracy med_ln_mean_serv_thrurate
keep DQ `med_mean_log_vars'
gen type = 4
foreach med_mean_log_var of local med_mean_log_vars {
	replace `med_mean_log_var' = round(`med_mean_log_var', 0.01)
	local varnewname = substr("`med_mean_log_var'", 13, .)
	rename `med_mean_log_var' `varnewname'
}
save `med_mean_log'
restore

** mean_med (nonlog)
preserve
tempfile mean_med_nonlog
local mean_med_nonlog_vars mean_med_serv_proctime mean_med_waittime_imp mean_med_thrutime_imp mean_med_accuracy mean_med_serv_thrurate
keep DQ `mean_med_nonlog_vars'
gen type = 5
foreach mean_med_nonlog_var of local mean_med_nonlog_vars {
	replace `mean_med_nonlog_var' = round(`mean_med_nonlog_var', 0.01)
	local varnewname = substr("`mean_med_nonlog_var'", 10, .)
	rename `mean_med_nonlog_var' `varnewname'
}
save `mean_med_nonlog'
restore

** mean_med (log)
preserve
tempfile mean_med_log
local mean_med_log_vars mean_ln_med_serv_proctime mean_ln_med_waittime_imp mean_ln_med_thrutime_imp mean_ln_med_accuracy mean_ln_med_serv_thrurate
keep DQ `mean_med_log_vars'
gen type = 6
foreach mean_med_log_var of local mean_med_log_vars {
	replace `mean_med_log_var' = round(`mean_med_log_var', 0.01)
	local varnewname = substr("`mean_med_log_var'", 13, .)
	rename `mean_med_log_var' `varnewname'
}
save `mean_med_log'
restore

** med_med (nonlog)
preserve
tempfile med_med_nonlog
local med_med_nonlog_vars med_med_serv_proctime med_med_waittime_imp med_med_thrutime_imp med_med_accuracy med_med_serv_thrurate
keep DQ `med_med_nonlog_vars'
gen type = 7
foreach med_med_nonlog_var of local med_med_nonlog_vars {
	replace `med_med_nonlog_var' = round(`med_med_nonlog_var', 0.01)
	local varnewname = substr("`med_med_nonlog_var'", 9, .)
	rename `med_med_nonlog_var' `varnewname'
}
save `med_med_nonlog'
restore

** med_med (log)
preserve
tempfile med_med_log
local med_med_log_vars med_ln_med_serv_proctime med_ln_med_waittime_imp med_ln_med_thrutime_imp med_ln_med_accuracy med_ln_med_serv_thrurate
keep DQ `med_med_log_vars'
gen type = 8
foreach med_med_log_var of local med_med_log_vars {
	replace `med_med_log_var' = round(`med_med_log_var', 0.01)
	local varnewname = substr("`med_med_log_var'", 12, .)
	rename `med_med_log_var' `varnewname'
}
save `med_med_log'
restore


*Combine 8 data sets above
use `mean_mean_nonlog', clear
append using `mean_mean_log'
append using `med_mean_nonlog'
append using `med_mean_log'
append using `mean_med_nonlog'
append using `mean_med_log'
append using `med_med_nonlog'
append using `med_med_log'

label variable serv_proctime "serv_proctime"
label variable waittime_imp "waittime_imp"
label variable thrutime_imp "thrutime_imp"
label variable accuracy "accuracy"
label variable serv_thrurate "serv_thrurate"
label variable type "type"
label define type_defs 1 "mean across subjects, mean within subjects (non-logged)" 2 "mean across subjects, mean within subjects (logged)" 3 "median across subjects, mean within subjects (non-logged)" 4 "median across subjects, mean within subjects (logged)" 5 "mean across subjects, median within subjects (non-logged)" 6 "mean across subjects, median within subjects (logged)" 7 "median across subjects, median within subjects (non-logged)" 8 "median across subjects, median within subjects (logged)"
label values type type_defs

save "$Data/Qualtrics Data/MedRoutine/Processed Data/within_across/MedRoutine_analysis_subject_20220919_perform_DVs.dta", replace

********************************************************************************
*2-2) Customer orientation summary statistics
********************************************************************************
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_subject_20220919.dta", clear

**Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

**Limit analysis to session 2 data
keep if session==2

*Calculate mean
collapse (mean) mean_COq_fbs=COq_fbs mean_COs_fbs=COs_fbs mean_QLdiff_all_perc=QLdiff_all_perc, by(DQ)
local CO_vars mean_COq_fbs mean_COs_fbs mean_QLdiff_all_perc
foreach CO_var of local CO_vars {
	replace `CO_var' = round(`CO_var', 0.01)
}

save "$Data/Qualtrics Data/MedRoutine/Processed Data/within_across/MedRoutine_analysis_subject_20220919_CO_DVs.dta", replace


**********************************************************
*3) Robust regressions (R3.10)
**********************************************************

*********************************************************************************************
* Installation Instructions:

* Implementing robust regressions needs to install a Stata command: robreg
* robreg provides a number of robust estimators for linear regression models. Among them are 
* the high breakdown-point and high efficiency MM estimator, the Huber and bisquare M estimator, 
* the S estimator, as well as quantile regression, each supporting robust standard errors based 
* on influence functions. Furthermore, basic implementations of LMS/LQS (least median/quantile
* of squares) and LTS (least trimmed squares) are provided.

*********************************************************************************************

*********************************************************************************************
* The impact of queue configuration on performance (robust regressions)
*********************************************************************************************

use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

*Limit analysis to session 2 data
keep if session==2

*Declare data to be panel data
xtset subject_id caseorder_sys2 

*Regressions (logged DVs)
bootstrap _b, reps($repnum) seed($seednum): robreg m ln_serv_proctime DQ, biweight
outreg2 using "$Output/Tables/MedRoutine/final/robust_regression_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Logged", "processing", "time") addtext(Model, `e(model)') dec(3) replace
bootstrap _b, reps($repnum) seed($seednum): robreg m accuracy DQ, biweight
outreg2 using "$Output/Tables/MedRoutine/final/robust_regression_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Percent", "correct") addtext(Model, `e(model)') dec(3) append
bootstrap _b, reps($repnum) seed($seednum): robreg m ln_serv_waittime_imp DQ, biweight
outreg2 using "$Output/Tables/MedRoutine/final/robust_regression_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Logged wait", "time") addtext(Model, `e(model)') dec(3) append
bootstrap _b, reps($repnum) seed($seednum): robreg m ln_serv_thrutime_imp DQ, biweight
outreg2 using "$Output/Tables/MedRoutine/final/robust_regression_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Logged", "througput", "time") addtext(Model, `e(model)') dec(3) append

keep if server_id == 3
keep if !missing(cs)
bysort subject_id cs: keep if _n == 1
bootstrap _b, reps($repnum) seed($seednum): robreg m serv_thrurate DQ, biweight
outreg2 using "$Output/Tables/MedRoutine/final/robust_regression_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Throughput", "rate") addtext(Model, `e(model)') dec(3) append


********************************************************************************
*4) Impact of queue configuration on variability of processing time (R3.11)
********************************************************************************

use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

*Limit analysis to session 2 data
keep if session==2

*Declare data to be panel data
xtset subject_id caseorder_sys2 

*Variability of processing time as metrics of interest: cv (coefficient of variation) and sd
bysort subject_id: egen proctime_mean_be = mean(serv_proctime)
bysort subject_id: egen proctime_sd_be = sd(serv_proctime)
bysort subject_id: gen proctime_cv_be = proctime_sd_be / proctime_mean_be

*Variability of processing time as metrics of interest: distance between each data and the mean, z-score
** z-score at the participant-level
bysort subject_id: gen proctime_z_be = (serv_proctime-proctime_mean_be) / proctime_sd_be
bysort subject_id: egen proctime_z_be_mean = mean(proctime_z_be)

** z-score at the case-level
egen proctime_mean = mean(serv_proctime)
egen proctime_sd = sd(serv_proctime)
gen proctime_z = (serv_proctime - proctime_mean) / proctime_sd

*Regressions (be model)
preserve 
bysort subject_id: keep if _n == 1

xtreg proctime_sd_be DQ, be vce(bootstrap, reps($repnum) seed($seednum))
outreg2 using "$Output/Tables/MedRoutine/final/performance_variability_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Processing time", "Standard Deviation") addtext(Model, `e(model)') dec(3) replace
xtreg proctime_cv_be DQ, be vce(bootstrap, reps($repnum) seed($seednum))
outreg2 using "$Output/Tables/MedRoutine/final/performance_variability_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Processing time", "Coefficient of", "Variation") addtext(Model, `e(model)') dec(3) append
xtreg proctime_z_be_mean DQ, be vce(bootstrap, reps($repnum) seed($seednum))
outreg2 using "$Output/Tables/MedRoutine/final/performance_variability_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Processing time", "Z-score", "participant-level") addtext(Model, `e(model)') dec(3) append

restore

*Regressions (re model)
xtreg proctime_z DQ, re vce(bootstrap, reps($repnum) seed($seednum))
outreg2 using "$Output/Tables/MedRoutine/final/performance_variability_20220922.doc", label word alpha(0.001, 0.01, 0.05, 0.10) symbol(***, **, *, +) ctitle("Processing time", "Z-score", "case-level") addtext(Model, `e(model)') dec(3) append

xtset, clear



********************************************************************************
*5) Mediation re: impact of queue on performance
/*
    This section aims to provide robustness tests for the mediation analysis in
the paper. There are two parts:
    
	1. Calculate the correlation between error terms
	2. Causal Mediation Analysis
*/
********************************************************************************

/* 1. Calculate the correlation between error terms

   Calculate the correlation between the error for the mediation model, and the
   error for the outcome model. We study two mediators, respectively.
*/
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

*Limit analysis to session 2 data
keep if session==2

*Declare data to be panel data
xtset subject_id caseorder_sys2 

*Keep only subjects
keep if !missing(ln_serv_proctime) /* Only keep subjects */

* QLdiff_all_perc
bootstrap, reps(`repnum') seed(`seednum'): regress QLdiff_all_perc DQ
predict M1_error, residuals

bootstrap, reps(`repnum') seed(`seednum'): regress ln_serv_proctime QLdiff_all_perc DQ
predict YM1_error, residuals

correlate M1_error YM1_error

* COq_fbs
bootstrap, reps(`repnum') seed(`seednum'): regress COq_fbs DQ
predict M2_error, residuals

bootstrap, reps(`repnum') seed(`seednum'): regress ln_serv_proctime COq_fbs DQ
predict YM2_error, residuals

correlate M2_error YM2_error



/* 2. Causal Mediation Analysis
   We use medeff and medsens commands contained in the mediation package to 
implement the procesures described in Imai, Keele, and Tingley (2010a) and Imai,
Keele, and Yamamoto (2010c) 
   
   There are two parts:
   A. Mediation Analysis : using medeff command
   B. Sensitivity Analysis: using medsens command to analyze data under the 
      sequential ignorability assumption.
   
   Note:
   The medsens command doesn't support the "seed()" option.
*/
* QLdiff_all_perc
medeff (regress QLdiff_all_perc DQ) (regress ln_serv_proctime QLdiff_all_perc DQ), treat(DQ) mediate(QLdiff_all_perc) sims($repnum) seed($seednum)

medsens (regress QLdiff_all_perc DQ) (regress ln_serv_proctime QLdiff_all_perc DQ), treat(DQ) mediate(QLdiff_all_perc) sims($repnum)

twoway (rarea _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14)) ///
       (line _med_delta0 _med_rho, lcolor(black) lpattern(dash) ///
	   ytitle("ACME") xtitle("Sensitivity parameter: {&rho}") title("ACME({&rho})") legend(off) xlabel(-1(.5)1) ylabel(-.2(.1).2))
graph export "$Output/Graphs/MedRoutine/final/QLdiff_all_perc_sens_20220922.png", as(png) replace


* COq_fbs
medeff (regress COq_fbs DQ) (regress ln_serv_proctime COq_fbs DQ), treat(DQ) mediate(COq_fbs) sims($repnum) seed($seednum)

medsens (regress COq_fbs DQ) (regress ln_serv_proctime COq_fbs DQ), treat(DQ) mediate(COq_fbs) sims($repnum) 

twoway (rarea _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14)) ///
       (line _med_delta0 _med_rho, lcolor(black) lpattern(dash) ///
	   ytitle("ACME") xtitle("Sensitivity parameter: {&rho}") title("ACME({&rho})") legend(off) xlabel(-1(.5)1) ylabel(-.2(.1).2))
graph export "$Output/Graphs/MedRoutine/final/COq_fbs_sens_20220922.png", as(png) replace



log close
*EOF
