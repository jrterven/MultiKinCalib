% function: 
%   Step03_Matching(camCount,dataAcqFile,preCalibResultsFile,minDist3D,matchingResultsFile)
%
% Description:
%   Perform the point cloud matching step between all pairs of cameras.
%   
% Dependencies:
%   - function Find3DMatches: peform the actual matching between a pair of
%   pointclouds.
%
% Inputs:
%   - camCount: Number of cameras to calibrate
%   - dataAcqFile: file containing the data from the acquisition step.
%   - preCalibResultsFile: name of the output file containing the results
%   of the pre-calibration
%   - minDist3D: matching distance
%   - matchingResultsFile: out file containing the matching results.
%
% Return:
%   Save the results on the matchingResultsFile specified in the arguments
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: 16-Jan-2016
function Step03_Matching(camCount,dataAcqFile,minDist3D,matchingResultsFile)
load(dataAcqFile);

disp('Step 3: 3D Pointcloud Matching');

% Finds the 3D matches between pointclouds
% Generates a file called matchingResultsFile
disp('Searching for matchings between Cam1 and Cam2');
[cam2_1Matches,cam2_1depthProj,cam2_1colorProj] = Find3DMatches( ...
    pc1, pc2, T1_2, cam2.depthProj, cam2.colorProj, minDist3D);

save(matchingResultsFile,'cam2_1Matches','cam2_1depthProj','cam2_1colorProj');

if camCount > 2 
    disp('Searching for matchings between Cam1 and Cam3');
    [cam3_1Matches,cam3_1depthProj,cam3_1colorProj] = Find3DMatches( ...
        pc1, pc3, T1_3, cam3.depthProj, cam3.colorProj, minDist3D);
    save(matchingResultsFile,'cam3_1Matches', ...
        'cam3_1depthProj','cam3_1colorProj','-append');
    
    disp('Searching for matchings between Cam2 and Cam3');
    [cam3_2Matches,cam3_2depthProj,cam3_2colorProj] = Find3DMatches( ...
        pc2, pc3, T2_3, cam3.depthProj, cam3.colorProj, minDist3D);
    save(matchingResultsFile,'cam3_2Matches', ...
        'cam3_2depthProj','cam3_2colorProj','-append');
end

if camCount > 3 
    disp('Searching for matchings between Cam1 and Cam4');
    [cam4_1Matches,cam4_1depthProj,cam4_1colorProj] = Find3DMatches( ...
        pc1, pc4, T1_4, cam4.depthProj, cam4.colorProj, minDist3D);
    save(matchingResultsFile,'cam4_1Matches', ...
        'cam4_1depthProj','cam4_1colorProj','-append');
end