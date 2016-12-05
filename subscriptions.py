import csv                                     # read in dataframe
import pandas as pd                            # data analysis
import numpy as np                             # linear algebra
from datetime import datetime                  # dates
import matplotlib.pyplot as plt                # visualizations
import seaborn as sns                          # visualizations
sns.set(style="darkgrid", color_codes=True)    # viz style

file = "filename.csv"
path = "pathname"
df = pd.read_csv(path+file)

print ("Shape of dataframe (row, col): ", df.shape)
# Shape of dataframe (row, col):  (261, 108)


#########################
#### CLEAN DATAFRAME ####
#########################
## Set entity name to index
df.ix[3,'Unnamed: 0'] = 'quarter' # Identify row with time (to preserve in indexing)
df.set_index(['Unnamed: 0'], inplace=True)

## Remove Extraneous Columns
df = df[list(df.columns[1:98])]

## Rename column headers with appropriately formatted dates
date = list(df.ix['quarter'])

header=[]
for x in date:
    x = str(x)
    x = x.replace(' Q', '')
    month, year = x.split('/')
    x = year + '-' + month
    header.append(x)

df.columns = header

df.columns.values

## Remove Extraneous Rows
df = df.drop(df.index[[0,1,2,3,4]])

print ("Shape of dataframe CLEANED (row, col): ", df.shape)
# Shape of dataframe CLEANED (row, col):  (256, 97)


## DELETE COMMAS FROM CELLS (so can convert to numeric)
def deleteCommas(x):
    if type(x) is str:
        y = x.replace(',','')
        return(y)
    else: 
        return(x)
df = df.applymap(deleteCommas)

## Convert to numeric
df = df.apply(pd.to_numeric)

## Replace 0's with nan
df.replace(0, np.nan, inplace=True)


#############################
#### Examine missingness ####
#############################
def n_missing(x):
    return (sum(x.isnull()))

n_quarter = df.apply(n_missing, axis=0)
n_quarter.max() # =255
n_quarter.min() # =133
n_entity = df.apply(n_missing, axis=1)
n_entity[n_entity==97]
n_entity.max() # =97
n_entity.min() # =133

# There are a 7 distinct entity names with all dates missing: ***
# 3 of these are have duplicates with non-missing data, 4 are unique.

########################
#### Visualizations ####
########################

# Subscriptions by quarter
subSum = np.sum(df, axis=0)

quarters = []
for i in subSum.index:
    dt_obj = datetime.strptime(i, "%y-%m")
    quarters.append(dt_obj)

subs = pd.Series(subSum.values, index=quarters)
subs.sort_index(ascending=True, inplace=True)

plt.plot(quarters, subs)
plt.xlabel('Year')
plt.ylabel('Subscriptions')
plt.title('Cable/Telco/Satellite Subscriptions')


# Number of active entities by quarter
entCount = df.count(axis=0)
entCount = pd.Series(entCount.values, index=quarters)
entCount.sort_index(ascending=True, inplace=True)

plt.plot(quarters, entCount)
plt.xlabel('Year')
plt.ylabel('Active Entities')
plt.title('Active Cable/Telco/Satellite Providers')


# Place both on same plot
plt.plot(quarters, subs, 'b', label='Subscriptions')
plt.plot(quarters, (3e5*entCount), 'r', label='Providers')
plt.legend(bbox_to_anchor=(1, 0.7))
plt.show


######## Time Series ########
fig = plt.figure()
ts = fig.add_subplot(1,1,1)
subs.plot(label = 'Subscriptions')

# Plot across a variety of rolling windows/moving averages
subs.rolling(window=2, center=False).mean().plot(label = 'Rolling 6 Month Mean')
subs.rolling(window=4, center=False).mean().plot(label = 'Rolling 1 Year Mean')
subs.rolling(window=6, center=False).mean().plot(label = 'Rolling 2 Year Mean')

# Also plot std in order to see variance
subs.rolling(window=3, center=False).std().plot(label = 'Rolling 3 Month STD')

ts.legend(loc='best')
ts.set_title('Cable/Telco/Satellite Subscriptions: Moving Averages')
ts.set_ylabel('Subscriptions')
ts.set_xlabel('Years')
