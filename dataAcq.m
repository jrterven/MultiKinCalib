function varargout = dataAcq(varargin)
% DATAACQ MATLAB code for dataAcq.fig
%      DATAACQ, by itself, creates a new DATAACQ or raises the existing
%      singleton*.
%
%      H = DATAACQ returns the handle to a new DATAACQ or the handle to
%      the existing singleton*.
%
%      DATAACQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAACQ.M with the given input arguments.
%
%      DATAACQ('Property','Value',...) creates a new DATAACQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataAcq_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataAcq_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataAcq

% Last Modified by GUIDE v2.5 05-Jun-2016 18:43:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataAcq_OpeningFcn, ...
                   'gui_OutputFcn',  @dataAcq_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before dataAcq is made visible.
function dataAcq_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataAcq (see VARARGIN)

% Choose default command line output for dataAcq
handles.output = hObject;

% Create timer
handles.timer = timer('ExecutionMode','fixedRate',...
                    'Period', 0.1,...
                    'TimerFcn', {@KinectUpdate,handles});

% Update handles structure
guidata(hObject, handles);

set(handles.buttonStopKinects,'Visible','Off');
set(handles.buttonStartAcq,'Enable','Off');
set(handles.buttonStopAcq,'Visible','Off');
set(handles.buttonSaveReference,'Enable','Off');
set(handles.buttonClearReference,'Visible','Off');

% Reference not ready
setappdata(handles.axesCam1,'refAReady',false);

% Acquistion = false
setappdata(handles.buttonStartAcq,'Acquisition',false);
% local adquisitions empty
setappdata(handles.buttonStartAcq,'camPoints',[]); 

% Clear the image axes
clearImg = ones(1080,1920) * 255;
imshow(clearImg, 'Parent', handles.axesCam1);

% Get setup data
role = getappdata(0,'role');
camCount = getappdata(0,'camCount');
countImagesToSave = getappdata(0,'countImagesToSave');

set(handles.editCams,'string',num2str(camCount));
set(handles.editAcqs,'string',num2str(countImagesToSave));

if strcmp(role,'client')
    clientId = getappdata(0,'clientId');
    set(handles.textRole,'string',[role ' ' num2str(clientId)]);

    serverIP = getappdata(0,'serverIP');
    set(handles.editServerIP,'string',serverIP);

%    set(handles.buttonStartKinects,'Enable','Off');
else
    % Display 'server' role
    set(handles.textRole,'string',role);

    % Display local IP address
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    set(handles.editServerIP,'string',IPaddress);
end

% Save the number of connections
setappdata(handles.figure1,'connections',0);

    

% UIWAIT makes dataAcq wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataAcq_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonStartKinects.
function buttonStartKinects_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStartKinects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath('Kin2/Mex');
k2 = Kin2('color','depth','infrared');
%imgWidth = 512; imgHeight = 424; outOfRange = 4000;
setappdata(handles.axesCam1,'k2',k2);

start(handles.timer)
%disp('Timer activated')
set(handles.buttonStartKinects,'Visible','Off');
set(handles.buttonStopKinects,'Visible','On');
set(handles.buttonSaveReference,'Enable','On');

% Save reference flag to false
setappdata(handles.axesCam1,'refAReady',false);


function KinectUpdate(obj,event,handles)
    k2 = getappdata(handles.axesCam1,'k2');
    refAReady = getappdata(handles.axesCam1,'refAReady');

    % Get frames from Kinect and save them on underlying buffer
    validData = k2.updateData;
    
    % Before processing the data, we need to make sure that a valid
    % frame was acquired.
    if validData
        % Copy data to Matlab matrices        
        %depth = k2.getDepth;
        colorImg = k2.getColor;
        infrared = k2.getInfrared;              

        % If not reference ready
        if ~refAReady
            % Search the infrared marker on the infrared image
            [refAw, refAc] = findPointAfromInfrared(k2, infrared);
            
            % and save it
            setappdata(handles.axesCam1,'refAw',refAw);
            setappdata(handles.axesCam1,'refAc', refAc);
        % If the reference is ready, get it from memory
        else
            refAw = getappdata(handles.axesCam1,'refAw');
            refAc = getappdata(handles.axesCam1,'refAc');
        end
        
        % Read the acqusition flag (see if acquisition is activated)
        acquisition = getappdata(handles.buttonStartAcq,'Acquisition');
        
        % If no acquisition activated
        if ~acquisition
            % Plot the infrared marker on the color image
            colorImg = insertShape(colorImg,'FilledCircle',[refAc 10],'color','yellow');                    
        % If acquisition activated,
        % get parameters 
        else
            role = getappdata(0,'role');            
            pointsOnStick = getappdata(0,'pointsOnStick');
            sizeStick = getappdata(0,'sizeStick');
            refAw = getappdata(handles.axesCam1,'refAw');
            pointcloudSize = getappdata(handles.buttonConnect,'pointcloudSize');
            
            % if this computer is the server
            if strcmp(role,'server')
                % Get the TCPIP connections
                TCPIPCons = getappdata(handles.buttonConnect,'TCPIPCons');
                
                % Get the location of the calibration points in color space
                % returns points as a 6x2 matrix in the case of six balls or 3x2 in
                % the case of three balls
                [validBalls, points] = trackCalibPoints(k2,colorImg, ...
                            pointsOnStick, refAw, sizeStick);
                        
                if validBalls
                    % Plot the balls in color
                    colorImg = insertShape(colorImg,'FilledCircle',points(1,:),'color','yellow');
                    %plot(points(1,1),points(1,2),'y*', 'MarkerSize',15)
                    colorImg = insertShape(colorImg,'FilledCircle',points(2,:),'color','blue');
                    %plot(points(2,1),points(2,2),'b*','MarkerSize',15)
                    colorImg = insertShape(colorImg,'FilledCircle',points(3,:),'color','cyan');
                    %plot(points(3,1),points(3,2),'c*','MarkerSize',15)
                    if pointsOnStick == 6
                        plot(points(4,1),points(4,2),'k*','MarkerSize',15)
                        plot(points(5,1),points(5,2),'g*','MarkerSize',15)
                        plot(points(6,1),points(6,2),'m*','MarkerSize',15)
                    end                                              
                
                    % read the desired number of acquisitions from GUI
                    maxAcqs = str2double(get(handles.editAcqs,'String'));
                    
                    % read the current number of acquistions
                    camPoints = getappdata(handles.buttonStartAcq,'camPoints');
                    currAcqs = size(camPoints,1);
                    
                    finishAcq = false;  % flag indicating finishing acquisition
                    
                    % if the number of acquisitions is less than the
                    % desired acquisitions, send to clients a command 
                    % gather data and save it locally
                    if currAcqs < (maxAcqs - 1)
                        % Send a command to get the calibration points on
                        % camera space from on each remote camera
                        [dataSaved, ~] = serverGetData(TCPIPCons,false,pointcloudSize);
                    % if the current number of acquisitions reached the
                    % desired acquistions fetch all the data from the
                    % clients
                    else
                        %camData is a cell array of struct arrays with the 
                        % data from each remote camera. Each element of the 
                        % cell array is a structure with the following fields:
                        % camPoints:  calibration camera points on camera space
                        % pointcloud: colored point cloud of the scene
                        % depthProj:  depth projections of point cloud
                        % colorProj:  color projections of point cloud
                        % As an example to access to the camPoints of camera 1 use:
                        % camData{1}.camPoints
                        [dataSaved, camData] = serverGetData(TCPIPCons,false,pointcloudSize);
                        
                        if dataSaved, finishAcq = true; end
                    end
                    
                    if dataSaved
                        % Accumulate local data points in camera space. These are 
                         % the calibration points in camera space (n x 3)   
                         
                        camPoints = [camPoints; k2.mapColorPoints2Camera(points)]; 
                        setappdata(handles.buttonStartAcq,'camPoints',camPoints);
                        
                        % update the number of acquisitions
                        acqs = size(camPoints,1);
                        set(handles.textAcquisitions,'String',num2str(acqs));
                        
                        if finishAcq
                            % Get the local pointcloud
                            pointcloud = k2.getPointCloud;
                            % Get the pointcloud's projections on depth space
                            depthProj = k2.mapCameraPoints2Depth(pointcloud);
                            % Get the pointcloud's projections on color space
                            colorProj = k2.mapCameraPoints2Color(pointcloud);
                    
                            % Save all the data into camData
                            cam1 = struct('camPoints',camPoints,'pointcloud',pointcloud, ...
                                'depthProj', depthProj, 'colorProj', colorProj);
                            
                            camData{1} = cam1;                            
                            setappdata(0,'camData',camData);
                        end
                    end
                end
            % if client
            else
                tcpipClient = getappdata(0,'tcpipClient');
                
            end
        end
      
        imshow(colorImg, 'Parent', handles.axesCam1);
    end

% --- Executes on button press in buttonStopKinects.
function buttonStopKinects_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStopKinects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isvalid(handles.timer)
    stop(handles.timer);
end

% Delete Kinect object
k2 = getappdata(handles.axesCam1,'k2');
k2.delete;
setappdata(handles.axesCam1,'k2',k2);

set(handles.buttonStartKinects,'Visible','On');
set(handles.buttonStopKinects,'Visible','Off');

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isvalid(handles.timer)
    stop(handles.timer);
    delete(handles.timer);    
end

clear handles.timer;

% Hint: delete(hObject) closes the figure
delete(hObject);



function editCams_Callback(hObject, eventdata, handles)
% hObject    handle to editCams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCams as text
%        str2double(get(hObject,'String')) returns contents of editCams as a double


% --- Executes during object creation, after setting all properties.
function editCams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAcqs_Callback(hObject, eventdata, handles)
% hObject    handle to editAcqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAcqs as text
%        str2double(get(hObject,'String')) returns contents of editAcqs as a double


% --- Executes during object creation, after setting all properties.
function editAcqs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAcqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonStartAcq.
function buttonStartAcq_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStartAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.buttonStartAcq,'Enable','Off');
setappdata(handles.buttonStartAcq,'Acquisition',true);


% --- Executes on button press in buttonSaveExit.
function buttonSaveExit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop timer
if isvalid(handles.timer)
    stop(handles.timer);
    delete(handles.timer);    
end

% Close network connections, if any
closeConnections(handles);

%figure(main)
close(dataAcq)

function closeConnections(handles)
    role = getappdata(0,'role');
    connections = getappdata(handles.figure1,'connections');  
    TCPIPCons = getappdata(handles.buttonConnect,'TCPIPCons');
    
    % close the server connections
    if strcmp(role,'server')
        if connections == 1
            %tcpipServer1 = getappdata(0,'tcpipServer1');
            fclose(TCPIPCons{1});     
        end
        if connections == 2
            %tcpipServer2 = getappdata(0,'tcpipServer2');
            fclose(TCPIPCons{2});     
        end
        if connections == 3
            %tcpipServer3 = getappdata(0,'tcpipServer3');
            fclose(TCPIPCons{3});     
        end    
    % if client, close client connection
    else
        if connections == 1
            tcpipClient = getappdata(0,'tcpipClient');
            fclose(tcpipClient);
        end
    end

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Shutdown timer
if isvalid(handles.timer)
    stop(handles.timer);
    delete(handles.timer);    
end

% Close network connections, if any
closeConnections(handles);

figure(main)
close(dataAcq)

% --- Executes on button press in buttonStopAcq.
function buttonStopAcq_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStopAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%setappdata(hObject,'Initialization',false);

function editServerIP_Callback(hObject, eventdata, handles)
% hObject    handle to editServerIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editServerIP as text
%        str2double(get(hObject,'String')) returns contents of editServerIP as a double


% --- Executes during object creation, after setting all properties.
function editServerIP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editServerIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonConnect.
function buttonConnect_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.buttonConnect,'Enable','Off');

depth_width = 512; depth_height = 424;
pointcloud = zeros(depth_height*depth_width,3);
pcMetDat = whos('pointcloud');
pointcloudSize = pcMetDat.size;

% Save pointcloud
setappdata(handles.buttonConnect,'pointcloud',pointcloud);
setappdata(handles.buttonConnect,'pointcloudSize',pointcloudSize);


role = getappdata(0,'role');
camCount = getappdata(0,'camCount') - 1;

% Set the number of external clients (cameras), max = 3 (3 clients +
% server)
CON_NUM = camCount; % 1 client + server = 2 Kinects

% Load Camera Network Commands and port numbers
load('TCPIPCommands.mat');

connections = 0;

% If the current computer is the Server
if strcmp(role,'server')
    TCPIPCons = cell(0);
    % Start a TCP/IP server socket in MATLAB. 
    % By setting the IP address to '0.0.0.0' the server socket will accept 
    % connections on the specified port 
    % (arbitrarily chosen to be 55000 in our case) from any IP address. 
    % You can restrict the TCP/IP server socket to only accept incoming 
    % connections from a specific IP address by explicitly specifying the IP address.
    if CON_NUM > 0
        tcpipServer1 = tcpip('0.0.0.0',PORT1,'NetworkRole','Server');
        set(tcpipServer1,'OutputBufferSize',8); % sending one double (8 bytes)
        set(tcpipServer1,'InputBufferSize',pcMetDat.bytes); % receive complete pointcloud
        set(tcpipServer1,'Timeout',60);                
        
        % Save server1
        setappdata(0,'tcpipServer1',tcpipServer1);                

        % Open the server socket and wait indefinitely for a connection. 
        % This line will cause MATLAB to wait until an incoming connection is established.
        disp('TCP Server ready')
        disp('Waiting for client 1 ...')
        fopen(tcpipServer1);
        TCPIPCons{1} = tcpipServer1;
        disp('Client 1 connected.')
        connections = 1;
    end

    % If we want more than one client, set up another connection
    if CON_NUM > 1
        tcpipServer2 = tcpip('0.0.0.0',PORT2,'NetworkRole','Server');
        set(tcpipServer2,'OutputBufferSize',8); % sending one double (8 bytes)
        set(tcpipServer2,'InputBufferSize',pcMetDat.bytes); % receive complete pointcloud
        set(tcpipServer2,'Timeout',30);
        
        % Save server2
        setappdata(0,'tcpipServer2',tcpipServer2);
        
        disp('TCP Server ready')
        disp('Waiting for client 2...')
        fopen(tcpipServer2);
        TCPIPCons{2} = tcpipServer2;
        disp('Client 2 connected.')
        connections = 2;
    end

    if CON_NUM > 2
        tcpipServer3 = tcpip('0.0.0.0',PORT3,'NetworkRole','Server');
        set(tcpipServer3,'OutputBufferSize',8); % sending one double (8 bytes)
        set(tcpipServer3,'InputBufferSize',pcMetDat.bytes); % receive complete pointcloud
        set(tcpipServer3,'Timeout',30);
        
        % Save server3
        setappdata(0,'tcpipServer3',tcpipServer3);
        
        disp('TCP Server ready')
        disp('Waiting for client 3...')
        fopen(tcpipServer3);
        TCPIPCons{3} = tcpipServer3;
        disp('Client 3 connected.');
        connections = 3;
    end
    
    % Save the connections
    setappdata(handles.buttonConnect,'TCPIPCons',TCPIPCons);
    
    disp(size(TCPIPCons))
    
% If the computer is a client    
else
    % get the client ID
    clientId = getappdata(0,'clientId');
    if clientId == 1
        port = PORT1;
    elseif clientId == 2
        port = PORT2;
    elseif clientId == 3
        port = PORT3;
    end
    
    serverIP = get(handles.editServerIP,'string');
    
    disp(['Trying to connect with server in ' serverIP]);
    % Create a MATLAB client connection to our MATLAB server socket. 
    % The port number of the client must match that selected for the server.
    tcpipClient = tcpip(serverIP,port,'NetworkRole','Client');
    set(tcpipClient,'InputBufferSize',8);
    set(tcpipClient,'OutputBufferSize',pcMetDat.bytes);
    set(tcpipClient,'Timeout',60);
    
    % Save client
     setappdata(0,'tcpipClient',tcpipClient);

    % Open a TCPIP connection to the server
    fopen(tcpipClient);
    disp('Connected to Server');
    disp('Waiting for Commands');
    connections = 1;
end % if server

% Save the number of connections
setappdata(handles.figure1,'connections',connections);


% --- Executes on button press in buttonSaveReference.
function buttonSaveReference_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSaveReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the flag
setappdata(handles.axesCam1,'refAReady',true);

% Hide the button and show the clear reference
set(handles.buttonSaveReference,'Visible','Off');
set(handles.buttonClearReference,'Visible','On');

% Enable the start acquisition button if connections > 0
connections = getappdata(handles.figure1,'connections');

if connections > 0
    set(handles.buttonStartAcq,'Enable','On');
end


% --- Executes on button press in buttonClearReference.
function buttonClearReference_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the flag
setappdata(handles.axesCam1,'refAReady',false);

% Hide the button and show the Save reference
set(handles.buttonSaveReference,'Visible','On');
set(handles.buttonClearReference,'Visible','Off');

% Disable the start acquisition button
set(handles.buttonStartAcq,'Enable','Off');
