# CS 7470 Spring 2024 (MUC)
### Team: What The Hack (3)
| Seth Schofill (bschofill3) | Liston Mehserle (lmehserle3) | Farhan Nesar (fnesar3) | Pranay Lunavat (lunavat) |
| ----------- | ----------- | ----------- | ----------- |
## Project: Future of Fit
### Package Descriptions:
#### ScalarAccel
- startDeviceMotionUpdates()
Records DeviceMotion, which is processed accelerometer. Updates an array with values using updateAccelerometerData()
- stopAccelerometer()
Stops accelerometer sensing
- (REMOVED)getScalarAcceleration() -> Double?
Returns the magnitude/scalar of acceleration from running accelerometer. If available, returns a double. Otherwise, returns nil.
