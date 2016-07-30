# MultiKinCalib
Multiple Kinect V2 Calibration

Run main script to display the main GUI.
Connect a Kinect V2 to the local computer and one or more Kinect V2 to remote computers on the same LAN.
Run each step of the main GUI.

## Setup
Setup calibration parameters such as:
Computer role: Server(local machine) or client.
Cameras: Number of cameras.
Images to save: Number of acquisition images (minumum 2).
Output directory: Where to save the data acquisition and the intermediate results,
Marching distance: Point cloud matching distance in millimeters.
Skew: Calibrate with skew parameter (yes or no).
Radial dist Coeff: Number of radial distortion parameters (2 or 3).
Tangential dist coeff: Calibrate with tangential distortion (yes or no).
Points on calib object: Number of collinear points on the calibration object.
Calib oject length: Length of calib object.

## Data Acquisition
In this step, the server communicates with the remote clients to begin syncrhonized data acquisition.

## Precalibration
With the data acquired in the previous step, the system estimates the pose of each camera.

## Matching
Using the estimates of the pose of each camera, the system gathers matching points between adjacent views.

## Intrinsic Initialization
With the multiple matching points from the previous step, the system estimates an initialization of the intrinsic parameters.

## Non-linear optimization
Perform a non-linear optimization of the intrinsic and extrinsic parameters for each camera.

## Point Cloud
Merge point cloud data using all the cameras.
