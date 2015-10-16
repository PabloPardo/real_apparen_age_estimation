__author__ = 'pablo'

import MySQLdb
import numpy as np
import math


def normal(x, mu, sig):
    return 1 - math.exp(-(x - mu)**2 / (2*sig**2))


def create_db(host='localhost', user='pablo', passwd='Zifnaf1.', database='HuPBA_AGE'):
    db = MySQLdb.connect(host=host,      # your host, usually localhost
                         user=user,      # your username
                         passwd=passwd,  # your password
                         db=database)    # name of the data base
    return db


def get_votes(database, gender='both'):

    if gender == 'both':
        gender_str = ''
    else:
        gender_str = "AND u.gender = '%s'" % gender

    # you must create a Cursor object. It will let
    # you execute all the queries you need
    cur = database.cursor()

    # Use all the SQL you like
    cur.execute("SELECT v.vote, v.img_id, u.gender "
                "  FROM votes v, " +
                "       users u " +
                " WHERE v.usr_id = u.usr_id " + gender_str)

    # print all the first cell of all the rows
    vote = []
    pic_id = []
    gdr = []
    for row in cur.fetchall():
        vote.append(row[0])
        pic_id.append(row[1])
        gdr.append(row[2])

    return vote, pic_id


def get_labels(database):
    # you must create a Cursor object. It will let
    # you execute all the queries you need
    cur = database.cursor()

    # Use all the SQL you like
    cur.execute("SELECT img_id, real_age "
                " FROM images"
                " WHERE real_age > '0'")

    # print all the first cell of all the rows
    pic_id = []
    real = []
    for row in cur.fetchall():
        pic_id.append(row[0])
        real.append(row[1])

    return pic_id, real

"""
Compute Human Error from the Training set.
"""

# Read Apparent Age Train Data
with open('Train.csv', 'r') as f:
    train_apparent = []
    train_std = []
    train_img_ID = []
    for l in f.readlines():
        s = l.split(';')
        train_apparent.append(int(s[1]))
        train_std.append(float(s[2].rstrip('\n')))
        train_img_ID.append(int(s[0].split('.')[0].split('_')[1]))

# Get Real Age from Database
db = create_db()
pic_id, real = get_labels(db)

vote, pic_id = get_votes(db)

score = []
for i in range(len(train_img_ID)):
    score_img = []
    for j in range(len(vote)):
        if pic_id[j] == train_img_ID[i]:
            score_img.append(normal(vote[j], train_apparent[i], train_std[i]))
    score.append(np.mean(score_img))
final_score = np.mean(score)

print final_score
