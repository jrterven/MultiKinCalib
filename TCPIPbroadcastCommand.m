function ack = TCPIPbroadcastCommand(tcpCons, numCon, command, message)  
    % If any of the commands fail, ack will be false
    ack = true;

    % Network Client 1:
    % Send command
    if numCon > 0
        if TCPIPsendCommand(tcpCons{1},command, ['client 1: ' message]) == false
            ack = false;
            return;
        end
    end

    % Network Client 2:
    % Send command
    if numCon > 1
        if TCPIPsendCommand(tcpCons{2},command, ['client 2: ' message]) == false
            ack = false;
            return;
        end
    end

% Network Client 3:
% Send command
    if numCon > 2
        if TCPIPsendCommand(tcpCons{3},command, ['client 3: ' message]) == false
            ack = false;
            return;
        end
    end
end