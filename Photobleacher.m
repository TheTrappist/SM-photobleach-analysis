function varargout = Photobleacher(varargin)
% PHOTOBLEACHER MATLAB code for Photobleacher.fig
% Sequentially plots the output of the SubunitCount ImageJ macro, allowing
% the user to either reject a trace or accept it and manually assign the
% number of photobleaching steps. The output is then saved as a single
% mat-file that can be used for further processing.
%
% Notes: since this GUI subtracts background from traces, the user must
% select a background point in the SubunitCount macro following each "real"
% point. This GUI assumes that every second trace is a background trace
% corresponding to the preceding "real" trace.
%


% Last Modified by GUIDE v2.5 02-Jul-2015 15:02:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Photobleacher_OpeningFcn, ...
                   'gui_OutputFcn',  @Photobleacher_OutputFcn, ...
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


% --- Executes just before Photobleacher is made visible.
function Photobleacher_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Photobleacher (see VARARGIN)

% Choose default command line output for Photobleacher
handles.output = hObject;

handles.currChoice = 'None'; % used to determine if user accepted or 
                             % rejected the current trace

handles.fitResult = 'None';


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Photobleacher wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Photobleacher_OutputFcn(~, ~, handles) 


% Get default command line output from handles structure
varargout{1} = handles.output;


function AcceptStep_Callback(hObject, ~, handles)

handles.currChoice = 'Accept';
guidata(hObject, handles);

uiresume;


function RejectStep_Callback(hObject, ~, handles)

handles.currChoice = 'Reject';
guidata(hObject, handles);

uiresume;

function AddDataPoint_Callback(hObject, ~, handles)

handles.currChoice = 'AddDataPt';
guidata(hObject, handles);

uiresume;

% --- Executes on button press in ChooseDir.
function ChooseDir_Callback(hObject, ~, handles)

[fileName,pathName,~] = uigetfile({'*_selectionCoords.txt', ...
    'Coordinate file'}, ...
    'Please choose file with coordinates of all dots', 'Coordinate file');

disp(pathName)
disp(fileName)

imgFileDir =[pathName, 'Images\'];
traceFileDir =[pathName, 'Traces\'];
baseFileName = strrep(fileName, '_selectionCoords.txt','');
imageFiles = dir([imgFileDir,baseFileName,'_avgImage*.png']);
intensityFiles = dir([traceFileDir,baseFileName,'_profile*.txt']);
disp(imageFiles);

coordFile = fopen([pathName,fileName]);
pointCoords = cell2mat(textscan(coordFile, '%f%f', 'CollectOutput', 1));
fclose(coordFile);

frameDuration = str2double(get(handles.FrameDuration, 'string'));
fitResult = struct([]); %structure storing all results
ctr2 = 1; % counter for appending data to fitResult

for i = 1:2:length(intensityFiles)
    img = imread([imgFileDir,imageFiles(i).name]);
    axes(handles.SpotImage);
    image(img,'CDataMapping','scaled'); colormap(gray);
    
    intFile = fopen([traceFileDir,intensityFiles(i).name]);
   
    
    % Read data
    textscan(intFile, '%s', 1); % Skip the first line
    intensityText = textscan(intFile, '%f%f', 'CollectOutput', 1);
    rawIntensity = cell2mat(intensityText);
    fclose(intFile);
    
    % Read background data
    backgroundFile = fopen([traceFileDir,intensityFiles(i+1).name]);
    textscan(backgroundFile, '%s', 1); % Skip the first line
    background = cell2mat(textscan(backgroundFile, '%f%f',...
                                                    'CollectOutput', 1));
    fclose(backgroundFile);
    
    intensity = rawIntensity;
    intensity(:,2) = rawIntensity(:,2) - background(:,2);
    
    plot(handles.StepPlot, intensity(:,1), intensity(:,2));
    
    nextSpot = 0;
    startEndTimes = []; % to keep track of arrival and departure times

    
    while nextSpot == 0
        
        uiwait;
        handles = guidata(hObject); % read updated handles structure
        disp(handles.currChoice);
        
        if strcmp(handles.currChoice, 'Accept') % accept fit
            numStepsOptions = get(handles.NumSteps, 'String');
            numStepsSel = get(handles.NumSteps, 'Value');
            numSteps = str2double(numStepsOptions{numStepsSel});
            
            
            % add info to fitResult:
            fitResult(ctr2).numSteps = numSteps;
            fitResult(ctr2).startEndTimes = startEndTimes;
            fitResult(ctr2).fileName = [pathName,intensityFiles(i).name];
            fitResult(ctr2).backgroundFileName = ...
                [pathName,intensityFiles(i+1).name];
            fitResult(ctr2).pointCoord = pointCoords(i,:);
            fitResult(ctr2).backgroundCoord = pointCoords(i+1,:);
            fitResult(ctr2).intensity = intensity;
            fitResult(ctr2).rawIntensity = rawIntensity;
            fitResult(ctr2).background = background;
            fitResult(ctr2).image = img;
            fitResult(ctr2).frameRateHz = 1/frameDuration;
            
            ctr2 = ctr2 + 1;
            
            nextSpot = 1;
          
        elseif strcmp(handles.currChoice, 'AddDataPt')
            tempTimes = zeros(1,3);
            
            numStepsOptions = get(handles.NumSteps, 'String');
            numStepsSel = get(handles.NumSteps, 'Value');
            numSteps = str2double(numStepsOptions{numStepsSel});
            
            startTime = str2double(get(handles.StartFrame, 'String')) ...
                * frameDuration;
            endTime = str2double(get(handles.EndFrame, 'String')) ...
                * frameDuration;
            
            tempTimes(1) = startTime;
            tempTimes(2) = endTime;
            tempTimes(3) = numSteps;
            
            startEndTimes = [startEndTimes; tempTimes];  %#ok<AGROW>
            
        else 
            
            nextSpot = 1;
            
        end
        
        set(handles.StartFrame, 'String', '');
        set(handles.EndFrame, 'String', '');
        
    end
    
    handles.currChoice = 'None';
    guidata(hObject, handles);
end

uisave('fitResult', 'PhotobleacherResult.mat');

guidata(hObject, handles);



function StartFrame_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function StartFrame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndFrame_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function EndFrame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameDuration_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function FrameDuration_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumSteps.
function NumSteps_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function NumSteps_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
