
# 数据集构成
## 初始数据集
| Temperature | Pressure |        |         |         |         |          |          |
|-------------|----------|--------|---------|---------|---------|----------|----------|
| 2500K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar |          |          |
| 3000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 900kbar  |          |
| 4000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 1000kbar | 1300kbar |
| 5000K       | 10kbar   | 50kbar | 100kbar | 300kbar | 600kbar | 1000kbar | 1400kbar |

## round-0
跑了这些温度压力下的`AIMD-20000`步， 舍弃前面`5000fs`，然后每隔`300`步抽一个结构做单点计算，将得到的数据训练一个粗糙的`nep.txt`势。

## round 1
估计各个体积比下的晶格常数，用`VASP-MD`后最接近的结构作为`NEP-MD`的`model.xyz`，用得到的`nep`势跑`2ns`的主动学习，此时用的已经是`nvt_bdp`系综了，因为`model.xyz`已经是不同体积比了。抽取`20`个结构重新做单点计算。

## round 2
鉴于上面的主动学习并没有使我的训练效果变好，我又增加了`VASP-AIMD`数据，并将抽取的结构做了微扰`perturb`，加入到数据集中重新训练，结果并没什么用，后来发现，`是因为有几个单点计算没有算收敛`, 现在GPUMD的tools里面将singleOUTCAR2xyz.sh的文件已经能够提示异常计算结果。也可用dpdata检查是否有异常计算结果（不收敛，或者任务异常中断导致未算完）
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

然后训练了一个势函数。`tran-new/all/new-dataset/`

## round 3
用上一步得到的`nep.txt`在各个温度-体积比下跑`5ns`主动学习抽样，抽了`20`个结构（好像某个体积少了一个），发现除了`5000K`外，其他三个温度的对角线图已经比较满意了，但还是做了以下计算

将上次训练的`train.xyz`按照9:1拆分成新的`train.xyz`和`test.xyz`，然后主动学习的`2500K`，`3000K`， `4000K`， `5000K`的数据全部加入到新的训练集中进行训练。原来的数据集中有 `4878` 帧构型，加入了`759`帧。所以现在新的`train.xyz`包含`5149`帧结构，`test.xyz`中包含`488`帧。
