function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 18-Aug-2016 11:21:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

displaySetupParams(handles);        

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonSetup.
function buttonSetup_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSetup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialization

% --- Executes on button press in buttonDataAcquisition.
function buttonDataAcquisition_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDataAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataAcq

% --- Executes on button press in buttonPreCalibration.
function buttonPreCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPreCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Step02_PreCalibration(camCount,dataAcqFile,preCalibResultsFile

% --- Executes on button press in buttonMatching.
function buttonMatching_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMatching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Step03_Matching(camCount,dataAcqFile,minDist3D,matchingResultsFile)

% --- Executes on button press in buttonIntrinsicInit.
function buttonIntrinsicInit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonIntrinsicInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Step04_IntrinsicParametersEstimation(camCount,dataAcqFile, ...
    preCalibResultsFile,matchingResultsFile,initIntrinsicsFile)

% --- Executes on button press in buttonNonLinearOptim.
function buttonNonLinearOptim_Callback(hObject, eventdata, handles)
% hObject    handle to buttonNonLinearOptim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Step05_FinalCalibration(camCount,preCalibResultsFile,initIntrinsicsFile,finalCalibResults)

% --- Executes on button press in buttonExit.
function buttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all

function setupData = getSetupData()
    role = getappdata(0,'role');
    
    % If server data
    if strcmp(role,'server')
        camCount = getappdata(0,'clientsCount') + 1;
        dataDir = getappdata(0,'dataDir');
        countImagesToSave = getappdata(0,'countImagesToSave');
        minDist3D = getappdata(0,'minDist3D');
        withSkew = getappdata(0,'withSkew');        
        distortRad = getappdata(0,'distortRad');
        distortTan = getappdata(0,'distortTan');
        pointsOnStick = getappdata(0,'pointsOnStick');
        sizeStick = getappdata(0,'sizeStick');  
        
        setupData = struct('role',role,'camCount',camCount, ...
            'dataDir',dataDir,'countImagesToSave',countImagesToSave, ...
            'minDist3D',minDist3D,'withSkew',withSkew, ...
            'distortRad',distortRad,'distortTan',distortTan, ...
            'pointsOnStick',pointsOnStick,'sizeStick',sizeStick);
    % If client data
    else
        clientId = getappdata(0,'clientId');
        serverIP = getappdata(0,'serverIP');
        
        setupData = struct('role',role,'clientId',clientId,'serverIP',serverIP);
    end      
             
    function displaySetupParams(handles)
        
        setupDataAvail = getappdata(0,'setupDataAvail');

        % If there is not setup data available
        if ~setupDataAvail
            role = 'server';
            camCount = 2;
            dataDir = strrep(pwd,'\','/');
            countImagesToSave = 10;
            minDist3D = 2;
            withSkew = logical(1);        
            distortRad = 0;
            distortTan = logical(0);
            pointsOnStick = 3;
            sizeStick = 30;  
            
            % Save data to root directory
            setappdata(0,'role',role);
            setappdata(0,'camCount',camCount);
            setappdata(0,'dataDir',dataDir);
            setappdata(0,'countImagesToSave',countImagesToSave);
            setappdata(0,'minDist3D',minDist3D);
            setappdata(0,'withSkew',withSkew);            
            setappdata(0,'distortRad',distortRad);
            setappdata(0,'distortTan',distortTan);
            setappdata(0,'pointsOnStick',pointsOnStick);
            setappdata(0,'sizeStick',sizeStick);   
            
            [patstr, name, ext] = fileparts(dataDir);
            dataDirToShow = name;
            
            sd = struct('role',role,'camCount',camCount, ...
            'dataDir',dataDirToShow,'countImagesToSave',countImagesToSave, ...
            'minDist3D',minDist3D,'withSkew',withSkew, ...
            'distortRad',distortRad,'distortTan',distortTan, ...
            'pointsOnStick',pointsOnStick,'sizeStick',sizeStick);
        else
            sd = getSetupData;            
        end
        
        % If server
        msg = '';
        if strcmp(sd.role,'server')
            [patstr, name, ext] = fileparts(sd.dataDir);
            dataDirToShow = name;
            msg = sprintf(['Computer Role: ' sd.role '\n' ...
                'Cameras: ' num2str(sd.camCount) '\n' ...
                'Images to save: ' num2str(sd.countImagesToSave) '\n' ...
                'Output dir: ' dataDirToShow '\n' ...
                'Matching distance: ' num2str(sd.minDist3D) '\n' ...
                'Skew: ' logical2strYN(sd.withSkew) '\n' ...
                'Radial dist coeff: ' num2str(sd.distortRad) '\n' ...
                'Tangential dist: ' logical2strYN(sd.distortTan) '\n' ...
                'Points on calib object: ' num2str(sd.pointsOnStick) '\n' ...
                'Calib object length: ' num2str(sd.sizeStick) 'cm\n']);
        % if client
        else
            msg = sprintf(['Computer Role: ' sd.role '\n' ...
                'Client Id: ' num2str(sd.clientId) '\n' ...
                'Server IP: ' sd.serverIP '\n']);
        end
        
        set(handles.textSetupParams,'string',msg);        

        function str = logical2strYN(l)
            if l
                str = 'yes';
            else
                str = 'no';
            end


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Initialize setupDataAvailable variable
setappdata(0,'setupDataAvail',false);


% --- Executes on button press in buttonPointCloudVis.
function buttonPointCloudVis_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPointCloudVis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
