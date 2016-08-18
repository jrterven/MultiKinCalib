% Function: 
%   proj05_costFunVec
%
% Description:
%   Function that we wish to minimize.
%   
% Dependencies:
%   - calibParameters.mat: file with variables defined in proj0_Multi_Kinect_Calibration.m 
%       such as: dataDir, distortRad, distortTan, withSkew
%   - matchingResults.mat: file containing the 3D matching points 
%       (cam2_1Matches, cam3_1Matches, etc)and 2D projections
%       (cam2_1depthProj, cam2_1colorProj, etc)
%   - variablesForCostFun.mat: file with variables 'camNum','camType'
%   created in proj05_FinalCalibration.
%   
% Inputs:
%   x0: parameters that we wish to find by minimizing the function f
%
% Usage:
%   This function is called by an optimization function such as fsolve,
%   lsqnonlin, fmincon
%
% Results:
%   find the values of x0 that minimize f
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016
function  fun = proj05_costFunVec(x0)

persistent X3d x2d distRad distTan height width with_skew;

% The first iteration loads the data
if isempty(X3d)
    X3d = [];
    x2d = [];
    
    % Load dataDir, distortRad, distortTan, withSkew
    load('calibParameters.mat');
    distRad = distortRad;
    distTan = distortTan;
    with_skew = withSkew;        
    
    % Load variables camNum and camType
    load([dataDir '/variablesForCostFun.mat']);
    
    if camNum == 1
        load(dataAcqFile)
    else       
        % Load the point clouds: cam2_1Matches, cam3_1Matches, etc
        load(matchingResultsFile);
    end
    
    if strcmp(camType, 'depth')
        height = 424;
        width = 512;
    elseif strcmp(camType, 'color')
        height = 1080;
        width = 1920;
    end

    
    % Get the 3D points from the matching results
    % 3D points as a 3 x n matrix
    if camNum == 1
        X3d = (cam1.pointcloud(1:100:end,:))';
        
        % 2D points as a 2 x n matrix
        if strcmp(camType, 'depth')
            x2d = double(cam1.depthProj(1:100:end,:))';
        elseif strcmp(camType, 'color')
            x2d = double(cam1.colorProj(1:100:end,:))';
        end
    elseif camNum == 2
        X3d = cam2_1Matches';
        
        % 2D points as a 2 x n matrix
        if strcmp(camType, 'depth')
            x2d = double(cam2_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam2_1colorProj)';
        end
    elseif camNum == 3
        X3d = cam3_1Matches';
        
        if strcmp(camType, 'depth')
            x2d = double(cam3_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam3_1colorProj)';
        end
    elseif camNum == 4
        X3d = cam4_1Matches';
        
        if strcmp(camType, 'depth')
            x2d = double(cam4_1depthProj)';
        elseif strcmp(camType, 'color')
            x2d = double(cam4_1colorProj)';
        end
    end
    
    % Remove outliers from X3d in both matrices
    % Find columns with invalid values
    x2dValidCols = ~any( isnan( x2d ) | isinf( x2d ) | x2d > width | x2d < 0, 1 );
    x3dValidCols = ~any( isnan( X3d ) | isinf( X3d ) | X3d > 8, 1 );
    validCols = x2dValidCols & x3dValidCols;
    
    x2d = x2d(:,validCols);
    X3d = X3d(:,validCols);
    
%     x2d(:,any(X3d > 8)) = []; % remove columns with values greater than 8 meters
%     x2d(:,any(X3d == inf)) = [];
%     x2d(:,any(X3d == -inf)) = [];
%      
%     X3d(:,any(X3d > 8)) = []; % remove columns with values greater than 8 meters
%     X3d(:,any(X3d == inf)) = [];
%     X3d(:,any(X3d == -inf)) = [];
%     
%     % Now remove outliers from x2d in both matrices
%     X3d(:,any(x2d > width)) = []; 
%     X3d(:,any(x2d < 0)) = []; % remove columns with negative values
%     X3d(:,any(x2d == inf)) = [];
%     X3d(:,any(x2d == -inf)) = [];
%      
%     x2d(:,any(x2d > width)) = []; 
%     x2d(:,any(x2d < 0)) = []; % remove columns with negative values
%     x2d(:,any(x2d == inf)) = [];
%     x2d(:,any(x2d == -inf)) = [];
    
end

f = x0(1);  % focal length
cx = x0(2); % principal point
cy = x0(3);

% Rotation
R = eul2r(x0(4),x0(5),x0(6));
% Rx=[1 0 0;0 cos(x0(4)) sin(x0(4));0 -sin(x0(4)) cos(x0(4))];
% Ry=[cos(x0(5)) 0 -sin(x0(5));0 1 0;sin(x0(5)) 0 cos(x0(5))];
% Rz=[cos(x0(6)) sin(x0(6)) 0;-sin(x0(6)) cos(x0(6)) 0;0 0 1];
% R = Rx*Ry*Rz;

% Translation
t = [x0(7);x0(8);x0(9)];


if distRad == 2
    k1 = x0(10);
    k2 = x0(11);
    if distTan
        p1 = x0(12);
        p2 = x0(13);
    end
elseif distRad == 3
    k1 = x0(10);
    k2 = x0(11);
    k3 = x0(12);
    if distTan
        p1 = x0(13);
        p2 = x0(14);
    end
end


if with_skew
    s = x0(end);
else
    s = 0;
end
    

intrinsic = [f s cx;
         0 f cy;
         0 0  1];
         

N = size(X3d,2);

Xw = X3d;
xc = x2d;
xc(2,:) = height - xc(2,:);

% Apply extrinsic parameters
proj = R * Xw  + repmat(t,1,size(Xw,2));
    
% Apply Intrinsic parameters to get the projection
proj = intrinsic * proj;
proj = proj ./ repmat(proj(3,:),3,1);  
    
% Distortion correction
if distRad > 0
    u = proj(1,:);
    v = proj(2,:);
    ud=xc(1,:);
    vd=xc(2,:);        

    r = sqrt((u-cx).^2 + (v-cy).^2);

    if distRad == 2        
        compRad(1,:) = 1 + k1*r.^2 + k2*r.^4;
        compRad(2,:) = 1 + k1*r.^2 + k2*r.^4;
    elseif distRad == 3
        compRad(1,:) = 1 + k1*r.^2 + k2*r.^4 + k3*r.^6;
        compRad(2,:) = 1 + k1*r.^2 + k2*r.^4 + k3*r.^6;
    end

    compTan = zeros(2,size(u,2));
    if distTan
        compTan(1,:) = 2*p1*(u-cx).*(v-cy) + p2*(r.^2+2*(u-cx).^2);
        compTan(2,:) = p1*(r.^2+2*(v-cy).^2) + 2*p2*(u-cx).*(v-cy);
    end

    % Reprojection error with distortion
    fun(1,:)= ((u-cx).*compRad(1,:) + compTan(1,:)) - (ud-cx);
    fun(2,:)= ((v-cy).*compRad(2,:) + compTan(2,:)) -(vd-cy);
else
    % Reprojection error without distortion
    fun = proj(1:2,:) - xc;
end

% Display the reproyection error
err = fun .* fun;
err = sum(err(:));
disp(sqrt(err/N));

