cd /Users/nooshinnejati/Downloads/
import delimited my_data_out.csv, clear
//////
//save my_data_out.dta
use my_data_out.dta, clear
//8,185
contract projectgeographicdistrict
//range: 1~32
contract projectbuildingidentifier
//1,196
contract projectschoolname
//1,483
contract projecttype
//20
contract projectdescription
//1,363
contract projectphasename
//9 (1 null)
contract projectstatusname
//3
sort projectphaseactualenddate
//keep in 1
gen date2 = date(projectphaseactualstartdate, "MDY") if projectphaseactualstartdate!="PNS"
format date2 %d
ren date2 StartDate

gen date2 = date(projectphaseplannedenddate, "MDY") if projectphaseplannedenddate!="PNS"
format date2 %d
ren date2 PlannedEndDate

gen date2 = date(projectphaseactualenddate, "MDY") if projectphaseactualenddate!="PNS"
format date2 %d
ren date2 ActualEndDate

//save my_data_out_MOD.dta, replace
use my_data_out_MOD.dta, clear
//8,185

sort projectbudgetamount
destring projectbudgetamount, generate(myBudgetAmount) force

order v1 StartDate PlannedEndDate ActualEndDate myBudgetAmount finalestimateofactualcoststhroug totalphaseactualspendingamount

sort v1

gen End_Delay= ActualEndDate - PlannedEndDate
order End_Delay
sort StartDate
//12sep2003~28dec2017
sort PlannedEndDate
//12sep2003~12aug2022
sort End_Delay
//-346~1431: Deviation from the plan
sum End_Delay, detail
histogram End_Delay, freq
gen Check=ActualEndDate-StartDate
sort Check
//0~3,702: Actual length of the project

order projectstatusname
sort projectstatusname ActualEndDate
sort projectstatusname totalphaseactualspendingamount

gen BudgetDev=totalphaseactualspendingamount - myBudgetAmount
order BudgetDev
sort BudgetDev
//-101,000,000~13,744,850

////////////// Multivariate analysis
corr BudgetDev End_Delay if projectstatusname=="Complete"

order projectstatusname finalestimateofactualcoststhroug myBudgetAmount

sort totalphaseactualspendingamount

order StartDate myBudgetAmount ActualEndDate finalestimateofactualcoststhroug totalphaseactualspendingamount 



///////////// Modeling
//// 1) predicting the over-budgeting

//// Training (completed projects)
gen ProjectLength= ActualEndDate-StartDate if projectstatusname=="Complete"
order projectstatusname ProjectLength
gen Ac_per_Day=  finalestimateofactualcoststhroug/ProjectLength if projectstatusname=="Complete"
gen Es_per_Day=  totalphaseactualspendingamount/ProjectLength if projectstatusname=="Complete"
order Ac_per_Day Es_per_Day

///// Test (In-progess projects)

replace ProjectLength= 21184-StartDate if projectstatusname=="In-Progress"

replace Ac_per_Day=  totalphaseactualspendingamount/ProjectLength if projectstatusname=="In-Progress"

/// training
regress Es_per_Day Ac_per_Day if projectstatusname=="Complete"


encode projecttype, gen(projecttypeN)
regress Es_per_Day Ac_per_Day projecttypeN projecttypeN#c.Ac_per_Day if projectstatusname=="Complete"

// test
predict New_Es_per_Day

order New_Es_per_Day Es_per_Day projectstatusname


gen New_es_exp=(PlannedEndDate-21184)*New_Es_per_Day if projectstatusname=="In-Progress"

gen New_es_over_bdgt=New_es_exp-(myBudgetAmount-totalphaseactualspendingamount) if projectstatusname=="In-Progress"

order New_es_over_bdgt
sort projectstatusname New_es_over_bdgt











