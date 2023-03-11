// Run scripts for the Queueing project

// Setup ---------------------------------------------------------------
// ---------------------------------------------------------------------

version 17.0
clear all
macro drop _all
set more off
set varabbrev off
set scheme white_tableau
capture log close

// Directories ---------------------------------------------------------
// To replicate on another computer simply uncomment the following lines
// by removing // and change the path:
// global main "/path/to/replication/folder"

if "$main"=="" {
	if "`c(username)'" == "aaronxiao" { // Bolun's Mac laptop
		global main "/Users/aaronxiao/Dropbox/Queueing"
	}
	else if "`c(username)'" == "Others" { // Others' PC laptop
	    global main "C:/Dropbox/Queueing/other_files"
		
	}
	else { // display as error 
	    display as error "User not recognized."
		display as error "Specify global main in analysis_run.do."
		exit 198 // stop the code so the user sees the error
		
	}
}

// Create globals for each subdirectory 
local subdirectories              ///
      Data                        ///
	  Documentation               ///
	  dofiles                     ///
	  Paper                       ///
	  Output                      ///
	  "Mediation Analysis"        ///
	  "Response to Reviewers"
	  
foreach folder of local subdirectories {
	cap mkdir "$main/`folder'" // Create folder if it doesn't exist already
	global `folder' "$main/`folder'"
}

// Create globals for each data subdirectory
local data_subdirectories         ///
      MedRoutine                  ///
	  TurkMD                      ///
	  Study3

foreach data_folder of local data_subdirectories {
	cap mkdir "$Data/Qualtrics Data/`data_folder'" 
	cap mkdir "$Data/Qualtrics Data/`data_folder'/Processed Data"
}

// Create the global for documentation subdirectory
cap mkdir "$Documentation/Relevant Materials"

// Create globals for each dofile subdirectory
local dofile_subdirectories      ///
      Study3                     ///
	  "Study 1 (MedRoutine)"     ///
	  "Study 2 (TurkMD)"         

foreach dofile_folder of local dofile_subdirectories {
	cap mkdir "$dofiles/`dofile_folder'"
	cap mkdir "$dofiles/`dofile_folder'/Archive"
}

// Create the global for each output subdirectory
local output_subdirectories      ///
      Graphs                     ///
	  Tables                     ///
	  Logs             

local output_sub2directories     ///
	      MedRoutine             ///
		  TurkMD                 ///
		  Study3       	  
	  
foreach output_folder of local output_subdirectories {
	cap mkdir "$Output/`output_folder'"
	global `output_folder' "$Output/`output_folder'"
	foreach output_subfolder of local output_sub2directories {
		cap mkdir "$Output/`output_folder'/`output_subfolder'"		
	}	
}

/* // The following code ensures that all user-written ado files needed for
//  the project are saved within the project directory, not elsewhere.
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
    if `"`1'"'!="BASE" cap adopath - `"`1'"'
    macro shift
}
adopath ++ "$scripts/programs"
*/

// Preliminaries -------------------------------------------------------------
// Control which script run
local 2_MedRoutine_summ_20220929_BX = 1
local 2_TurkMD_summ_20220929_BX = 1
local 2_Study3_summ_20220929_BX = 1
local 4_MedRoutine_posthoc_20220929_BX = 1
local 4_TurkMD_posthoc_20220929_BX = 1
local 4_Study3_posthoc_20220922_BX = 1


// Run Scripts (the latest version) ---------------------------------------------------------------
if (`2_MedRoutine_summ_20220929_BX' == 1) do "$dofiles/Study 1 (MedRoutine)/2_MedRoutine_summ_20220929_BX.do"
if (`2_TurkMD_summ_20220929_BX' == 1) do "$dofiles/Study 2 (TurkMD)/2_TurkMD_summ_20220929_BX.do"
if (`2_Study3_summ_20220929_BX' == 1) do "$dofiles/Study3/2_Study3_summ_20220929_BX.do"
if (`4_MedRoutine_posthoc_20220929_BX' == 1) do "$dofiles/Study 1 (MedRoutine)/4_MedRoutine_posthoc_20220929_BX.do"
if (`4_TurkMD_posthoc_20220929_BX' == 1) do "$dofiles/Study 2 (TurkMD)/4_TurkMD_posthoc_20220929_BX.do"
if (`4_Study3_posthoc_20220922_BX' == 1) do "$dofiles/Study3/4_Study3_posthoc_20220922_BX.do"
