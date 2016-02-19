function varargout = threedimrotvis(varargin)
% THREEDIMROTVIS MATLAB code for threedimrotvis.fig
%      THREEDIMROTVIS, by itself, creates a new THREEDIMROTVIS or raises the existing
%      singleton*.
%
%      H = THREEDIMROTVIS returns the handle to a new THREEDIMROTVIS or the handle to
%      the existing singleton*.
%
%      THREEDIMROTVIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THREEDIMROTVIS.M with the given input arguments.
%
%      THREEDIMROTVIS('Property','Value',...) creates a new THREEDIMROTVIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before threedimrotvis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to threedimrotvis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help threedimrotvis

% Last Modified by GUIDE v2.5 19-Feb-2016 13:32:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threedimrotvis_OpeningFcn, ...
                   'gui_OutputFcn',  @threedimrotvis_OutputFcn, ...
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


% --- Executes just before threedimrotvis is made visible.
function threedimrotvis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to threedimrotvis (see VARARGIN)

% Choose default command line output for threedimrotvis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes threedimrotvis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = threedimrotvis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axTarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axTarget
aRotation = rotz(0)*roty(0)*rotx(0);
vAxesX = aRotation*[1; 0; 0];
vAxesY = aRotation*[0; 1; 0];
vAxesZ = aRotation*[0; 0; 1];
plot3(...
     [0, vAxesX(1)], [0, vAxesX(2)], [0, vAxesX(3)], 'r-' ... % Changable x-axis
    ,[0, vAxesY(1)], [0, vAxesY(2)], [0, vAxesY(3)], 'g-' ... % Changeable y-axis
    ,[0, vAxesZ(1)], [0, vAxesZ(2)], [0, vAxesZ(3)], 'b-' ... % Changeable z-axis
    ,[0, vAxesX(1)], [0, vAxesX(2)], [0, vAxesX(3)], 'r--' ... % Reference x-axis
    ,[0, vAxesY(1)], [0, vAxesY(2)], [0, vAxesY(3)], 'g--' ... % Reference y-axis
    ,[0, vAxesZ(1)], [0, vAxesZ(2)], [0, vAxesZ(3)], 'b--' ... % Reference z-axis
    , 'Parent', hObject ...
);

set(hObject, 'XLim', [-1.1, 1.1], 'YLim', [-1.1, 1.1], 'ZLim', [-1.1, 1.1]);
set(hObject, 'View', [20, 20]);
set(hObject, 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on');
xlabel(hObject, 'x');
ylabel(hObject, 'y');
zlabel(hObject, 'z');
set(hObject, 'Box', 'on');
    


% --- Executes on slider movement.
function sliderX_Callback(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

setRotation(hObject, eventdata, handles);
set(handles.textRotXValue, 'String', sprintf('%3.0f', get(hObject, 'Value')));


% --- Executes during object creation, after setting all properties.
function sliderX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'Min', -360);
set(hObject, 'Max', 360);
set(hObject, 'SliderStep', [1/(2*get(hObject, 'Max')), 0.01]);


% --- Executes on slider movement.
function sliderY_Callback(hObject, eventdata, handles)
% hObject    handle to sliderY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

setRotation(hObject, eventdata, handles);
set(handles.textRotYValue, 'String', sprintf('%3.0f', get(hObject, 'Value')));


% --- Executes during object creation, after setting all properties.
function sliderY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'Min', -360);
set(hObject, 'Max', 360);
set(hObject, 'SliderStep', [1/(2*get(hObject, 'Max')), 0.01]);


% --- Executes on slider movement.
function sliderZ_Callback(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

setRotation(hObject, eventdata, handles);
set(handles.textRotZValue, 'String', sprintf('%3.0f', get(hObject, 'Value')));


% --- Executes during object creation, after setting all properties.
function sliderZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'Min', -360);
set(hObject, 'Max', 360);
set(hObject, 'SliderStep', [1/(2*get(hObject, 'Max')), 0.01]);

function setRotation(hObject, eventdata, handles)
% hObject    handle to sliderZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dRotationX = get(handles.sliderX, 'Value');
dRotationY = get(handles.sliderY, 'Value');
dRotationZ = get(handles.sliderZ, 'Value');

aRotation = rotz(dRotationZ)*roty(dRotationY)*rotx(dRotationX);
vAxesX = aRotation*[1; 0; 0];
vAxesY = aRotation*[0; 1; 0];
vAxesZ = aRotation*[0; 0; 1];

hLines = get(handles.axTarget, 'Children');

set(hLines(6), 'XData', [0, vAxesX(1)], 'YData', [0, vAxesX(2)], 'ZData', [0, vAxesX(3)]);
set(hLines(5), 'XData', [0, vAxesY(1)], 'YData', [0, vAxesY(2)], 'ZData', [0, vAxesY(3)]);
set(hLines(4), 'XData', [0, vAxesZ(1)], 'YData', [0, vAxesZ(2)], 'ZData', [0, vAxesZ(3)]);


% --- Executes during object creation, after setting all properties.
function textRotXValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRotXValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', '0');


% --- Executes during object creation, after setting all properties.
function textRotYValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRotXValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', '0');


% --- Executes during object creation, after setting all properties.
function textRotZValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRotXValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', '0');
