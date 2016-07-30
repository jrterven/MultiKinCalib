function [camData, pc, depthPr, colorPr] = getCalibDataFromClient(tcpCons, camCount, ...
    camDataSize, pointcloudSize, depthProjSize, colorProjSize)
    % Load Camera Network Commands and port numbers
    load('TCPIPCommands.mat');
    
    connections = camCount;
    
    camData = cell(camCount,1);
    pc = cell(camCount,1);
    
    if connections > 0
        fwrite(tcpCons{1},REQUEST,'double');
        response = fread(tcpCons{1},1,'double'); % read ack
        
        disp('Reading cam data from Client1');        
        camraw = fread(tcpCons{1},prod(camDataSize),'double');
        fwrite(tcpCons{1},ACK,'double');
        camData{1} = reshape(camraw,camDataSize);
        
        disp('Reading pointcloud from Client1');        
        pcraw = fread(tcpCons{1},prod(pointcloudSize),'double');
        fwrite(tcpCons{1},ACK,'double');
        pc{1} = reshape(pcraw,pointcloudSize);  
        
        disp('Reading depthProj from Client1');        
        depthraw = fread(tcpCons{1},prod(depthProjSize),'double');
        fwrite(tcpCons{1},ACK,'double');
        depthPr{1} = reshape(depthraw,depthProjSize);  
        
        disp('Reading colorProj from Client1');        
        colorraw = fread(tcpCons{1},prod(colorProjSize),'double');
        fwrite(tcpCons{1},ACK,'double');
        colorPr{1} = reshape(colorraw,colorProjSize);  
    end

    if connections > 1
        fwrite(tcpCons{2},REQUEST,'double');
        response = fread(tcpCons{2},1,'double'); % read ack
        
        disp('Reading cam data from Client2');        
        camraw = fread(tcpCons{2},prod(camDataSize),'double');
        fwrite(tcpCons{2},ACK,'double');
        camData{2} = reshape(camraw,camDataSize);
        
        disp('Reading pointcloud from Client2');        
        pcraw = fread(tcpCons{2},prod(pointcloudSize),'double');
        fwrite(tcpCons{2},ACK,'double');
        pc{2} = reshape(pcraw,pointcloudSize);  
        
        disp('Reading depthProj from Client2');        
        depthraw = fread(tcpCons{2},prod(depthProjSize),'double');
        fwrite(tcpCons{2},ACK,'double');
        depthPr{2} = reshape(depthraw,depthProjSize);  
        
        disp('Reading colorProj from Client2');        
        colorraw = fread(tcpCons{2},prod(colorProjSize),'double');
        fwrite(tcpCons{2},ACK,'double');
        colorPr{2} = reshape(colorraw,colorProjSize);  
    end

    if connections > 2
        fwrite(tcpCons{3},REQUEST,'double');
        response = fread(tcpCons{3},1,'double'); % read ack
        
        disp('Reading cam data from Client3');        
        camraw = fread(tcpCons{3},prod(camDataSize),'double');
        fwrite(tcpCons{3},ACK,'double');
        camData{3} = reshape(camraw,camDataSize);
        
        disp('Reading pointcloud from Client3');        
        pcraw = fread(tcpCons{3},prod(pointcloudSize),'double');
        fwrite(tcpCons{3},ACK,'double');
        pc{3} = reshape(pcraw,pointcloudSize);  
        
        disp('Reading depthProj from Client3');        
        depthraw = fread(tcpCons{3},prod(depthProjSize),'double');
        fwrite(tcpCons{3},ACK,'double');
        depthPr{3} = reshape(depthraw,depthProjSize);  
        
        disp('Reading colorProj from Client3');        
        colorraw = fread(tcpCons{3},prod(colorProjSize),'double');
        fwrite(tcpCons{3},ACK,'double');
        colorPr{3} = reshape(colorraw,colorProjSize);  
    end 
end