% function: 
%   Find3DMatches
%
% Description:
%   Find 3D matches
%   
% Dependencies:
%
% Inputs:
%
% Usage:
%
% Return:
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016
%
function [cam2_1Matches,cam2_1depthProj,cam2_1colorProj] = Find3DMatches(pc1, pc2, T2_1, ...
    cam2DepthProj, cam2ColorProj, minDist3D)

%     k2 = Kin2('color','depth');
%     
%     while true
%         validData = k2.updateKin2;
%         
%         if validData
%             break;
%         end
%         pause(0.03);
%     end
        
    
    % Transform cam2 points to cam1 in order to find matches by distance
    pc2 = pc2';
    pc2h = [pc2; ones(1,size(pc2,2))];
    pc2_1 = T2_1 \ pc2h;
    pc2_1 = pc2_1(1:end-1,1:end);
    pc2_1 = pc2_1';

    % Find matching points between camera 1 and 2
    %disp('Searching for Matching Points between cameras');
    [cam2_1Matches,cam2_1depthProj,cam2_1colorProj] =  matching3DNN(pc1, pc2_1, cam2DepthProj, cam2ColorProj, minDist3D/1000);
    disp('Finish finding matching points');
    
    % Transform the matches back to camera 2 and get its 2D projections 
    % on the depth camera     
%     cam2PCh = [cam2_1Matches'; ones(1,size(cam2_1Matches,1))];
%     cam2PCh = T2_1 * cam2PCh;
%     cam2PCh = cam2PCh(1:end-1,1:end)';
%     cam2_1depthProj = k2.mapCameraPoints2Depth(cam2PCh);
    
    % and the 2D projections on the color camera
%     cam2_1colorProj = k2.mapCameraPoints2Color(cam2PCh);
    
%     k2.delete;
end