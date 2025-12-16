///对于无法运行的命令，可能是没有安装外部命令，首先运行ssc install 命令名，例如:ssc install reghdfe 或findit 命令名

///数据来源：中国城市统计年鉴、中国区域统计年鉴、中国统计年鉴
***变量定义
gen energye=超效率CCR
gen energyer=超效率SBM
gen lgdp=log( 地区生产总值万元 )
gen lpergdp=log( 人均地区生产总值元)
gen popud= 城镇常住人口万人/ 行政区域土地面积平方公里
gen stru1= 第二产业增加值占GDP比重
gen stru2= 第三产业增加值占GDP比重
gen lpopu1= 城镇常住人口万人
gen stru3= 第二产业从业人员比重
gen stru4= 第三产业从业人员比重
gen energyp= 电力煤气及水生产供应业从业人员数万人/ 年末单位从业人员数万人
gen industry1=log( 规模以上工业企业数个)
gen industry2=log( 规模以上工业总产值当年价万元 )
gen fdi2=log( 外商投资企业工业总产值万元 )
gen fdi1=log( 外商投资企业数个 )
gen fdi3=log( 当年实际使用外资金额万美元 )
gen fiscalp= 地方财政一般预算内支出万元/ 地方财政一般预算内收入万元
gen edu1= 教育支出万元/ 地方财政一般预算内支出万元
gen tech1= 科学支出万元/ 地方财政一般预算内支出万元
gen fin1=log( 年末金融机构各项贷款余额万元)
gen fin2=log( 年末金融机构存款余额万元 )
gen edu2=log( 普通高等学校学校数所)
gen tech2=log( RD人员人)
gen tech3=log( RD内部经费支出万元 )
gen pantent=log( 发明专利授权数件)
gen dig1=log( 电信业务总量万元)
gen dig2=log( 移动电话年末用户数万户 )
gen eu1=log( 全年用电量万千瓦时)
gen eu2=log( 工业用电万千瓦时 )
gen eu3=log( 城镇生活消费用电万千瓦时 )
gen er1=log( 工业二氧化硫去除量吨)
gen er2=log( 工业烟尘去除量吨 )
gen er3=log( 生活污水处理率 )


***数据调用
use "C:\Users\lszcj\Desktop\论文\2.dta",clear

***描述性统计
outreg2 using 123.doc, replace sum(log) keep(energye policy lpergdp popud stru energyp industry edu tech fin dig eu er)
shellout using `"123.doc"' 

***均值差异检验
logout, save(Tab2_corr) word replace: ttable2 energye lpergdp popud stru energyp industry edu tech fin dig eu er, by(policy) 

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

***基准回归
reg energye policy,cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

reg energye policy lpergdp popud stru energyp industry edu tech fin dig eu er,cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

***稳健性检验
**缩尾处理
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
winsor2 energye lpergdp popud stru energyp industry edu tech fin dig eu er, cuts(1 99) replace
reghdfe energye policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

**缩短样本期（排除covid19影响）
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

**psm-did（倾向得分匹配双重差分）
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

**合成双重差分法
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
xtset citycode year
xtbalance ,range(2006 2021)
carryforward lpergdp popud stru energyp industry edu tech fin dig eu er ,replace
sdid energye citycode year policy , vce(bootstrap) seed(123) covariates( lpergdp popud stru energyp industry edu tech fin dig eu er  ) graph 

***机制检验
**绿色创新
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
reghdfe lgp policy lpergdp popud stru energyp industry edu tech fin dig eu er ,absorb(citycode year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'


**融资约束

use "C:\Users\lszcj\Desktop\论文\07_firm.dta", clear
 reghdfe FC指数 policy  lpergdp popud stru energyp industry edu tech fin dig eu er  ,absorb(stkcd year) cluster(citycode)
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

***异质性检验

**产业结构异质性
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
egen med=median(stru3)
gen group=1 if stru3>=med
replace group=0 if stru3<med
//按第二产业人数占比分组，第二产业人数多的group取值为1(工业型城市)，人数少的取值为0
reghdfe energye policy  lpergdp popud stru energyp industry edu tech fin dig eu er if group==1,absorb(citycode year) cluster(citycode) 
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

reghdfe energye policy  lpergdp popud stru energyp industry edu tech fin dig eu er if group==0,absorb(citycode year) cluster(citycode) 
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'
///policy在group=1显著，group=0不显著。第二产业越发达的城市，新能源政策效果越好。这说明新能源政策更适用于工业型城市。

**技术水平异质性
use "C:\Users\lszcj\Desktop\论文\2.dta",clear
egen med=median(tech1)
gen group=1 if tech1>=med
replace group=0 if tech1<med

reghdfe energye policy  lpergdp popud stru energyp industry edu tech fin dig eu er if group==1,absorb(citycode year) cluster(citycode) 
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'

reghdfe energye policy  lpergdp popud stru energyp industry edu tech fin dig eu er if group==0,absorb(citycode year) cluster(citycode) 
outreg2 using 123.doc,replace  bdec(4) tdec(3) ctitle(y)
shellout using `"123.doc"'
///policy在group=1显著，group=0不显著。技术发达的城市，新能源政策效果越好。这说明新能源政策的效果依赖于城市的技术发展。

