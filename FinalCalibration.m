% Script: 
%   proj05_FinalCalibration
%
% Description:
%   Perform calibration of a Kinect camera (depth or color) given pairs of
%   3D points and 2D projections.
%   
% Dependencies:
%   function proj05_costFunVec: this function is the one we wish to minimize
%   function tr2eul: converts from rotation matriz to Euler angles.
%   calibParameters.mat: file with variables defined in proj0_Multi_Kinect_Calibration.m 
%   such as distortRad, distortTan, withSkew.
%
% Inputs:
%   - preCalibResults: file with initial estimation of rotation and
%       translation for each camera. This file is generated in proj0_Multi_Kinect_Calibration.m 
%   - initIntrinsics: file with initial estimation of intrinsic parameters for each
%       camera. This file is generated in proj0_Multi_Kinect_Calibration.m
%   - camNum: Number of camera to calibrate.
%   - camType: Type of camera to calibrate. 'depth' or 'color'
%    
%   
% Usage:
%   This function is called on the step 5: Final Joint Calibration of the
%   calibration process. 
%
% Results:
%   Intrinsic and extrinsic parameters, radDist (radial distortion) and
%   tanDist (tangential distortion).
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016

function [outData1 outData2] = FinalCalibration( ...
        preCalibResults, initIntrinsics, camNum, camType)

clear proj05_costFunVec3;        % clear persistent variables of the cost function
load('calibParameters.mat');    % Load the variables: distortRad, distortTan, withSkew                          
load(preCalibResults);          % Load the estimated extrinsics
load(initIntrinsics);           % Load the initial intrinsics

% Generates a file with variables for the cost function
save([dataDir '/variablesForCostFun.mat'],'camNum','camType');

cd(fileparts(mfilename('fullpath')));


% Get intrinsic initial values from initIntrinsics file
if strcmp(camType, 'depth')
    if camNum == 1
        f = preIntrinsicsD1(1,1);
        cx = preIntrinsicsD1(1,3);
        cy = preIntrinsicsD1(2,3);
        skew = preIntrinsicsD1(1,2);
    elseif camNum == 2
        f = preIntrinsicsD2(1,1);
        cx = preIntrinsicsD2(1,3);
        cy = preIntrinsicsD2(2,3);
        skew = preIntrinsicsD2(1,2);
    elseif camNum == 3
        f = preIntrinsicsD3(1,1);
        cx = preIntrinsicsD3(1,3);
        cy = preIntrinsicsD3(2,3);
        skew = preIntrinsicsD3(1,2);
    elseif camNum == 4
        f = preIntrinsicsD4(1,1);
        cx = preIntrinsicsD4(1,3);
        cy = preIntrinsicsD4(2,3);
        skew = preIntrinsicsD4(1,2);
    end
elseif strcmp(camType, 'color')
    if camNum == 1
        f = preIntrinsicsC1(1,1);
        cx = preIntrinsicsC1(1,3);
        cy = preIntrinsicsC1(2,3);
        skew = preIntrinsicsC1(1,2);
    elseif camNum == 2
        f = preIntrinsicsC2(1,1);
        cx = preIntrinsicsC2(1,3);
        cy = preIntrinsicsC2(2,3);
        skew = preIntrinsicsC2(1,2);
    elseif camNum == 3
        f = preIntrinsicsC3(1,1);
        cx = preIntrinsicsC3(1,3);
        cy = preIntrinsicsC3(2,3);
        skew = preIntrinsicsC3(1,2);
    elseif camNum == 4
        f = preIntrinsicsC4(1,1);
        cx = preIntrinsicsC4(1,3);
        cy = preIntrinsicsC4(2,3);
        skew = preIntrinsicsC4(1,2);
    end
end

% Get extrinsics from pre-calibration
if camNum == 1
    R = eye(3);
    %Rq = qGetQ( R );
    %Rq = qNormalize(Rq); 
    Rq = rotm2quat(R);
    t = [0 0 0];
elseif camNum == 2 
    %Rq = qGetQ( R1_2 );
    %Rq = qNormalize(Rq);
    Rq = rotm2quat(R1_2);
    t = t1_2;
elseif camNum == 3
    %Rq = qGetQ( R1_3 );
    %Rq = qNormalize(Rq);
    Rq = rotm2quat(R1_3);
    t = t1_3;
elseif camNum == 4
    %Rq = qGetQ( R1_4 );
    %Rq = qNormalize(Rq);
    Rq = rotm2quat(R1_4);
    t = t1_4;
end

% Build the variables vector to be solved
x0 = [f, cx, cy, ...
      Rq(1), Rq(2), Rq(3), Rq(4), ...
      t(1), t(2), t(3)];
    

if distortRad > 0
    if distortRad == 2
        x0 = [x0 0 0];
    elseif distortRad == 3
        x0 = [x0 0 0 0];
    end

    if distortTan
        x0 = [x0 0 0];
    end
end
if withSkew
    x0 = [x0 skew];
end

% Non-linear optimization
options = optimset('Algorithm','levenberg-marquardt','MaxFunEvals',100000, ...
    'TolFun',1e-100,'TolX',1e-100,'MaxIter', 10000);
x = fsolve('proj05_costFunVec3',x0,options);

% Extract results from results vector
f = x(1);   % focal length
cx = x(2);  % principal point x
cy = x(3);  % principal point y

if withSkew
    s = x(end); % skew
else
    s = 0;
end

% Get rotation from vector
Rq = [x(4) x(5) x(6) x(7)];
      
% Convert to rotation matrix
% Rx=[1 0 0;0 cos(Reul(1)) sin(Reul(1));0 -sin(Reul(1)) cos(Reul(1))];
% Ry=[cos(Reul(2)) 0 -sin(Reul(2));0 1 0;sin(Reul(2)) 0 cos(Reul(2))];
% Rz=[cos(Reul(3)) sin(Reul(3)) 0;-sin(Reul(3)) cos(Reul(3)) 0;0 0 1];
% R = Rx*Ry*Rz;  
%R = eul2r(Reul(1),Reul(2),Reul(3));
%Rq = qNormalize(Rq);
% Get rotation matrix from quaternion
%R = qGetR(Rq);
R = quat2rotm(Rq);

% Extract translation
t = [x(8); x(9); x(10)];

% Extract radial and tangential distortion coefficients
if distortRad == 2
    k1 = x(11);
    k2 = x(12);
    if distortTan
        p1 = x(13);
        p2 = x(14);
    end
elseif distortRad == 3
    k1 = x(11);
    k2 = x(12);
    k3 = x(13);
    if distortTan
        p1 = x(14);
        p2 = x(15);
    end
end

% Display results
disp(['***** ' camType ' Camera ' num2str(camNum) ' Calibration Results *****']);

intrinsics = [f s cx;
              0 f cy;
              0 0 1];
disp('Intrinsic parameters matrix:');
disp(intrinsics);

% Rotation
disp('R=');
disp(R);

% Test if the rotation is valid
detR = det(R);
if detR ~= 1
    disp('Invalid rotation matrix!')
    disp(['Determinant = ' num2str(detR)]);
end

% Translation
disp('t=');
disp(t);

% Distortion
radDist = [];
tanDist = [];
if distortRad > 0
    if distortRad == 2
        disp('Radial Distortion: k1, k2')
        radDist = [k1 k2];
        disp(radDist);
        
    elseif distortRad == 3
        disp('Radial Distortion: k1, k2, k3')
        radDist = [k1 k2 k3];
        disp(radDist);
    end
    
    if distortTan
        disp('Tangential Distortion: p1, p2')
        tanDist = [p1 p2];
        disp(tanDist);
    end
end

tanStr = '0';
if distortTan
    tanStr = '2';
else
    tanStr = '0';
end

% Calculate reproyection error with the pointcloud and point-cloud projections
result = struct('CamType',camType,'CamNum',camNum,'MatchingDist',minDist3D, ...
    'Intrinsics',intrinsics,'Rot',R,'t',t,'RadDist',radDist, ...
    'TanDist',tanDist);

repError = proj05_calcReprojectionError2(result);
disp(['Error: ' num2str(repError)]);

   
% Build the name of the struct
name = ['cam' num2str(camNum) '_' camType '_' num2str(minDist3D) 'mm_' ...
    'rad' num2str(distortRad) '_tan' tanStr];

% Build the struct with the data
results = struct('CamType',camType,'MatchingDist',minDist3D, ...
    'Intrinsics',intrinsics,'Rot',Rq,'t',t,'RadDist',radDist, ...
    'TanDist',tanDist,'Error',repError);

outData1.(name) = results;
outData2 = results;

