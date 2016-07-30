function ack = TCPIPsendCommand(connection,command, message)
    % Camera Network Commands
    load('TCPIPCommands.mat');

    fwrite(connection,command,'double'); 
    response = fread(connection,1,'double');

    if response == ACK
        disp(message);
        ack = true;
    else
        disp('Communication error!')
        ack = false;
    end
end