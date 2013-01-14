Available training sets
=======================

Some examples of training, validation and test sets are available in the
`training` folder.
* `training_1.dat` and `test_1.dat`:
  * Inputs: last 5 minutes, last hour, last 24 hours
  * Outputs: normal, warning, critical
  * Inputs range: [-1, 1]
  * Outputs range: [0, 1]
  * To be used with `SIGMOID_SYMMETRIC` activation function for hidden layers
    and `SIGMOID` for output layer
* `training_2.dat`, `validation_2.dat` and `test_2.dat`:
  * Inputs: last 5 minutes, last hour, last 24 hours
  * Outputs: normal, warning, critical
  * Inputs range: [-1, 1]
  * Outputs range: [0, 1]
  * Adds validation set to support cross validation of ANN

Already trained engines
=======================

We also provide some already trained engines that can be used out of the box in
the `engines` folder.
 * `engine_working_70.fann`: a neural network with 70% accuracy, trained without
  overfitting control
 * `engine_working_80.fann`: a neural network with 80% accuracy, trained
   without overfitting control
 * `engine_working_93.fann`: a neural network with 93% accuracy, trained with
   simple overfitting control. To constrast lack of k-fold cross validation,
   the sets are built by scrambling samples retrieved from intervals, removing
   cronological order.
To use these engines, copy the corresponding file over to `engine.fann`, which
is read by the running system at startup to build the neural network at the
core of the application.

Example Frontend
================

`index.html` provides a very simple frontend for the monitoring engine that
listen to the WebSocket endpoint updating status and graphs of the monitored
metric in real time.

Training Intervals
==================

The `intervals` file contains the intervals used to build the training set.
Each interval is associated with an output class; examples are built from each
interval by taking the required number of points at a distance of 1 minute one
from the other.
