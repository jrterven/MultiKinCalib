function resp = TCPIPgetResponses(tcpCons, numCon, errorMsg)
    % Camera Network Commands
    load('TCPIPCommands.mat');
    
    resp = VALID_FRAME;
    
    if numCon > 0
        r1 = fread(tcpCons{1},1,'double');
        if r1 == ERROR
            disp(['client 1:' errorMsg])
            resp = ERROR;
        end
    end

    if numCon > 1
        r2 = fread(tcpCons{2},1,'double'); 
        if r2 == ERROR
            disp(['client 2:' errorMsg])
            resp = ERROR; 
        end
    end

    if numCon > 2
        r3 = fread(tcpCons{3},1,'double');
        if r3 == ERROR
            disp(['client 3:' errorMsg])
            resp = ERROR; 
        end
    end 
end   