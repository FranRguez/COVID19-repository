* Stata COVID19 Repository (https://github.com/FranRguez/Stata-COVID19-repository)
* Author: Francisco Rodriguez Cabrera, MD MPH
* Resident in Public Health
* Spanish National Center of Epidemiology
* Contact: fdrodriguez@isciii.es


* Escribir el directorio donde está la base de datos a analizar, ya seleccionado por islas.
cd "C:\Users\Alice\Desktop\Epi_Canarias\informesAutomáticos"

* Fecha de actualización hoy.
local fechaactualizacion : di %tdDD\NN\CCYY daily("$S_DATE", "DMY")


* Preparar datos resto de España
import delimited "https://covid19.isciii.es/resources/serie_historica_acumulados.csv", clear
gen fecha_mod=date(fecha, "DMY")
format %tdDD/NN/CCYY fecha_mod
collapse (sum) casos, by(fecha_mod ccaa)

* Elimino 2 últimas filas (que tiene observaciones escritas) y posibles datos sin CCAA.
drop if ccaa=="" | _n>=_N-1
* Coger los valores de la variable ccaa

* Se definió momento de transmisión comunitaria el momento en el cual tuvieron 10 casos.

drop if casos<10
bysort ccaa (fecha_mod): gen diadeepidemia=_n
rename casos casos_totalsp


* Elimino fechas no rellenadas.
drop if fecha_mod==.

grstyle clear
grstyle init
grstyle set imesh, horizontal
* No legend this time.
grstyle set legend 2, nobox
grstyle linewidth plineplot 0.3
grstyle set color Set2, n(8)

 
 
 twoway line casos_totalsp diadeepidemia if ccaa!="CN" | ccaa!="MD", yla(10 50 100 500 1000 5000 10000 50000 100000, labsize(2.5)) yscale(log range(10 100000)) color(white*1) xla(0 (10) 50, labsize(2.5)) ||  ///
  function y=2^(x+5/2), range(1 10) lpattern(shortdash) color("215 25 28*1") text(7000 7 "Duplicación de casos cada día", color(black) size(2)) || ///
  function y=2^(x/2+5/1.667), range(1 25) lpattern(shortdash) color("253 174 97*2") text(50000 25 "... cada 2 días", color(black) size(2) orient(horizontal))  ||  /// 
  function y=2^(x/3+5/1.6), range(1 40) lpattern(shortdash) color("171 217 233*3")  text(100000 40 "... cada 3 días", color(black) size(2) orient(horizontal))  || ///
  function y=2^(x/4+5/1.5), range(1 50) lpattern(shortdash) color("black*1")  text(65000 50 "... cada 4 días", color(black) size(2))  || ///
  function y=2^(x/5+5/1.5), range(1 50) lpattern(shortdash) color("0 136 55*1")  text(14000 49 "... cada 5 días", color(black) size(2))  /// 
  xtitle("Día de epidemia (desde ≥10 casos)", size(small))   caption("Datos del Centro Nacional de Epidemiología. Extraídos el `fechaactualizacion'", size(vsmall)position(6))  ///
  legend(order(8 "Cataluña"  9 "Andalucía"  7 "Canarias"  )) /// 
  ytitle("Casos confirmados (escala logarítmica)", size(small)) || ///
  line casos_totalsp diadeepidemia if ccaa=="CN", lwidth(medthick) color(dkorange*1) || ///
  line casos_totalsp diadeepidemia if ccaa=="CT", lwidth(medthick) color(ltblue*1.5) || ///
  line casos_totalsp diadeepidemia if ccaa=="AN", lwidth(medthick) color(green*0.6) xsize(1.2) ysize(1)

  
 

 graph export "Dataviz\COVID19_curvalogaritmica_referencias.png", width(1500	) replace
 




