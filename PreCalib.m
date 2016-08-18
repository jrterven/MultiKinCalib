% function: 
%   [Rs, ts, T] = PreCalib(camNum,dataAcqFile)
%
% Description:
%   Perform a pre-calibration of the extrinsic parameters between a pair of
%   Kinect cameras.
%   
% Dependencies:
%   - function CostFunPreCalib: this function is the one we wish to
%   minimize.
%   - file 'calibParameters.mat' created with proj0_ServerMultiKinectCalib.
%       From this file we use the variables: 'dataDir', 'minFunType', 'pointsToConsider'
%   - file dataAcqFile created with proj01_ServerCapturePointsFromCalibObject.m
%       From this file we get the calibration camera points of the camera
%       we wish to calibrate i.e. cam2.camPoints, cam3.camPoints, etc.
%
% Inputs:
%   - camNum: Number of camera to calibrate wrt the reference camera
%   - file dataAcqFile
%
% Usage:
%
% Return:
%   - Rs, ts: Estimation of the extrinsic parameters of the camNum wrt the
%   reference camera.
%   - T: 4x4 transformation matrix composed by Rs and Tt
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016

function [Rs, ts, T] = PreCalib(camA,camB,dataAcqFile)

% Load calibration parameters:
%'dataDir', 'minFunType', 'pointsToConsider'
load('calibParameters.mat');
load(dataAcqFile);

%% Calibrate Depth Camera
R = eye(3);    
t = [0,0,0];

% Extract the data from the structures located in dataAcqFile
if camA == 1
    XwA = cam1.camPoints;
elseif camA == 2
    XwA = cam2.camPoints;
elseif camA == 3
    XwA = cam3.camPoints;
elseif camA == 4
    XwA = cam4.camPoints;
end

if camB == 1
    XwB = cam1.camPoints;
elseif camB == 2
    XwB = cam2.camPoints;
elseif camB == 3
    XwB = cam3.camPoints;
elseif camB == 4
    XwB = cam4.camPoints;
end
    
if strcmp(minFunType,'pointReg')  
    
        
    if pointsToConsider ~= -1
        XwA = XwA(1:pointsToConsider,:);
        XwB = XwB(1:pointsToConsider,:);
    end
    
    [Rs,ts] = rigid_transform_3D(XwA, XwB);
    rmse = calculateRegistrationError(XwA',XwB',Rs,ts);
    disp(['RMSE of Precalibration:' num2str(rmse)]);
    
elseif strcmp(minFunType,'fsolve')

    % Generates a file with variables for the cost function
    save([dataDir '/variablesForCostFunPreCalib.mat'],'camNum','Xw1','Xw2');

	x0 = [0, 0, 0, t(1), t(2), t(3)];

    options = optimset('MaxFunEvals',100000,'TolFun',1e-100,'TolX',1e-100, 'MaxIter', 10000);
    x = fsolve('proj02_CostFunPreCalib',x0,options);
    
    Reul = [x(1) x(2) x(3)];
      
    Rx=[1 0 0;0 cos(Reul(1)) sin(Reul(1));0 -sin(Reul(1)) cos(Reul(1))];
    Ry=[cos(Reul(2)) 0 -sin(Reul(2));0 1 0;sin(Reul(2)) 0 cos(Reul(2))];
    Rz=[cos(Reul(3)) sin(Reul(3)) 0;-sin(Reul(3)) cos(Reul(3)) 0;0 0 1];
    
    Rs = Rx*Ry*Rz;
    ts = [x(4); x(5); x(6)];
else
    disp('Invalid minimization function: only supports pointReg or fsolve');
end

% Test if it is a valid rotation matrix
disp('R:'), disp(Rs)
disp('Rotation determinant:')
det(Rs)

disp('t='), disp(ts)

T = [Rs ts; 0 0 0 1];


