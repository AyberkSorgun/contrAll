#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 30 19:53:30 2019

@author: Aybuke, Ayberk
"""
import numpy
from pandas import read_csv
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras import metrics
from sklearn.preprocessing import MinMaxScaler
import coremltools
# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []
    for sample in dataset:
        for i in range(len(sample)-look_back):
            a = sample[i:(i+look_back)]
            dataX.append(a)
            y = numpy.zeros(5)
            y[int(sample[-1])-1] = 1
            dataY.append(y)
    return numpy.array(dataX), numpy.array(dataY)

# fix random seed for reproducibility
numpy.random.seed(3)
# load the dataset
dataframe = read_csv('/Users/Ayberk/Desktop/gesture-data-labeled.csv', engine='python')
print dataframe
dataset = dataframe.values
dataset = dataset.astype('float32')
numpy.random.shuffle(dataset)
# split into train and test sets
train_size = int(len(dataset) * 0.8)
test_size = len(dataset) - train_size
train, test = dataset[0:train_size,:], dataset[train_size:len(dataset),:]
# normalize the dataset
scaler = MinMaxScaler(feature_range=(0,1))
dataset = scaler.fit_transform(dataset[:,:-1])
# reshape into X=t and Y=t+1
look_back = 60
trainX, trainY = create_dataset(train, look_back)
testX, testY = create_dataset(test, look_back)
# reshape input to be [samples, time steps, features]
trainX = numpy.reshape(trainX, (trainX.shape[0], 1,trainX.shape[1]))
testX = numpy.reshape(testX, (testX.shape[0], 1,testX.shape[1]))
# create and fit the LSTM network
model = Sequential()
model.add(LSTM(64, input_shape=(1,look_back), activation = 'relu',return_sequences = True))
model.add(LSTM(64))
model.add(Dense(5, activation = 'softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=[metrics.categorical_accuracy])
model.fit(trainX, trainY, epochs=25, batch_size=1, verbose=2)
# make predictions
trainPredict = model.predict(trainX)
testPredict = model.predict(testX)

coreml_model = coremltools.converters.keras.convert(
    model, input_names=['gestures'], output_names=['gestureType'])
coreml_model.author = 'Aybüke and Ayberk'
coreml_model.license = 'Aybüke and Ayberk Inc.'
coreml_model.short_description = 'Recognizing gesture types'
coreml_model.input_description['gestures'] = 'One handed gestures on air'
coreml_model.output_description['gestureType'] = 'Which gesture was performed'
coreml_model.save('contrAll-LSTM.mlmodel')