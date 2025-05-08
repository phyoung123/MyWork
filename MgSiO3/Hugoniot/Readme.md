# MgSiO<sub>3</sub> 冲击加载过程中的相变
## 1. 泛函测试
分别用PBE和LDA优化布里奇曼石(Pbnm)的原胞，得到0压下的晶格常数与实验对比(Earth and Planetary Science Letters 224 (2004) 241-248)，
分别基于PBE和LDA优化晶格，发现LDA得到的晶胞参数和体积跟实验值更接近，所以整个计算过程使用LDA泛函。

## 2. NEP势的构建
之前的尝试训练全部都是基于P21c的初始结构来的，现在考虑到P21c的复杂性，我直接用Pbca作为初始结构进行冲击加载模拟。
**新开始的文件夹位于 /enstatite/Pbca**
初始训练集准备4种结构：Pbca，pv，ppv和liquid
所需要覆盖的P-T范围在  `初始MD的P-T范围.xlsx`里面查看
基于之前跑的一部分AIMD，直接拿过来用，300-3000K下面包含0,5,10,20,50,100GPa的AIMD以及对应的单点计算。
然后是基于之前的nep.txt势函数跑NEP-MD，覆盖`初始MD的P-T范围.xlsx`里面所指定的P-T范围，这个nep势是来自`P21c/train-nep/run_md/train_add_12km_x_no_lmp_msst/run_md/train_add_14_15km_x/run_md/train_add_11_13_15-zbl-1.2`的结果