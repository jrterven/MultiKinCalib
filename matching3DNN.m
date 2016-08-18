% Function: 
%   matching3DNN
%
% Description:
%   Given two input pointclouds (cam1PC, cam2PC), finds the matching points.
%   Matching points are searched using 1-Nearest Neighbor with a threshold
%   value of epsilon millimeters.
%
% Usage:
%
%
% Params:
%   cam1PC : Pointcloud from camera 1 in n x 3
%   cam2PC : Pointcloud from camera 2 in n x 3
%   epsilon: Max distance between corresponding points in meters
%
% Return: 
%   cam1MatchedPoints : Matched points in camera 1 in m x 3
%   cam2MatchedPoints : Matched points in camera 2 in m x 3
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
% 
% Citation:
%   Put the paper here!
%
% Date: 09-Jan-2016

function [cam2_1MatchedPoints, matchedDepthProj, matchedColorProj] =  matching3DNN( ...
    cam1PC, cam2PC, cam2DepthProj, cam2ColorProj, epsilon)
    
    % Remove inf and NaN values from input pointclouds
    cam1PCvalidRows = ~any( isnan( cam1PC ) | isinf( cam1PC ), 2 );
    cam2PCvalidRows = ~any( isnan( cam2PC ) | isinf( cam2PC ), 2 );
    
    cam1PC = cam1PC(cam1PCvalidRows,:);
    cam2PC = cam2PC(cam2PCvalidRows,:);
    cam2DepthProj = cam2DepthProj(cam2PCvalidRows,:);
    cam2ColorProj = cam2ColorProj(cam2PCvalidRows,:);
    
    % VERSION 3: Using knnsearch from 
    %http://www.mathworks.com/matlabcentral/fileexchange/19345-efficient-k-nearest-neighbor-search-using-jit
    [idx, D] = knnsearch(cam1PC,cam2PC);
    % idx contains the indices of cam2PC with the smallest distance to each
    % cam1PC
    % Find the points with distance less than epsilon
    matchedIdx = idx(D <= epsilon);
    cam2_1MatchedPoints = cam2PC(matchedIdx,:);     
    matchedDepthProj = cam2DepthProj(matchedIdx,:);
    matchedColorProj = cam2ColorProj(matchedIdx,:);
    
    % VERSION 2: Using pdist2 Matlab function, partitioning the pointclouds
    % in 100 parts for storage
    % Brute search for the nearest point to each point from cam1PC in cam2PC
%     iout = 1;
%     
%     elemPerPartition = floor(size(cam1PC,1)/100);
%     
%     for i1=0:99  
%         idx = uint32(floor(i1*elemPerPartition + 1:elemPerPartition*(i1+1)));
%         cam1PCpart = cam1PC(idx,:);
%         D = pdist2(cam1PCpart, cam2PC);
%         [r,c] = find(D<epsilon);
%         
%         cam1MatchedPoints = [cam1MatchedPoints;  cam1PC(r + i1*elemPerPartition,:)];
%         cam2MatchedPoints = [cam2MatchedPoints;  cam2PC(c,:)];
%         
%         disp(i1);
%     end
    
    % VERSION 1: Using vectorized Euclidean distance
%     for i1=1:size(cam1PC,1)     % for each point in cam1PC                
%         
%         % calculate the distance of point i1 from cam1PC to all the points
%         % in cam2PC
%         
%         % replicate the i1th component of cam1PC cam2PC times in order to
%         % vectorize the operation
%         pc1 = repmat(cam1PC(i1,:),size(cam2PC,1),1); 
%         D = sqrt(sum(abs(pc1 - cam2PC).^2,2));
%         
%         % D have all the distances, find the index of the minimun value
%         [m,idx] = min(D);
%         
%         % If the minimum value is less than the theshold we have a match
%         % save the point on both output pointclouds
%         % and remove from the cam2PC search
%         if m < epsilon
%             cam1MatchedPoints(iout,:) = cam1PC(i1,:);
%             cam2MatchedPoints(iout,:) = cam2PC(idx,:);
%             
%             cam2PC(idx,:) = [];
%             iout = iout + 1;
%         end        
%     end
end