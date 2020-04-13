* Stata COVID19 Repository (https://github.com/FranRguez/Stata-COVID19-repository)
* Author: Francisco Rodriguez Cabrera, MD MPH
* Resident in Public Health
* Spanish National Center of Epidemiology
* Contact: fdrodriguez@isciii.es

* Case fatality rate.

import excel "C:\Users\Alice\Desktop\Epi_Canarias\informesAutomáticos\do-fileFiguras\letalidadporsexo.xlsx", sheet("Hoja1") firstrow clear
destring, replace
gen row=_n

set scheme s1mono 

encode age, gen(age_num)

grstyle init
grstyle set plain, grid
grstyle set color Set2, opacity(60): p#markfill
grstyle set color Set2, opacity(0):  p#marklin
grstyle symbolsize p 2
grstyle set legend 2, nobox

twoway  rcap lowerci upperci age_num, vert  || ///
scatter proportion age_num if sex==1 || ///
scatter proportion age_num if sex==2, xla(-2 "<10" -1 "10-19" 0 "20-29" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80-89" 7 "≥90", labsize(3)) ///
ytitle("Case fatality rate (%)") xtitle("Age group (years)") ///
legend(order(3 "Men" 2 "Women" 1 "95% CI")) 


graph export "casefatalityrate.png", replace width(2000)


** Model 2

/*
twoway /// 
(rcap lowerci upperci  row, horizontal) /// code for 95% CI
(scatter row proportion if sex ==1, mcolor(red)) /// dot for group 1
(scatter row proportion if sex ==2, mcolor(blue)) /// dot for group 2
, legend(row(1) order(2 "legend 1" 3 "legend 2") pos(6)) /// legend at 6 o'clock position
ylabel(1.5 "Model A" 4.5 "Model B" 7.5 "Model C" 10.5 "Model D" 13.5 "Model E", angle(0) noticks) ///
/// note that the labels are 1.5, 4.5, etc so they are between rows 1&2, 4&5, etc.
/// also note that there is a space in between different rows by leaving out rows 3, 6, 9, and 12 
xlabel(.95 " " 1 "1.0" 1.1 "1.1" 1.2 "1.2" 1.3 "1.3" 1.4 "1.4" 1.5 "1.5" 1.6 " ", angle(0)) /// no 1.6 label
title("Title") ///
xtitle("X axis") /// 
ytitle("Y axis") /// 
yscale(reverse) /// y axis is flipped
xline(1.0, lpattern(dash) lcolor(gs8)) ///
/// aspect (next line) is how tall or wide the figure is
aspect(.5)

graph export "dot and 95 percent ci figure.png", replace width(2000)
//graph export "dot and 95 percent ci figure.tif", replace width(2000)
