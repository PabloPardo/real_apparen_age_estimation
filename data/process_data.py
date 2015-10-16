__author__ = 'pablo'

data = []
with open('chalearn_full_db.csv', 'r') as f:
    lines = f.readlines()
    for l in lines:
        name, real, age, _ = l.split(',')
        data.append([name, age, '-1'])

with open('fgnet.csv', 'r') as f:
    lines = f.readlines()
    for l in lines:
        age, ind, name, _ = l.split(',')
        data.append([name, age, ind])

with open('fgnet_chalearn_apparent_db.csv', 'w') as f:
    for img in data:
        f.write(','.join(img) + '\n')