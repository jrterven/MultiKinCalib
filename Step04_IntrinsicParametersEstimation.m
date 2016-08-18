% function: 
%   Step04_IntrinsicParametersEstimation(camCount,dataAcqFile,preCalibResultsFile,matchingResultsFile,initIntrinsicsFile)
%
% Description:
%   Estimates intrinsics parameters for all the cameras (depth and color
%   for each Kinect).
%   
% Dependencies:
%   - function EstimateIntrins: estimates the camera intrinsics using the method from 
%   Prince, Simon JD. Computer vision: models, learning, and inference. 
%   Cambridge University Press, 2012.
%
% Inputs:
%   - camCount: Number of cameras to calibrate
%   - dataAcqFile: file containing the data from the acquisition step.
%   - preCalibResultsFile: name of the output file containing the results
%   of the pre-calibration
%   - matchingResultsFile: out file containing the matching results.
%   - initIntrinsicsFile: out file with the estimated intrinsic parameters.
%
% Return:
%   Save the results on the initIntrinsicsFile specified in the arguments.
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: Feb-2016
function Step04_IntrinsicParametersEstimation(dataAcqFile,matchingResultsFile,preCalibResultsFile,initIntrinsicsFile)
% Initialize Intrinsics of depth cam1 using its pointcloud
preIntrinsicsD1 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,1, 'depth');

% Initialize Intrinsics of color cam1 using its pointcloud
preIntrinsicsC1 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,1, 'color');

save(initIntrinsicsFile,'preIntrinsicsD1','preIntrinsicsC1');

if camCount > 1
    % Initialize Intrinsics of depth cam2 using the pointclouds matches with cam1
    preIntrinsicsD2 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,2, 'depth');

    % Initialize Intrinsics of color cam2 using the pointclouds matches with cam1
    preIntrinsicsC2 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,2, 'color');
    
    save(initIntrinsicsFile,'preIntrinsicsD2','preIntrinsicsC2','-append');
end

if camCount > 2
    % Initialize Intrinsics of depth cam2 using the pointclouds matches with cam1
    preIntrinsicsD3 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,3, 'depth');

    % Initialize Intrinsics of color cam2 using the pointclouds matches with cam1
    preIntrinsicsC3 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,3, 'color');
    
    save(initIntrinsicsFile,'preIntrinsicsD3','preIntrinsicsC3','-append');
end

if camCount > 3
    % Initialize Intrinsics of depth cam2 using the pointclouds matches with cam1
    preIntrinsicsD4 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,4, 'depth');

    % Initialize Intrinsics of color cam2 using the pointclouds matches with cam1
    preIntrinsicsC4 = EstimateIntrins(dataAcqFile,matchingResultsFile,preCalibResultsFile,4, 'color');
    
    save(initIntrinsicsFile,'preIntrinsicsD4','preIntrinsicsC4','-append');
end