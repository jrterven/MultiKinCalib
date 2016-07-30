function varargout = initialization(varargin)
% INITIALIZATION MATLAB code for initialization.fig
%      INITIALIZATION, by itself, creates a new INITIALIZATION or raises the existing
%      singleton*.
%
%      H = INITIALIZATION returns the handle to a new INITIALIZATION or the handle to
%      the existing singleton*.
%
%      INITIALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INITIALIZATION.M with the given input arguments.
%
%      INITIALIZATION('Property','Value',...) creates a new INITIALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before initialization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to initialization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help initialization

% Last Modified by GUIDE v2.5 30-May-2016 23:25:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @initialization_OpeningFcn, ...
                   'gui_OutputFcn',  @initialization_OutputFcn, ...
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


% --- Executes just before initialization is made visible.
function initialization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to initialization (see VARARGIN)

% Choose default command line output for initialization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes initialization wait for user response (see UIRESUME)
% uiwait(handles.figure1);

initializeServerControls(handles)

% --- Outputs from this function are returned to the command line.
function varargout = initialization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
sel_val=get(handles.listbox1,'value');

% If Server selected
if sel_val==1    
    enableServerControls(handles)
    
    % Disable client controls
    set(handles.uipanel3,'visible','off');
    set(handles.edit8,'string','');
    set(handles.edit9,'string','');   
    
    % Display the IP address
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    set(handles.text20,'string',IPaddress);
% Else if Client selected
else
    set(handles.uipanel3,'visible','on');
    disableServerControls(handles)
    clearServerControls(handles)
end

function initializeServerControls(handles)
    % Initial values
    set(handles.edit1,'string','1');
    set(handles.edit3,'string',pwd);
    set(handles.edit4,'string','10');
    set(handles.edit5,'string','2');
    set(handles.edit6,'string','3');
    set(handles.edit7,'string','60');
    set(handles.checkbox1,'value',0);
    set(handles.checkbox3,'value',1);
    
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    set(handles.text20,'string',IPaddress);
    
function clearServerControls(handles)
    set(handles.edit1,'string','');
    set(handles.edit3,'string','');
    set(handles.edit4,'string','');
    set(handles.edit5,'string','');
    set(handles.edit6,'string','');
    set(handles.edit7,'string','');
    set(handles.checkbox1,'value',0);
    set(handles.checkbox3,'value',0);
    set(handles.text20,'string','');
    
function disableServerControls(handles)
    set(handles.edit1,'enable','off');
    set(handles.edit3,'enable','off');
    set(handles.edit4,'enable','off');
    set(handles.edit5,'enable','off');
    set(handles.edit6,'enable','off');
    set(handles.edit7,'enable','off');
    set(handles.checkbox3,'enable','off');
    set(handles.popupmenu1,'enable','off');
    set(handles.checkbox1,'enable','off');

function enableServerControls(handles)
    set(handles.edit1,'enable','on');
    set(handles.edit3,'enable','on');
    set(handles.edit4,'enable','on');
    set(handles.edit5,'enable','on');
    set(handles.edit6,'enable','on');
    set(handles.edit7,'enable','on');
    set(handles.checkbox3,'enable','on');
    set(handles.popupmenu1,'enable','on');
    set(handles.checkbox1,'enable','on');

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read the value from listbox to determine if it was server or client
sel_val=get(handles.listbox1,'value');

% If Server selected
if sel_val==1    
    % Save data to root directory
    setappdata(0,'role','server');
    setappdata(0,'clientsCount',str2double(get(handles.edit1,'string')));
    dataDir = strrep(get(handles.edit3,'string'),'\','/');
    setappdata(0,'dataDir',dataDir);
    setappdata(0,'countImagesToSave',str2double(get(handles.edit4,'string')));
    setappdata(0,'minDist3D',str2double(get(handles.edit5,'string')));
    setappdata(0,'withSkew',logical(get(handles.checkbox3,'value')));
    contentsDistortRadMenu = cellstr(get(handles.popupmenu1,'string'));           
    distortRad = str2double(contentsDistortRadMenu{get(handles.popupmenu1,'Value')});
    setappdata(0,'distortRad',distortRad);
    setappdata(0,'distortTan',get(handles.checkbox1,'value'));
    setappdata(0,'pointsOnStick',str2double(get(handles.edit6,'string')));
    setappdata(0,'sizeStick',str2double(get(handles.edit7,'string')));            
% if client selected
else
    setappdata(0,'role','client');
    setappdata(0,'clientId',str2double(get(handles.edit9,'string')));
    setappdata(0,'serverIP',get(handles.edit8,'string'));
end

setappdata(0,'setupDataAvail',true);

%on another GUI you want to get the slider properties
%h=findall(0,'tag','textSetupParams');
h = findobj('tag','textSetupParams');
set(h,'String',' ');

figure(main)
close(initialization)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox1


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


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[filename, pathname]=uiputfile('*.jpeg;*.jpg;*.tiff;*.gif;*.bmp;*.png;*.hdf;*.pcx;*.xwd;*.ico;*.cur;*.ras;*.pbm;*.pgm;*.ppm;', 'Save image');
folder_name = uigetdir;
set(handles.edit3,'string',folder_name);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(main)
close(initialization)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('*.mat','Save Setup As');

[patstr, name, ext] = fileparts(file);
if strcmp(ext,'.mat') == 0
    errordlg('The file must be a .mat')
else
    % read the value from listbox to determine if it was server or client
    sel_val=get(handles.listbox1,'value');

    % If Server selected
    if sel_val==1    
        % get data from controls
        role ='server';
        camCount = str2double(get(handles.edit1,'string'));
        countImagesToSave = str2double(get(handles.edit4,'string'));
        dataDir = get(handles.edit3,'string');
        minDist3D = str2double(get(handles.edit5,'string'));
        withSkew = logical(get(handles.checkbox3,'value'));
        contentsDistortRadMenu = cellstr(get(handles.popupmenu1,'string'));           
        distortRad = str2double(contentsDistortRadMenu{get(handles.popupmenu1,'Value')});
        distortRadVal = get(handles.popupmenu1,'Value');
        distortTan = get(handles.checkbox1,'value');
        pointsOnStick = get(handles.edit6,'string');
        sizeStick = str2double(get(handles.edit7,'string'));
        
        % Save the variables in output file
        save([path file],'role','camCount','countImagesToSave','dataDir', ...
            'minDist3D','withSkew','distortRad','distortRadVal', ...
            'distortTan','pointsOnStick','sizeStick');
    % if client selected
    else
        role = 'client';
        clientId = str2double(get(handles.edit9,'string'));
        serverIP = get(handles.edit8,'string');
        
        % Save the variables in output file
        save([path file],'role','clientId','serverIP');
    end
    
    msgbox(['File Saved: ' path file],'File Saved')
end
  
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.mat','Select the Setup file');

[patstr, name, ext] = fileparts(FileName);
if strcmp(ext,'.mat') == 0
    errordlg('The input file must be a .mat')
else
    % load the saved variables into workspace
    load([PathName FileName])
    
    % read the value from listbox to determine if it was server or client
    currentRole = get(handles.listbox1,'value');
    
    % If the data saved was from server
    if strcmp(role,'server')
        % If the role read is server, and the current role is client
        % display an error
        if currentRole ~= 1
            errordlg(['Loading Server data with Client role selected. ' ...
                'Please select the Server role first']);
        % copy the loaded variables into the controls
        else
            set(handles.edit1,'string',num2str(camCount));
            set(handles.edit4,'string',num2str(countImagesToSave));
            set(handles.edit3,'string',dataDir);
            set(handles.edit5,'string',num2str(minDist3D));
            set(handles.checkbox3,'value',withSkew);
            set(handles.popupmenu1,'Value',distortRadVal);
            set(handles.checkbox1,'value',distortTan);
            set(handles.edit6,'string',pointsOnStick);
            set(handles.edit7,'string',num2str(sizeStick));
        end
    else strcmp(role,'client')        
        % If the role read is client, and the current role is server
        % display an error
        if currentRole ~= 2
            errordlg(['Loading Client data with Server role selected. ' ...
                'Please select the Client role first']);
        % copy the loaded variables into the controls
        else
            set(handles.edit9,'string',num2str(clientId));
            set(handles.edit8,'string',serverIP);
        end
    end
end

% --- Executes during object creation, after setting all properties.
function text20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text20.
function text20_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

address = java.net.InetAddress.getLocalHost;
IPaddress = char(address.getHostAddress);
set(handles.text20,'string',IPaddress);
