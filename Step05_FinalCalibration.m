% function: 
%   Step05_FinalCalibration(camCount,preCalibResultsFile,initIntrinsicsFile,finalCalibResults)
%
% Description:
%   Perform the final calibration of all the cameras using a non-linear
%   optimization.
%   
% Dependencies:
%   - function FinalCalibration: performs the calibration of a single
%   camera.
%   - file 'calibParameters.mat' created with proj0_ServerMultiKinectCalib.
%       From this file we use the variables: 'dataDir', 'minFunType', 'pointsToConsider'
%
% Inputs:
%   - camCount: Number of cameras to calibrate
%   - preCalibResultsFile: name of the output file containing the results
%   of the pre-calibration
%   - initIntrinsicsFile: out file with the estimated intrinsic parameters.
%
% Return:
%   Save the results on the finalCalibResults specified in the arguments
%
% Authors:
%   Diana M. Cordova
%   Juan R. Terven
%   Date: Feb-2016
function Step05_FinalCalibration(camCount,preCalibResultsFile,initIntrinsicsFile,finalCalibResults)
disp('Step 4: Final Joint Calibration');

% Calibrate camera 1
disp('Calibrating Depth camera 1...')
[result1, result2] = FinalCalibration(preCalibResultsFile, ...
                           initIntrinsicsFile, 1, 'depth');                      
save(finalCalibResults,'-struct','result1');      % Save results on .mat 

disp('Calibrating Color camera 1...')
[result1, result2] = FinalCalibration(preCalibResultsFile, ...
                            initIntrinsicsFile, 1, 'color');
save(finalCalibResults,'-struct','result1','-append');  

if camCount > 1
    % Calibrate camera 2
    disp('Calibrating Depth camera 2...')
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                               initIntrinsicsFile, 2, 'depth');
    save(finalCalibResults,'-struct','result1','-append');
    
    disp('Calibrating Color camera 2...')
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                                initIntrinsicsFile, 2, 'color');   
    save(finalCalibResults,'-struct','result1','-append');
end

if camCount > 2
    % Calibrate camera 3
    disp('Calibrating Depth camera 3...')
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                                initIntrinsicsFile, 3, 'depth');
    save(finalCalibResults,'-struct','result1','-append')
    
    disp('Calibrating Color camera 3...')                        
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                                initIntrinsicsFile, 3, 'color');                            
    save(finalCalibResults,'-struct','result1','-append')
end

if camCount > 3
    % Calibrate camera 4
    disp('Calibrating Depth camera 4...')
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                                initIntrinsicsFile, 4, 'depth');
    save(finalCalibResults,'-struct','result1','-append');
    
    disp('Calibrating Color camera 4...')
    [result1, result2] = FinalCalibration(preCalibResultsFile, ...
                                initIntrinsicsFile, 4, 'color');
    save(finalCalibResults,'-struct','result1','-append')
end