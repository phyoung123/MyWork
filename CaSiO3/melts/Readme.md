
# 数据集构成
## 初始数据集
| Temperature | Pressure |        |         |         |         |          |          |
|-------------|----------|--------|---------|---------|---------|----------|----------|
| 2500K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar |          |          |
| 3000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 900kbar  |          |
| 4000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 1000kbar | 1300kbar |
| 5000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 1000kbar | 1400kbar |

## round-0
跑了这些温度压力下的`AIMD-NPT-20000`步， 舍弃前面`5000fs`，然后每隔`300`步抽一个结构做单点计算，将得到的数据训练一个粗糙的`nep.txt`势。**初始的数据集放在`0-vasp`里面。**

## round 1
估计各个体积比下的晶格常数，用`VASP-MD`后最接近的结构作为`NEP-MD`的`model.xyz`，用得到的`nep`势跑`2ns`的主动学习，此时用的已经是`nvt_bdp`系综了，因为`model.xyz`已经是不同体积比了。抽取`20`个结构重新做单点计算。**得到的结果放在了`1-active`里面。**
```python
from ase.io import read, write

atoms = read('CONTCAR-ovito-300kbar-3000K.vasp', format='vasp')
print(atoms.cell[0,0])
# atoms.cell[0] = [13.3109, 0, 0]
# atoms.cell[1] = [ 0,13.3109, 0]
# atoms.cell[2] = [ 0, 0,13.3109]
new_length = 11.12194768

new_cell = atoms.cell.copy()
new_cell[0] = [new_length, 0, 0 ]
new_cell[1] = [0, new_length, 0]
new_cell[2] = [0, 0, new_length]
atoms.set_cell(new_cell, scale_atoms=True)
atoms.wrap()

write("POSCAR-0.7V0.vasp", atoms, direct=True)
```

## round 2
鉴于上面的主动学习并没有使我的训练效果变好，我又增加了`VASP-AIMD`数据，并将抽取的结构做了微扰`perturb`，加入到数据集中重新训练，结果并没什么用，后来发现，`是因为有几个单点计算没有算收敛`, 现在GPUMD的tools里面将singleOUTCAR2xyz.sh的文件已经能够提示异常计算结果。也可用dpdata检查是否有异常计算结果（不收敛，或者任务异常中断导致未算完）。**相关的数据放在`2-SWSTU`里面。**

dpdata导出成dp的npy格式，即可检查：

用法： python vasp2deep.py < outcar_path >

```python
from dpdata import LabeledSystem, MultiSystems
import dpdata
from glob import glob
import sys, os

def find_outcar(start_path='.'):
    result = []
    for root, dirs, files in os.walk(start_path):
        if 'OUTCAR' in files:
            result.append(os.path.join(root, 'OUTCAR'))
    return result

file_list = find_outcar(start_path=sys.argv[1])
# print(file_list)
total_system=LabeledSystem()

for f in file_list:
    ls=LabeledSystem(f, fmt='vasp/outcar')
    total_system.append(ls)

total_system.shuffle()

split_num = int(len(total_system) * 1)      # should be convert to int
print(split_num)
total_system[:split_num].to_deepmd_npy('./data/training_set', set_size=2000)
total_system[:split_num].to_deepmd_raw('./data/training_set', set_size=2000)
# total_system[split_num:].to_deepmd_npy('./data/validation_set', set_size=500)
# total_system[split_num:].to_deepmd_raw('./data/validation_set', set_size=500)
```

**将那几个异常的踢出去以后，跑gpumd不再出现原子聚集的情况。**

### 失败的DFT计算
1-active--> 5000K ---> 10 kbar ---> perturb ---> 10000/18600

1-active--> 4000K ---> vasp/10kbar ---> 12/17

2-SWSTU---> 3000K ---> 1.2V0 ---> vasp --->8400/15800/27200

2-SWSTU---> 4000K--->10kbar ---> 1.1V0---> vasp ---> 8600

2-SWSTU---> 4000K--->10kbar --->1.2V0 ---> Perturb-add ---> 23000

2-SWSTU---> 5000K ---> 1.1V0 ---> Perturb ---> vasp ---> 17500

2-SWSTU---> 5000K ---> 1.4V0 ---> vasp ---> 8900/15050/19550/26600

然后训练了一个势函数。`tran-new/all/new-dataset/`

## round 3
用上一步得到的`nep.txt`在各个温度-体积比下跑`5ns`主动学习抽样，抽了`20`个结构（好像某个体积少了一个），发现除了`5000K`外，其他三个温度的对角线图已经比较满意了，但还是做了以下计算

将上次训练的`train.xyz`按照9:1拆分成新的`train.xyz`和`test.xyz`，然后主动学习的`2500K`，`3000K`， `4000K`， `5000K`的数据全部加入到新的训练集中进行训练。原来的数据集中有 `4878` 帧构型，加入了`759`帧。所以现在新的`train.xyz`包含`5149`帧结构，`test.xyz`中包含`488`帧。

**DFT数据集放在超算上的路径是：GPUMD_new/dataset-deep/3-active**

**DFT数据集放在本地机上的路径是：train-new/all/new-dataset/run_md**

**本地机训练相关路径：train-new/all/new-dataset/run_md/train-add**

## round 4
将上一步训练得到的势函数`nep.txt`用于主动学习，在各个温度-体积比下跑更长的`10ns`的主动学习抽样，这次每个轨迹只抽了10个结构，发现已经符合得非常好了，所以最后一次主动学习的数据并没有加入到训练集中去重新训练，而是`round 3`得到的势函数就已经是稳定的势函数了，可以用它来跑性质计算了。

## round 5
鉴于 `round 4`的结果其实并没有达到最好，后期处理`rdf`时发现还是有偏差，所以我还是准备将 `round 4`的DFT加入到训练集中继续训练。`round 4`中的`10ns`NEP-MD本来只输出了`100`个结构，`round 4`只从`9-99`间隔`10`提取了`10`个结构。这`10`个结构是在本地机上计算的，路径：`train-new/all/new-dataset/run_md/train-add/run_md`。在本轮中，我还是将上述的`10`个结构加入训练集，并且重新加入了从`5-95`，间隔`10`个结构，总共`10`个结构加入训练集，并且还施加了一点微扰，但不是全部微扰。这些是在超算上计算的。但是准备利用`pynep`将原来的一些数据给他踢出去，但是将主动学习的结构全保留。

失败的DFT计算：4-active-10ns/5000/1.4/89

4-active-10ns/4000/1.4-perturb/55

**相关的DFT数据放在超算上的路径是： GPUMD_new/dataset-deep/4-active**

在用`pynep`挑选之前的结构数量分布：

先用 `grep_rmse_max.py` 将力大于`25A`的结构踢出去，将NEPdataset.xyz保存成ase_out.xyz。然后再用pynep挑选。

| 数据集 | 0-vasp  | 1-active  | 2-SWSTU  | 3-active-5ns  | 4-active-10ns  |
|-------|----------|----------|----------|----------------|----------------|
| 挑之前(NEPdataset.xyz) |  1584   | 565       |  2754    |      759      |      1224      |
| 踢掉后(ase_out.xyz) |  1578   | 563       |  2737    |      759      |      1198      |
| 挑之后(selected.xyz) |   1095   | 469       |  1666    |      759      |      1198      |

`2-SWSTU`挑选的时候`pynep`选择`0.007`，`0-vasp`和`1-active`选择的`0.008`。`3-active-5ns` 和`4-active-10ns` 除了筛选出力大于25A的以外全部纳入训练。