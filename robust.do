
***平行趋势检验
gen event=year-2014
forvalues i=8(-1)1{
  gen pre`i'=(event==-`i'& treat==1)
}
gen current=(event==0 & treat==1)
forvalues i=1(1)8{
  gen post`i'=(event==`i'& treat==1)
}
drop pre1
reghdfe energye  pre* current post* lpergdp popud stru energyp industry edu tech fin dig eu er,absorb(citycode year) cluster(citycode)
est sto reg
coefplot reg,keep(pre* current post*) vertical recast(connect) yline(0) xline(8,lp(dash)) levels(90)


***稳健性检验
**缩尾处理
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
winsor2 energye lpergdp popud stru energyp industry edu tech fin dig eu er, cuts(1 99) replace
reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**缩短样本期（排除新馆影响）
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
drop if year==2020
drop if year==2021
reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**剔除直辖市
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
drop if citycode==110000
drop if citycode==310000
drop if citycode==120000
drop if citycode==500000
reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**替换被解释变量
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
reghdfe energyer policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**psm-did
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1
psmatch2 treat lpergdp popud stru energyp industry edu tech fin dig eu er  , outcome( energye) logit neighbor(2) ties common
gen common=_support
drop if common==0
reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**安慰剂检验
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
set seed 223 
  forvalue i = 1/1000 {
          use "C:\Users\lszcj\Desktop\论文\2.dta",clear
          preserve
          keep if year   == 2006
          gen  randomvar = runiform()
          sort randomvar
          keep if citycode in 1/33
          keep    citycode
          save    id_random.dta, replace  
      restore

      merge m:1 citycode using id_random.dta  
      gen  treat1  = (_merge == 3)
      gen  did    = treat1 * period
      qui  reghdfe energye did lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
      gen  b_did  = _b[did]   
      gen  se_did = _se[did]  
      keep b_did se_did
      duplicates drop b_did, force
      save placebo_`i'.dta, replace
      }
  erase id_random.dta

  use placebo_1.dta, clear
  forvalue k = 2/1000 {
      append using  placebo_`k'.dta
      erase  placebo_`k'.dta
      }
gen tvalue = b_did / se_did
///
kdensity b_did

kdensity tvalue

**合成did
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
xtset citycode year
xtbalance ,range(2006 2021)
carryforward lpergdp popud stru energyp industry edu tech fin dig eu er ,replace
sdid energye citycode year policy , vce(bootstrap) seed(123) covariates( lpergdp popud stru energyp industry edu tech fin dig eu er  ) graph 
