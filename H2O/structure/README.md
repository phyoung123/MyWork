# 不同密度结构的准备
利用playmol来构建不同密度下的H<sub>2</sub>O的初始构型。然后利用该构型用VASP的ML-MD跑平衡获取结构，并重新做单点计算。
playmol 运行命令：
```python
playmol tip4p.playmol
```
输出lmp, pdb, xml, xyz等格式的结构文件， 然后用ovito打开，删掉鬼原子M，最后导出为POSCAR即可。