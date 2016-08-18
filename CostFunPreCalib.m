% Function: 
%   CostFunPreCalib
%
% Description:
%   Function that we wish to minimize using proj02_PreCalib
%   
% Dependencies:
%   File: calibParameters.mat where we load the variables load dataDir and pointsToConsider
%   File: variablesForCostFunPreCalib.mat with the variables camNum, Xw1, Xw2
%
% Inputs:
%   1) x0: parameters that we wish to find by minimizing the function f
%
% Usage:
%   This function is called by the proj02_PreCalib script inside the optimization 
%   function fsolve
%
% Results:
%   find the values of x0 that minimize f
%
% Authors: 
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016
%
function  f= CostFunPreCalib(x0)

persistent Xw1s;
persistent Xw2s;

% Euler angles to Rotation matrix
R = eul2r(x0(1),x0(2),x0(3));
t = [x0(4);x0(5);x0(6)];


% Load the data
if isempty(Xw1s)
    
    % Load dataDir and pointsToConsider
    load('calibParameters.mat');
    
    % Load camNum, Xw1, Xw2
    load([dataDir '/variablesForCostFunPreCalib.mat']);

    Xw1s = Xw1';
    Xw2s = Xw2';    
        
    if pointsToConsider ~= -1
        Xw1s = Xw1s(:,1:pointsToConsider);
        Xw2s = Xw2s(:,1:pointsToConsider);
    end
end
   
pos_puntos_ref=[Xw1s(1,:)' Xw1s(2,:)' Xw1s(3,:)'];
pos_puntos_cam=[Xw2s(1,:)' Xw2s(2,:)' Xw2s(3,:)'];

f = [];
for j=1:size(pos_puntos_ref,1)
     
    vec=pos_puntos_ref(j,:);
    comp=pos_puntos_cam(j,:);
    
    p_esp=(R*vec')+t;
    
    fun = comp - p_esp';
    
    f=[fun'; f];
end

e=mean(abs(f))