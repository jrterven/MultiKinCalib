% Function: 
%   findPointAfromInfrared
%
% Description:
%   Finds the nearest 3D world point to the marker.
%   The point A is the fixed point, we use a reflective tape on the
%   ground near this point. So when detecting the red points, the nearest
%   point to this (refAw) will be point A.
%   
% Dependencies:
%   Kin2 class
%    
%
% Inputs:
%   kinect: Kin2 object
%
% Usage:
%   This function is called at the beggining of the images acquisition for
%   calibration. This function returns the location of the infrared marker
%   (reflective tape) such that this point be used for detecting the
%   reference point in the calibration object.
%   
% Returns:
%   refAw: position of the infrared marker in camera space (X,Y,Z).
%   refAc: poistion of the infrared marker in color space (x,y)
%
% Authors: 
%   Diana M. Cordova
%   Juan R. Terven
%
%   Date: 05-June-2016

function [refAw, refAc] = findPointAfromInfrared(kinect, infrared)                        
    imgBW = im2bw(infrared);
    % Remove all those pixels less than 300px
    imgBW = bwareaopen(imgBW,5);                       

    % calculate the centroid
    stat = regionprops(imgBW,'centroid');

    refAw = zeros(1,3);
    refAc = zeros(1,2);
    
    if length(stat) >= 1
        refA = stat(1).Centroid;

        % Search for the nearest neighbor that can be mapped to
        % camera space
        movement = 1; % move 1 pixel
        n1 = refA; n2 = refA; n3 = refA; n4 = refA;
        for i=1:100                                                                        
            % Move refA on the 4 neighbors                        
            n1(1) = n1(1) + movement; % move in positive x direction
            n2(1) = n2(1) - movement; % move in negative x direction
            n3(2) = n3(2) + movement;
            n4(2) = n4(2) - movement;

            ns = [n1;n2;n3;n4];
            refAws = kinect.mapDepthPoints2Camera(ns);
            if ~isinf(refAws(1,1))
                refAw = refAws(1,:);
                break; 
            elseif ~isinf(refAws(2,1))
                refAw = refAws(2,:);
                break;
            elseif ~isinf(refAws(3,1))
                refAw = refAws(3,:);
                break;
            elseif ~isinf(refAws(4,1))
                refAw = refAws(4,:);
                break;
            end

            movement = movement + 1;
        end

        refAc = kinect.mapCameraPoints2Color(refAw);
        %plot(refAc(1),refAc(2),'y*')                          

    end                
end % findPointAfromInfrared function