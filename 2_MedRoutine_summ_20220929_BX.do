********************************************************************************************************************
*Date created: 9/20/2022
*Date modified: 9/29/2022
*Description: Summary statistics
********************************************************************************************************************
/*TABLE OF CONTENTS
** Setup
1) Case-level summary statistics
2) Subject-level summary statistics
3) Learning curve (Average processing time trend) & Quality (Accuracy) curve
*/

********************************************************************************************************************
**) Setup
********************************************************************************************************************
log using "$Logs/MedRoutine/2_summary_20220921_BX.txt", text replace

**********************************************************
*1) Case-level summary statistics
**********************************************************
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

local demographic_vars age female
local DV_case_vars serv_proctime accuracy waittime_imp thrutime_imp serv_thrurate waittime thrutime
local DV_subject_vars med_serv_proctime med_accuracy med_waittime_imp med_thrutime_imp med_serv_thrurate med_waittime med_thrutime 
local MV_vars COq_fbs COs_fbs QLdiff_all_perc
local MV_vars_me QLdiff_me QLdiff_me_perc 
local other_vars duration_m

iebaltab `DV_case_vars', grpvar(cs) total nottest feqtest std tblnonote tblnote(Post-exclusion. Data at case level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/case_postexcl_DVs_cs_20220921.xlsx") replace

iebaltab `DV_case_vars' if session==2, grpvar(cs) total nottest feqtest std tblnonote tblnote(Post-exclusion. Data at case level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/case_postexcl_DVs_cs2_20220921.xlsx") replace

iebaltab `DV_case_vars', grpvar(condition) total nottest feqtest std tblnonote tblnote(Post-exclusion. Data at case level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/case_postexcl_DVs_c_20220921.xlsx") replace


*Percent imputed
count if !missing(serv_proctime) & server_id==3 & session!=3
count if !missing(serv_waittime_imp) & server_id==3 & session!=3
count if !missing(serv_thrutime_imp) & server_id==3 & session!=3

**********************************************************
*2) Subject-level summary statistics
**********************************************************
use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_subject_20220919.dta", clear

iebaltab `demographic_vars', grpvar(condition) total onerow nottest feqtest std tblnonote tblnote(Pre-exclusion. Data at subject level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/subj_preexcl_demVs_20220921.xlsx") replace

*Implement exclusion criteria
drop if exclusion_keepip>0
unique subject_id, by(condition)

iebaltab `DV_subject_vars' `MV_vars' sessiontime, grpvar(cs) total nottest feqtest std tblnonote tblnote(Post-exclusion. Data at subject level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/subj_postexcl_DVsMVs_20220921.xlsx") replace 

iebaltab `DV_subject_vars' `MV_vars' sessiontime if session==2, grpvar(cs) total nottest feqtest std tblnonote tblnote(Post-exclusion. Data at subject level. ***, **, and * indicate significance at the 1, 5, and 10 percent levels.) save("$Tables/MedRoutine/final/subj_postexcl_DVsMVs2_20220921.xlsx") replace 

*Appendix C
ttest age, by(condition)
ttest female, by(condition)
unique subject_id, by(condition)

**********************************************************
*3) Learning curve (Average processing time trend) & Quality (Accuracy) curve
**********************************************************

*Using case percentile with no missing values

**Prep data
clear
set obs 100
seq pctile, from(1) to(100)
tempfile pctile_temp
save `pctile_temp'

use "$Data/Qualtrics Data/MedRoutine/MedRoutine_analysis_case_20220919.dta", clear
drop if exclusion_keepip>0
unique subject_id, by(condition)
keep if server_id==3
keep subject_id condition cs DtoP PtoD session DQ PQ serv_proctime accuracy caseorder_serv3 
drop if missing(subject_id)
drop if missing(serv_proctime)
drop if session == 3

egen casemax=max(caseorder_serv3) if !missing(caseorder_serv3), by(subject_id session)
bysort subject_id session: gen casemax_session1 = casemax if session == 1
replace casemax_session1 = 0 if missing(casemax_session1)
bysort subject_id: egen casemax_session1_copy = max(casemax_session1)
bysort subject_id: replace casemax = casemax - casemax_session1_copy if session == 2
bysort subject_id: replace caseorder_serv3 = caseorder_serv3 - casemax_session1_copy if session == 2
sort subject_id session caseorder_serv3
drop casemax_session1 casemax_session1_copy
rename caseorder_serv3 caseorder_serv3_session

bysort subject_id session: gen casepctile = caseorder_serv3_session/(casemax+1)*100
replace casepctile = round(casepctile, 1)

preserve
keep if session == 1
save "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_1.dta", replace
restore

preserve
keep if session == 2
save "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_2.dta", replace
restore

cd "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy"
local datas: dir . files "*.dta"
foreach data of local datas {
	drop _all
	use `data', clear
	
	append using `pctile_temp'
    replace casepctile=pctile if missing(subject_id) & missing(casepctile)
    fillin subject_id casepctile
    sort subject_id casepctile
    drop pctile	
	
	gen byte newcase_session=missing(caseorder_serv3_session)&!missing(caseorder_serv3_session[_n-1])
    replace newcase_session=1 if _n==1
    replace newcase_session=0 if newcase_session==1 & casemax[_n-1]==caseorder_serv3_session[_n-1] & !missing(casemax[_n-1]) & !missing(caseorder_serv3_session[_n-1])
    replace newcase_session=1 if subject_id!=subject_id[_n-1]
    gen spell_session=sum(newcase_session)
	
	foreach var in condition cs DtoP PtoD session DQ PQ serv_proctime accuracy caseorder_serv3_session casemax  {
		egen `var'_temp=mean(`var'), by(spell_session)
	    order `var'_temp, after(`var')
	    drop `var'
	    rename `var'_temp `var'		
	}

    drop _fillin	
	
	collapse (mean) mean_proctime=serv_proctime mean_accuracy=accuracy (sd) sd_proctime=serv_proctime sd_accuracy=accuracy (mean) casemax, by(casepctile)
    gen ci95la_proctime = mean_proctime - invttail(casemax-1, .025)*sd_proctime/sqrt(casemax)
    gen ci95ua_proctime = mean_proctime + invttail(casemax-1, .025)*sd_proctime/sqrt(casemax)
	gen ci95la_accuracy = mean_accuracy - invttail(casemax-1, .025)*sd_accuracy/sqrt(casemax)
    gen ci95ua_accuracy = mean_accuracy + invttail(casemax-1, .025)*sd_accuracy/sqrt(casemax)	
	
	save `data', replace
	
}

use "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_1.dta", clear
gen session = 1
save "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_1.dta", replace

use "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_2.dta", clear
gen session = 2
save "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_2.dta", replace

use "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_1.dta", clear
append using "$Data/Qualtrics Data/MedRoutine/Processed Data/learning_accuracy/MedRoutine_analysis_case_20220921_session_2.dta"
label define session_defs 1 "Experimental round 1" 2 "Experimental round 2"
label val session session_defs
keep if inlist(casepctile,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95)

**Learning effects trends across experimental round 1 & 2
twoway (line mean_proctime casepctile, by(session, note("") legend(off)) color(edkblue)) ///
       (rarea ci95ua_proctime ci95la_proctime casepctile, by(session) color(edkblue%30) ///
	   xlabel(0(20)100) ylabel(30(5)70, angle(0)) xtitle("Case percentile") ytitle("Average processing time (seconds)"))

graph export "$Graphs/MedRoutine/final/MedRoutine_learning_20220921.png", as(png) replace
	   
**Quality (accuracy) trends across experimental round 1 & 2
twoway (line mean_accuracy casepctile, by(session, note("") legend(off)) color(emerald)) ///
       (rarea ci95ua_accuracy ci95la_accuracy casepctile, by(session) color(emerald%30) ///
	   xlabel(0(20)100) ylabel(75(5)105, angle(0)) xtitle("Case percentile") ytitle("Average percent correct (%)"))

graph export "$Output/Graphs/MedRoutine/final/MedRoutine_accuracy_20220921.png", as(png) replace
	   
log close
*EOF
