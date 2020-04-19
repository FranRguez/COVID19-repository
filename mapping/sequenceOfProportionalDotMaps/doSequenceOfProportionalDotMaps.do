* Stata COVID19 Repository (https://github.com/FranRguez/Stata-COVID19-repository)
* Author: Francisco Rodriguez Cabrera, MD MPH
* Resident in Public Health
* Spanish National Center of Epidemiology
* Contact: fdrodriguez@isciii.es


* We want to create a daily sequence of maps. Let's first put our preferred directory.
cd "C:\Users\Alice\Desktop\Epi_Canarias"

* Obtain ECDC data
set excelxlsxlargefile on
local today : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
capture noi import excel "https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-`lastdatewithdata'.xlsx", firstrow case(lower) locale("unicode") clear

* If it does not work today's data (that's OK!) lets try the one before and so on, until you get it (or a week go by).
forvalues x=0(1)7 {
	if _rc!=0 {
		local lastdatewithdata : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")-`x'
		capture import excel "https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-`lastdatewithdata'.xlsx", firstrow case(lower) locale("unicode") clear
}

}

 * Let's adapt the data to what we want to represent.
replace countriesandterritories=subinstr(countriesandterritories,"_"," ",.)
replace countriesandterritories="Macedonia" if countriesandterritories=="North Macedonia"
 
* Keep European countries. 
keep if  countriesandterritories=="Norway" || countriesandterritories=="Albania" || countriesandterritories=="Bulgaria" || ///
countriesandterritories=="Kosovo" || countriesandterritories=="Serbia" || countriesandterritories=="Bosnia_and_Herzegovina" || ///
countriesandterritories=="Switzerland" ||countryterritorycode=="AUT" || countryterritorycode=="BEL" || countryterritorycode=="BGR" || ///
countryterritorycode=="HRV" || countryterritorycode=="CYP" || countriesandterritories =="Czechia" || countryterritorycode=="DNK" || ///
countryterritorycode=="EST" || countryterritorycode=="FIN" || countryterritorycode=="FRA" || countryterritorycode=="DEU" || ///
countryterritorycode=="GRC" || countryterritorycode=="HUN" || countryterritorycode=="IRL" || countryterritorycode=="ITA" || ///
countryterritorycode=="LVA" || countryterritorycode=="LTU" || countryterritorycode=="LUX" || countryterritorycode=="MLT" || ///
countryterritorycode=="NLD" || countryterritorycode=="POL" || countryterritorycode=="PRT" || countryterritorycode=="ROU" || ///
countryterritorycode=="SVK" || countryterritorycode=="SVN" || countryterritorycode=="ESP" || countryterritorycode=="SWE" || ///
countryterritorycode=="GBR"

* cases in ECDC are new cases, and we want to paint cumulative incidences.
bysort countriesandterritories (daterep): gen cumul_cases=sum(cases)

save resultadosecdc, replace

use resultadosecdc, clear
* Get the maps we want to represent. Freely available at https://tapiquen-sig.jimdofree.com/english-version/free-downloads/world/
shp2dta using "informesAutomáticos\do-fileFiguras\Mapeo mundo\World_Cities.shp", database(cities) coordinates(co_cities) genid(id2) replace
shp2dta using "informesAutomáticos\do-fileFiguras\Mapeo mundo\World_Lakes.shp", database(lakes) coordinates(co_lakes) genid(id3) replace
shp2dta using "informesAutomáticos\do-fileFiguras\Mapeo mundo\World_Hydrography.shp", database(hydrography) coordinates(co_hydrography) genid(id4) replace
shp2dta using "informesAutomáticos\do-fileFiguras\Mapeo mundo\World_Countries.shp", database(countries) coordinates(co_countries) genid(id) gencentroids(centroides) replace

use countries, clear
* Let's assign the column's name of ECDC's country and name them according to how ECDC does.
rename COUNTRY countriesandterritories
replace countriesandterritories="Czechia" if countriesandterritories=="Czech Republic"
save, replace



* Substitute how many days backwards you wanna get.
local daysbackwards=30
local datanumbers : di date("`lastdatewithdata'","YMD")


forvalues x=`daysbackwards'(-1)0 {
* Take data until yesterday (in normal conditions, last data available on ECDC's website).

use resultadosecdc, clear



* ECDC data does not include countries that had not notified any cases yet.
* I want to input 0 cases when there has been no notification yet. For that, I get all the countries that I had yesterday.
if `x'==`daysbackwards' {
	

	keep if daterep==`datanumbers'

	keep daterep countriesandterritories
	bysort countriesandterritories: gen secuencia=_n-1
	gen daterep_ready=daterep-secuencia
	format daterep_ready %tdDD/NN/CCYY
	keep countriesandterritories daterep_ready
	rename daterep_ready daterep
	save resultadosecdc_countries_dates, replace
	
	use resultadosecdc, clear
	merge m:m countriesandterritories daterep using resultadosecdc_countries_dates
	drop if daterep<`datanumbers'-`daysbackwards'
	replace cumul_cases=0 if cumul_cases==.
	save resultadosecdc, replace
}

* Take all the cases until that day
local gobackwards=`daysbackwards' - `x'
drop if daterep>(`datanumbers' - `gobackwards')


* Now, let's iterate backwards, daily.
local lastdataavailable_betterformat : di %tdDD\NN\CCYY daily("`lastdatewithdata'", "YMD")-`gobackwards'
di `lastdateavailable_betterformat'
	
collapse (max) cumul_cases (mean) popdata2018, by(countriesandterritories)
gen incidence=cumul_cases*100000/popdata2018
replace incidence=0 if incidence==.
save resultadosecdc_cases, replace



use countries, clear
merge 1:m countriesandterritories using resultadosecdc_cases
keep if _merge==3 | countriesandterritories=="Macedonia"
save COVID19_casemap, replace



if `x'<=`daysbackwards'	 {

	* Let's do a trick.
	replace popdata2018=0	
	replace incidence=int(incidence)
	spmap popdata2018 using co_countries,  id(id)	fcolor(gs10*0.1) legstyle(2) legend(off) ///
	osize(vthin) ocolor(gs8) graphregion(color(gs14)) title(`lastdataavailable_betterformat', size(7)) ///
	subtitle("Confirmed cases per 100,000 inhabitants") ///
	note("Spanish National Center of Epidemiology. Data from the European Centre for Disease Prevention and Control.", size(2.3)) ///
	point(data(COVID19_casemap) xcoord(x_centroides) ycoord(y_centroides) proportional(incidence) prange(0 500) psize(absolute) size(1.5) fcolor(ltblue*0.6) ocolor(black*0.8)) ///
	label(x(x_centroides) y(y_centroides) label(incidence) color(dknavy*0.8) size(*0.7))

	}
 graph export "informesAutomáticos\Dataviz\MapaCasos\COVID19_iter_world_`x'_cases.png", width(1600)  replace

	}


