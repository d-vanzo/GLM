#!/usr/bin/python
import pandas as pd
import matplotlib.pyplot as plt
import glob
import os

path = '.'                     # use your path
all_files = glob.glob(path + "/**/lake.csv")     # advisable to use os.path.join as this makes concatenation OS independent

for f in all_files:
	#print f
	data = pd.read_csv(f)
	plt.figure(1)
	plt.plot(data['Surface Temp'], label=f)
	plt.figure(2)
	plt.plot(data['Lake Level'], label=f)
plt.legend()
plt.show()