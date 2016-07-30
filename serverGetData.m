% Function: 
%   serverGetData
%
% Description:
%   Communicates with remote clients via TCP/IP to obtain the calibration
%   points, pointcloud of the scene, and depth and color projections of the
%   3D calibration points of the current frame
%   
% Dependencies:
%   TCPIPCommands.mat: mat file with custom defined codes
%    
%
% Inputs:
%   TCPIPCons:  TCP/IP connections
%   CapturePC: if true, the clients send all the data to the server and all
%   the data is returned by this function.
%
% Usage:
%   This function is called inside the dataAcq.m GUI KinectUpdate function.
%   When the user presses the "Start Acquisition" button, this function is
%   called repeatedly on each frame acquired from the Kinect. Each time
%   this function is called with the second parameter on false, the remote
%   clients save their data locally. When this function is called with the
%   second parameter on true, the remote clients send the data to the
%   server and this function returns the whole data.
%   
% Returns:
%   dataSaved: if true, all the clients were able to collect data, if
%       false, an error ocurred.
%   camData: cell array of struct arrays with the data for each camera
%       Each element of the cell array contains the data of each camera saved
%       as a structure containing:
%           camPoints:  calibration camera points on camera space
%           pointcloud: colored point cloud of the scene
%           depthProj:  depth projections of point cloud
%           colorProj:  color projections of point cloud
%       For example to access to the camPoints of camera 1 use:
%       camData{1}.camPoints
%
% Authors: 
%   Diana M. Cordova
%   Juan R. Terven
%
%   Date: 26-June-2016

function [dataSaved, camData] = serverGetData(TCPIPCons,CapturePC,pointcloudSize)
    load('TCPIPCommands.mat');    
        
    % Display input buffer size
    %disp(get(tcpipServer1,'InputBufferSize'));
    
    % Number of connections
    CON_NUM = size(tcpipServer1,2);
    
    % Send a capture command to all cameras
    ack = TCPIPbroadcastCommand(TCPIPCons,CON_NUM, CAPTURE, 'capturing');

    % If communication error
    if ack == false
        disp('Comunication Error on CAPTURE command!!');
        dataSaved = false;
        return;
    end
    
    % At this point, all the cameras capture a frame
    % Check if all have valid data
    resp = TCPIPgetResponses(TCPIPCons, CON_NUM, 'No valid Kinect frame');
    
    % Before processing the data, we need to make sure that a valid
    % frame was acquired on all the cameras
    if resp == VALID_FRAME  % if valid frame on all cameras
        % Send a process command to all cameras
        ack = TCPIPbroadcastCommand(TCPIPCons, CON_NUM, PROCESS, 'processing frame');
        if ack == false
            disp('Comunication Error on PROCESS command!!');
            dataSaved = false;
        return;
        end

        % At this point, all the cameras are processing its own frame 
        % searching for the balls
        % Check if all have found the six balls
        resp = TCPIPgetResponses(TCPIPCons, CON_NUM, ...
                ['Not found ' num2str(pointsOnStick) ' balls']);    

        if resp == VALID_FRAME   % if all cameras found the six balls             
            % Send a save command to all cameras
            ack = TCPIPbroadcastCommand(TCPIPCons, CON_NUM, SAVE, 'saving frame');
            if ack == false
                dataSaved = false;
                return; 
            end                                                                                                                     

            % if we want to collect all the data from the clients
            if CapturePC
                % Get remote camPoints, pointclouds, depthProj, and
                % colorProj
                camPointsMetDat = whos('camPoints');
                camDataSize = camPointsMetDat.size;
                depthProjMetDat = whos('depthProj');
                depthProjSize = depthProjMetDat.size;
                colorProjMetDat = whos('colorProj');
                colorProjSize = colorProjMetDat.size;

                [camPoints, pc, depthPr, colorPr] = getCalibDataFromClient(TCPIPCons, ...
                    CON_NUM, camDataSize, pointcloudSize, ...
                    depthProjSize,colorProjSize);
                if CON_NUM > 1
                    cam2 = struct('camPoints',camPoints{1}, ...
                        'pointcloud',pc{1}, 'depthProj',depthPr{1}, ...
                        'colorProj',colorPr{1});
                    camData{2} = cam2;
                end
                if CON_NUM > 2
                    cam3 = struct('camPoints',camPoints{2}, ...
                        'pointcloud',pc{2}, 'depthProj',depthPr{2}, ...
                        'colorProj',colorPr{2});
                    camData{3} = cam3;
                end
                if CON_NUM > 3
                    cam4 = struct('camPoints',camPoints{3}, ...
                        'pointcloud',pc{3},'depthProj',depthPr{3}, ...
                        'colorProj',colorPr{3});
                    camData{4} = cam4;
                end
            end 
        else
            dataSaved = false;
            return;
        end
    else   % if some client were not able to capture data
        dataSaved = false;
        return;
    end
end