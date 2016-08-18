% function: 
%   Step02_PreCalibration(camCount,dataAcqFile,preCalibResultsFile)
%
% Description:
%   Perform a pre-calibration of the extrinsic parameters of all the
%   Kinect cameras.
%   
% Dependencies:
%   - function proj02_CostFunPreCalib: this function is the one we wish to
%   minimize.
%   - file 'calibParameters.mat' created with proj0_ServerMultiKinectCalib.
%       From this file we use the variables: 'dataDir', 'minFunType', 'pointsToConsider'
%   - file dataAcqFile created with proj01_ServerCapturePointsFromCalibObject.m
%       From this file we get the calibration camera points of the camera
%       we wish to calibrate i.e. cam2.camPoints, cam3.camPoints, etc.
%
% Inputs:
%   - camCount: Number of cameras to calibrate
%   - dataAcqFile: file containing the data from the acquisition step.
%   - preCalibResultsFile: name of the output file containing the results
%   of the pre-calibration
%
% Return:
%   Save the results on the preCalibResultsFile specified in the arguments
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016
function Step02_PreCalibration(camCount,dataAcqFile,preCalibResultsFile)

disp('Step 2: Pre-calibration');

% Estimate extrinsic parameters between camera 1 and camera 2
disp('Estimate extrinsic parameters between camera 1 and camera 2');
[R1_2, t1_2, T1_2] = PreCalib(1,2,dataAcqFile);
save(preCalibResultsFile,'R1_2','t1_2');

if camCount > 2
    % Estimate extrinsic parameters between camera 3 and camera 1
    disp('Estimate extrinsic parameters between camera 1 and camera 3');
    [R1_3, t1_3, T1_3] = PreCalib(1,3,dataAcqFile);
    save(preCalibResultsFile,'R1_3','t1_3', '-append');
    
    disp('Estimate extrinsic parameters between camera 2 and 3');
    [R2_3, t2_3, T2_3] = PreCalib(2,3,dataAcqFile);
    save(preCalibResultsFile,'R2_3','t2_3', '-append');
end

if camCount > 3
    % Estimate extrinsic parameters between camera 4 and camera 1
    disp('Estimate extrinsic parameters between camera 1 and camera 4');
    [R1_4, t1_4, T1_4] = PreCalib(1,4,dataAcqFile);
    save(preCalibResultsFile,'R1_4','t1_4', '-append');
end