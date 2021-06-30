#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 29 16:22:47 2021

@author: nooshinnejati
"""

import json
import pandas as pd


with open('/Users/nooshinnejati/Downloads/AI_Dataset.json') as f:
  data = json.load(f)

# Output: {'name': 'Bob', 'languages': ['English', 'Fench']}
print(data)
print(type(data[1]))
print(len(data))
print(data[1])
print(data[8184])
df = pd.DataFrame(data)

############

df = pd.read_stata('/Users/nooshinnejati/Downloads/Test.dta')
print(type(df))
df.to_stata('my_data_out.dta')
df.to_csv("/Users/nooshinnejati/Downloads/my_data_out.csv")

print(df.loc[0])
