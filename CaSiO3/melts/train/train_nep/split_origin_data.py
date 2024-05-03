"""
	Run: 
		python split_dataset.py <your_dataset_file_name> <ratio_you_want>

	Author:
		Feiyang Xu <phyang0106@qq.com>

"""

from ase.io import read, write
import random
import sys

reference = read(sys.argv[1], ":")  

ratio = float(sys.argv[2])
random_sample = random.sample(range(len(reference)), int(len(reference) * ratio))
# for i in random_sample:
#     write("./train.xyz", reference[i], append=True)
write("./train.xyz", [reference[i] for i in random_sample])
write("./test.xyz", [reference[i]  for i in range(len(reference)) if i not in random_sample])
