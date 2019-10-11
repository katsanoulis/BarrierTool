function varargout = BarrierTool(varargin)
% BARRIERTOOL MATLAB code for BarrierTool.fig
%      BARRIERTOOL, by itself, creates a new BARRIERTOOL or raises the existing
%      singleton*.
%
%      H = BARRIERTOOL returns the handle to a new BARRIERTOOL or the handle to
%      the existing singleton*.
%
%      BARRIERTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BARRIERTOOL.M with the given input arguments.
%
%      BARRIERTOOL('Property','Value',...) creates a new BARRIERTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before null_geo_Fcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BarrierTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BarrierTool

% Last Modified by GUIDE v2.5 20-Dec-2018 17:16:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BarrierTool_OpeningFcn, ...
                   'gui_OutputFcn',  @BarrierTool_OutputFcn, ...
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


% --- Executes just before BarrierTool is made visible.
function BarrierTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BarrierTool (see VARARGIN)

% adjust GUI window
resolution = get(0,'ScreenSize');
screen_width = resolution(3);
screen_height = resolution(4);
screen_ratio = screen_width/screen_height;
gui_ratio = 1.1;
    
if screen_ratio > 1
    screen_ref = screen_height;
else 
    screen_ref =  screen_width;
end
    
scale_par = 1.7;
gui_width = (screen_ref/scale_par)*gui_ratio;
gui_height = screen_ref/scale_par;

set(gcf,'Units','pixels','Position',[0,0,gui_width,gui_height])

% add path
fp = mfilename('fullpath');
rootdir = fileparts(fp);
if ismac
    s1 = '/..';
elseif ispc
    s1 = '\..';
end
rootdir = strcat(rootdir,s1);
p{1} = fullfile(rootdir,'data');
p{2} = fullfile(rootdir,'doc');
p{3} = fullfile(rootdir,'Main');
p{4} = fullfile(rootdir,'Output');
p{5} = fullfile(rootdir,'Subfunctions');

for i = 1:5
    addpath(rootdir,p{i});
end

%------------------------------------
fprintf('---------------------------------*----------------------------------------\n');
fprintf('data,...doc,...Main,...Output,...Subfunctions,...All paths have been added');
fprintf('\n')
fprintf('---------------------------------*----------------------------------------\n');


handles = diffusive(handles);
handles = interpolationIn2D(handles);
handles = stepsize(handles);
handles.NCores = feature('numcores') - 1;
set(handles.edit17,'string',num2str(handles.NCores));
handles.tensor_file = '';
handles.eulerian = false;
A = cell(1,2);  
A{1,1} = 'Number of intermediate points';
A{1,2} = 'for time averaging:';                                      
mls = sprintf('%s\n%s',A{1,1},A{1,2});
set(handles.text171,'string',mls);

% Choose default command line output for BarrierTool
handles.output = hObject;

% TEXT annotations need an axes as parent so create an invisible axes which
% is as big as the figure

handles.laxis1 = axes('parent',handles.uipanel5,'units','normalized','position',[0 0 1 1],'visible','off');
% Find all static text UICONTROLS whose 'Tag' starts with latex_
lbls = findobj(hObject,'-regexp','tag','latex_*');
for i=1:length(lbls)
      l = lbls(i);
      % Get current text, position and tag
      set(l,'units','normalized');
      s = get(l,'string');
      p = get(l,'position');
      t = get(l,'tag')';
      % Remove the UICONTROL
      delete(l);
      % Replace it with a TEXT object 
      handles.(t) = text(p(1),p(2)+0.09,s,'Interpreter','latex', 'FontUnits', 'normalized', 'Fontsize', 0.16);
end

handles.laxis2 = axes('parent',handles.uipanel4,'units','normalized','position',[0 0 1 1],'visible','off');
% Find all static text UICONTROLS whose 'Tag' starts with latex_
lbls = findobj(hObject,'-regexp','tag','lambda_*');
for i=1:length(lbls)
      l = lbls(i);
      % Get current text, position and tag
      set(l,'units','normalized');
      s = get(l,'string');
      p = get(l,'position');
      t = get(l,'tag')';
      % Remove the UICONTROL
      delete(l);
      % Replace it with a TEXT object 
      handles.(t) = text(p(1),p(2)+0.065,s,'Interpreter','latex', 'FontUnits', 'normalized', 'Fontsize', 0.12);
end

% Update handles structure
guidata(hObject, handles);
%set(gcf, 'units', 'normalized', 'position', [0.05 0.15 0.9 0.8])
% UIWAIT makes BarrierTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BarrierTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,path] = uigetfile('*.mat');
if fileName==0
  return
else
addpath(path);
[handles,check] = loadCG(handles,fileName);
if check
    set(handles.pushbutton2,'string',fileName,'ForegroundColor','blue');
end
handles = computeCGDerivatives(handles);
guidata(hObject,handles)
end

function [handles,check] = loadCG(handles,fileName)
load(fileName,'x1_g','x2_g','C11','C12','C22')
if exist('x1_g','var') && exist('x2_g','var') && exist('C11','var') && exist('C12','var') && exist('C22','var')
    handles.x1_g = x1_g;
    handles.x2_g = x2_g;
    handles.C11 = C11;
    handles.C12 = C12;
    handles.C22 = C22;
    handles.tensor_file = fileName;
    check = true;
else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{12} You chose an input file which does not have the correct variables. Please follow the format described in the manual.', ' File Error', mode);
    check = false;
end

function [handles] = computeCGDerivatives(handles)
handles.trC  = handles.C11 + handles.C22;
detC = handles.C11.*handles.C22-handles.C12.^2;

handles.lam2 = 0.5*handles.trC+sqrt((0.5*handles.trC).^2-detC);

C11_interp = griddedInterpolant({handles.x1_g,handles.x2_g},permute(handles.C11,[2 1]),'spline','linear');
C12_interp = griddedInterpolant({handles.x1_g,handles.x2_g},permute(handles.C12,[2 1]),'spline','linear');
C22_interp = griddedInterpolant({handles.x1_g,handles.x2_g},permute(handles.C22,[2 1]),'spline','linear');

rhox = (handles.x1_g(2)-handles.x1_g(1))*0.2;  
rhoy = (handles.x2_g(2)-handles.x2_g(1))*0.2;

xPlusEpsilon  = handles.x1_g + rhox;
xMinusEpsilon = handles.x1_g - rhox;
yPlusEpsilon  = handles.x2_g + rhoy;
yMinusEpsilon = handles.x2_g - rhoy;
[xPe,y0] = ndgrid(xPlusEpsilon,handles.x2_g);
[xMe,~]  = ndgrid(xMinusEpsilon,handles.x2_g);
[x0,yPe] = ndgrid(handles.x1_g,yPlusEpsilon);
[~,yMe]  = ndgrid(handles.x1_g,yMinusEpsilon);
handles.C11x1 = ((C11_interp(xPe,y0)-C11_interp(xMe,y0))/(2*rhox))';
handles.C11x2 = ((C11_interp(x0,yPe)-C11_interp(x0,yMe))/(2*rhoy))';
handles.C12x1 = ((C12_interp(xPe,y0)-C12_interp(xMe,y0))/(2*rhox))';
handles.C12x2 = ((C12_interp(x0,yPe)-C12_interp(x0,yMe))/(2*rhoy))';
handles.C22x1 = ((C22_interp(xPe,y0)-C22_interp(xMe,y0))/(2*rhox))';
handles.C22x2 = ((C22_interp(x0,yPe)-C22_interp(x0,yMe))/(2*rhoy))';


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.radiobutton2, 'Value', 1);
set(handles.radiobutton3, 'Value', 0);
handles = diffusive(handles);
set(handles.pushbutton13,'string','Load Data Set (Velocity, Time, Domain, Diffusivity)','ForegroundColor','black');
if ~handles.eulerian
    if ~handles.b_h{1,1}
        set(handles.edit82,'Enable','on');
    end
handles.pushbutton3.String = 'Compute Closed Diffusion Barriers';
handles.pushbutton7.String = 'Compute OuterMost Closed Diffusion Barriers and Plot';
handles.pushbutton12.String = 'Advect Closed Diffusion Barriers and Create GIF';
handles.uipanel6.Title = 'Closed Diffusion Barriers';
handles.uipanel12.Title = 'Advection of Closed Diffusion Barriers';
handles.uipanel17.Title = 'Time-Averaged Cauchy-Green Tensor Field';
else
handles.pushbutton3.String = 'Compute Diffusive Instantaneous Barriers';
handles.pushbutton7.String = 'Compute OuterMost Diffusive Instantaneous Barriers and Plot';
handles.pushbutton12.String = 'Advect Diffusive Instantaneous Barriers and Create GIF';
handles.uipanel6.Title = 'Diffusive Instantaneous Barriers';
handles.uipanel12.Title = 'Advection of Diffusive Instantaneous Barriers';
handles.uipanel17.Title = 'Diffusive Flux-Rate Tensor Field';
end
guidata(hObject,handles)


% Hint: get(hObject,'Value') returns toggle state of radiobutton2

function handles = diffusive(handles)
if get(handles.radiobutton2,'Value') == true
    handles.b_h{1,1} = false;
end
handles.l_v = str2double(get(handles.edit6,'String'));
handles.g_v = str2double(get(handles.edit7,'String'));
handles.numberOfLambdas = str2double(get(handles.edit8,'String'));
handles.lamV = linspace(handles.l_v,handles.g_v,handles.numberOfLambdas);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.radiobutton3,'Value') == true
    handles.b_h{1,2} = str2double(get(hObject,'String'));
end
guidata(hObject, handles);
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



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.radiobutton2,'Value') == true
    tmin = str2double(get(hObject,'String'));
    if tmin >= handles.g_v
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a T_0 value smaller than the upper T_0 value.', ' Input Error', mode);
        uiwait(er);
        tminTemporary = num2str(handles.l_v);
        set(handles.edit6,'string',tminTemporary);
    else
        handles.l_v = tmin;
    end
end
guidata(hObject, handles);

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
if get(handles.radiobutton2,'Value') == true
    tmax = str2double(get(hObject,'String'));
    if tmax <= handles.l_v
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a T_0 value greater than the lower T_0 value.', ' Input Error', mode);
        uiwait(er);
        tmaxTemporary = num2str(handles.g_v);
        set(handles.edit7,'string',tmaxTemporary);
    else
        handles.g_v = tmax;
    end
end
guidata(hObject, handles);

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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.radiobutton2,'Value') == true
    handles.numberOfLambdas = str2double(get(handles.edit8,'String'));
end
guidata(hObject, handles);
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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%str2double(get(hObject,'String'))
if get(handles.radiobutton3,'Value') == true
    lmin = str2double(get(hObject,'String'));
    if lmin >= handles.g_v
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a \lambda value smaller than the upper \lambda value.', ' Input Error', mode);
        uiwait(er);
        lminTemporary = num2str(handles.l_v);
        set(handles.edit2,'string',lminTemporary);
    else
        handles.l_v = lmin;
    end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
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
if get(handles.radiobutton3,'Value') == true
    lmax = str2double(get(hObject,'String'));
    if lmax <= handles.l_v
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a \lambda value greater than the lower \lambda value.', ' Input Error', mode);
        uiwait(er);
        lmaxTemporary = num2str(handles.g_v);
        set(handles.edit3,'string',lmaxTemporary);
    else
        handles.g_v = lmax;
    end
end
guidata(hObject, handles);
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
if get(handles.radiobutton3,'Value') == true
    handles.numberOfLambdas = str2double(get(handles.edit4,'String'));
end
guidata(hObject, handles);
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


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.radiobutton2, 'Value', 0);
set(handles.radiobutton3, 'Value', 1);
set(handles.edit82,'Enable','off');
handles.b_h{1,1} = true;
handles.b_h{1,2} = str2double(get(handles.edit1,'String'));
handles.l_v = str2double(get(handles.edit2,'String'));
handles.g_v = str2double(get(handles.edit3,'String'));
handles.numberOfLambdas = str2double(get(handles.edit4,'String'));
handles.lamV = linspace(handles.l_v,handles.g_v,handles.numberOfLambdas);
set(handles.pushbutton13,'string','Load Data Set (Velocity, Time, Domain)','ForegroundColor','black');
if ~handles.eulerian
handles.pushbutton3.String = 'Compute Elliptic Lagrangian Coherent Structures';
handles.pushbutton7.String = 'Compute Lagrangian Vortex Boundaries and Plot';
handles.pushbutton12.String = 'Advect Lagrangian Vortex Boundaries and Create GIF';
handles.uipanel6.Title = 'Elliptic Lagrangian Coherent Structures';
handles.uipanel12.Title = 'Advection of Lagrangian Vortex Boundaries';
handles.uipanel17.Title = 'Cauchy-Green Tensor Field';
else
handles.pushbutton3.String = 'Compute Objective Eulerian Barriers';
handles.pushbutton7.String = 'Compute OuterMost Objective Eulerian Barriers and Plot';
handles.pushbutton12.String = 'Advect Objective Eulerian Barriers and Create GIF';
handles.uipanel6.Title = 'Objective Eulerian Barriers';
handles.uipanel12.Title = 'Advection of Objective Eulerian Barriers';
handles.uipanel17.Title = 'Rate-of-Strain Tensor Field';
end
guidata(hObject,handles)
% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = interpolationIn2D(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox1


function handles = interpolationIn2D(handles)
    if get(handles.checkbox1,'Value') == true
        handles.interpolationIn2D = true;
    else
        handles.interpolationIn2D = false;
    end

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = stepsize(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

function handles = stepsize(handles)
sVec = str2double(get(handles.edit9,'String'));
if sVec > 0.01
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The step size must be lower than 0.01', ' Step Size Error', mode);
    uiwait(er);
    sVecTemporary = num2str(handles.sVec(2));
    set(handles.edit9,'string',sVecTemporary);
else
    handles.sVec = 0:sVec:12;
end


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


% --- Executes on key press with focus on edit2 and none of its controls.
function edit2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Spinner(gcf,'Busy','Start',[615,154,80,80]);

if ~isempty(handles.tensor_file)
    handles.lamV = linspace(handles.l_v,handles.g_v,handles.numberOfLambdas);
%% Step1: Compute r_\lambda(0)=(x_0,\phi0) (cf. eq. (39) of [1])                                          
    [x0lam,y0lam,phi0lam]=r0_lam(handles.lamV,handles.C11,handles.C12,handles.C22,handles.x1_g,handles.x2_g,handles.b_h,handles.eulerian);

    if ~isempty(x0lam)
 %% Step2: Compute \phi'
    % Returns a function handle for \phi'(x,y,\phi) (cf. eq.(38) of [1])
    % and the (x)-dependent functions needed to evaluate its domain of existence V. (cf. eq (37) of [1])
    [C22mC11Gr,C11Gr,C12Gr,C22Gr,phiPrGr]=Phi_prime(handles.C11,handles.C11x1,handles.C11x2,handles.C12,handles.C12x1,handles.C12x2,handles.C22,handles.C22x1,handles.C22x2,handles.x1_g,handles.x2_g,handles.interpolationIn2D);
        %[C22mC11Gr,C12Gr,thetaCGr,phiPrGr]=Phi_prime(C11,C11x1,C11x2,C12,C12x1,C12x2,C22,C22x1,C22x2,x1_g,x2_g,interpolationIn2D);
  
        % Clear unnecessary variables 
        clear handles.C11 handles.C11x1 handles.C11x2 handles.C12 handles.C12x1 handles.C12x2 handles.C22 handles.C22x1 handles.C22x2
 %% Step3: Solve the Initial value null-geodesic problem (cf. eqs. (38-39) of [1])
   
    % Compute closed Null-Geodesics
    [handles.x1Psol,handles.x2Psol] = FindClosedNullGeod(C22mC11Gr,C11Gr,C12Gr,C22Gr,phiPrGr,x0lam,y0lam,phi0lam,handles.x1_g,handles.x2_g,handles.lamV,handles.sVec,handles.NCores,handles.b_h,handles.interpolationIn2D);
    
    %x1 = handles.x1Psol;
    %x2 = handles.x2Psol;
    %save('invariant.mat','x1','x2','xxx','yyy')
    
    Spinner(gcf,'Done','Stop',[615,154,80,80]);
    
    disp(' ')
    disp('Computation of closed Null Geodesics is now completed.')
    %{
    b = msgbox('Computation of closed Null Geodesics is now completed.',' Completion ');
    pos = getpixelposition(handles.figure1,true);
    set(b, 'position', [pos(1)+200 pos(2)+200 320 60]);
    ab = get( b, 'CurrentAxes' );
    ac = get( ab, 'Children' );
    set(ac, 'FontSize', 12);
    %}
    
    clear C22mC11Gr C12Gr phiPrGr x0lam y0lam
    end
else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}','Please specify an input file. '], ' Input File Error ', mode);
end
guidata(hObject, handles);



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Plot all the closed null-geodesics on FTLE
% Write structures    
if ismac
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '/Output/Structures.mat');
elseif ispc
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '\Output\Structures.mat');
end
    x1_g = handles.x1_g;
    x2_g = handles.x2_g;
    x1Psol = handles.x1Psol;
    x2Psol = handles.x2Psol;
    lamV = handles.lamV;
    lam2 = handles.lam2;
    trC = handles.trC;
    b_h = handles.b_h;
    eulerian = handles.eulerian;
    sVec = handles.sVec;
    save(filename,'x1_g','x2_g','x1Psol','x2Psol','lamV','lam2','trC','b_h','eulerian','sVec');
if isfield(handles,'x1Psol')
    PlotAllClosedNullGeodesics(handles.x1Psol,handles.x2Psol,handles.x1_g,handles.x2_g,handles.lamV,handles.lam2,handles.trC,handles.b_h,handles.eulerian)

    % Find Outermost closed null-geodesics 
    [handles.x1LcOutM,handles.x2LcOutM,handles.LamLcOutM] = FindOutermost(handles.x1Psol,handles.x2Psol,handles.lamV,handles.sVec);
    %%
    % Plot Outermost Closed null-geodesics
    PlotOutmost(handles.x1LcOutM,handles.x2LcOutM,handles.LamLcOutM,handles.lamV,handles.x1_g,handles.x2_g,handles.lam2,handles.trC,handles.b_h,handles.eulerian)
else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}', 'Please compute first the Null Geodesics. '], ' Computation Error', mode);
end
    guidata(hObject, handles);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,path] = uigetfile('*.mat');
if fileName==0
  return
else
    addpath(path);
    load(fileName,'xc','yc','vx','vy','time')
    if exist('xc','var') && exist('yc','var') && exist('vx','var') && exist('vy','var') && exist('time','var')
        handles.xc = xc;
        handles.yc = yc;
        handles.vx = vx;
        handles.vy = vy;
        handles.time = time;
        handles = initializeAdvectionDomain(handles);
        handles.velocity_file = fileName;
        guidata(hObject, handles);
        set(handles.pushbutton11,'string',fileName,'ForegroundColor','blue');
    else
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{12} You chose an input file which does not have the correct variables. Please follow the format described in the manual.', ' File Error', mode);
    end
end

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'x1LcOutM')
    if isfield(handles,'velocity_file')
        if ~isempty(handles.LamLcOutM)
            handles = velocityDataAdvection(handles);
            AdvectParticlesAndLCSs(handles)
        else
            mode = struct('WindowStyle','non-modal','Interpreter','tex');
            er = errordlg(['\fontsize{13}', 'No Null Geodesics were detected for the input you have provided. '], ' Computation Error', mode);
        end
    else
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg(['\fontsize{13}','Please specify an input file for the velocity field. '], ' Input File Error ', mode);
    end
else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}', 'Please compute first the Outermost Null Geodesics . '], ' Computation Error', mode);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text5.
function text5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
url = 'http://www.georgehaller.com';
[stat,h] = web(url);


% --- Executes during object creation, after setting all properties.
function text13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = numberOfCores(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double

function handles = numberOfCores(handles)
NCores = str2double(get(handles.edit17,'String'));
NCores = round(NCores);
n = feature('numcores') - 1;
if NCores > n || NCores < 1
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}',num2str(n+1),' cores were detected on your machine. Please specify a number which is greater or equal to 1 and less than ', num2str(n+1) , '. '], ' Number Of Cores Error', mode);
    uiwait(er);
    NCoresTemporary = num2str(handles.NCores);
    set(handles.edit17,'string',NCoresTemporary);
else
    handles.NCores = NCores;
end



% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
xmin = str2double(get(hObject,'String'));
if xmin > max(handles.xc) || xmin < min(handles.xc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Minimum x you selected is out of the computational domain. Please specify your Minimum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    xminTemporary = num2str(handles.xmin);
    set(handles.edit18,'string',xminTemporary);
else
    if xmin >= handles.xmax
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Minimum x value smaller than Maximum x.', ' Input Error', mode);
        uiwait(er);
        xminTemporary = num2str(handles.xmin);
        set(handles.edit18,'string',xminTemporary);
    else
        handles.xmin = xmin;
    end
end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
xmax = str2double(get(hObject,'String'));
if xmax > max(handles.xc) || xmax < min(handles.xc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Maximum x you selected is out of the computational domain. Please specify your Maximum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    xmaxTemporary = num2str(handles.xmax);
    set(handles.edit23,'string',xmaxTemporary);
else
    if xmax <= handles.xmin
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Maximum x value greater than Minimum x.', ' Input Error', mode);
        uiwait(er);
        xmaxTemporary = num2str(handles.xmax);
        set(handles.edit23,'string',xmaxTemporary);
    else
        handles.xmax = xmax;
    end
end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
ymin = str2double(get(hObject,'String'));
if ymin > max(handles.yc) || ymin < min(handles.yc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Minimum y you selected is out of the computational domain. Please specify your Minimum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    yminTemporary = num2str(handles.ymin);
    set(handles.edit24,'string',yminTemporary);
else
    if ymin >= handles.ymax
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Minimum y value smaller than Maximum y.', ' Input Error', mode);
        uiwait(er);
        yminTemporary = num2str(handles.ymin);
        set(handles.edit24,'string',yminTemporary);
    else
        handles.ymin = ymin;
    end
end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
ymax = str2double(get(hObject,'String'));
if ymax > max(handles.yc) || ymax < min(handles.yc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Maximum y you selected is out of the computational domain. Please specify your Maximum y inside this domain.', ' Input Error', mode);
    uiwait(er);
    ymaxTemporary = num2str(handles.ymax);
    set(handles.edit25,'string',ymaxTemporary);
else
    if ymax <= handles.ymin
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Maximum y value greater than Minimum x.', ' Input Error', mode);
        uiwait(er);
        ymaxTemporary = num2str(handles.ymax);
        set(handles.edit25,'string',ymaxTemporary);
    else
        handles.ymax = ymax;
    end
end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
handles.pointsInX = str2double(get(hObject,'String'));
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
handles.pointsInY = str2double(get(hObject,'String'));
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
itime = str2double(get(hObject,'String'));
if itime > max(handles.time) || itime < min(handles.time)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Initial time you selected is out of the computational domain. Please specify your Initial time inside this domain.', ' Input Error', mode);
    uiwait(er);
    itimeTemporary = num2str(handles.itime);
    set(handles.edit28,'string',itimeTemporary);
else
    if itime >= handles.ftime
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify an Initial time smaller than Final time.', ' Input Error', mode);
        uiwait(er);
        itimeTemporary = num2str(handles.itime);
        set(handles.edit28,'string',itimeTemporary);
    else
        handles.itime = itime;
    end
end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'velocity_file')
ftime = str2double(get(hObject,'String'));
if ftime > max(handles.time) || ftime < min(handles.time)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Final time you selected is out of the computational domain. Please specify your Final time inside this domain.', ' Input Error', mode);
    uiwait(er);
    ftimeTemporary = num2str(handles.ftime);
    set(handles.edit29,'string',ftimeTemporary);
else
    if ftime <= handles.itime
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Final time value greater than Initial Time.', ' Input Error', mode);
        uiwait(er);
        ftimeTemporary = num2str(handles.ftime);
        set(handles.edit29,'string',ftimeTemporary);
    else
        handles.ftime = ftime;
    end
end
end
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,path] = uigetfile('*.mat');
if fileName==0
  return
else
addpath(path);
[handles,check] = loadVelocityField(handles,fileName);
if check
    handles = initializeComputationalDomain(handles);
    handles = initializeAdvectionDomain(handles);
    handles.velocity_file = fileName;
    set(handles.pushbutton13,'string',fileName,'ForegroundColor','blue');
    set(handles.pushbutton11,'enable','off')
end
guidata(hObject,handles)
end

function [handles,check] = loadVelocityField(handles,fileName)
if get(handles.radiobutton2,'Value') == true
    load(fileName,'xc','yc','vx','vy','time','D11','D12','D22')
    if exist('xc','var') && exist('yc','var') && exist('vx','var') && exist('vy','var') && exist('time','var') && exist('D11','var')
        handles.xc = xc;
        handles.yc = yc;
        handles.vx = vx;
        handles.vy = vy;
        handles.time = time;
        handles.D11 = D11;
        if numel(D11) > 1
            if exist('D12','var') && exist('D22','var')
                handles.D12 = D12;
                handles.D22 = D22;
                check = true;
            else
                mode = struct('WindowStyle','non-modal','Interpreter','tex');
                errordlg('\fontsize{12} You chose an input file which does not have the correct variables. Please follow the format described in the manual.', ' File Error', mode);
                check = false;
            end
        else
            check = true;
        end
    else
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{12} You chose an input file which does not have the correct variables. Please follow the format described in the manual.', ' File Error', mode);
        check = false;
    end
else
    load(fileName,'xc','yc','vx','vy','time')
    if exist('xc','var') && exist('yc','var') && exist('vx','var') && exist('vy','var') && exist('time','var')
        handles.xc = xc;
        handles.yc = yc;
        handles.vx = vx;
        handles.vy = vy;
        handles.time = time;
        check = true;
    else
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{12} You chose an input file which does not have the correct variables. Please follow the format described in the manual.', ' File Error', mode);
        check = false;
    end
end

function [handles] = initializeComputationalDomain(handles)
handles.xmin = min(handles.xc);
handles.xmax = max(handles.xc);
handles.ymin = min(handles.yc);
handles.ymax = max(handles.yc);
handles.pointsInX = 100;
handles.pointsInY = 100;
handles.itime = min(handles.time);
handles.ftime = max(handles.time);
handles.intermediatePointsForAveraging = 10;

set(handles.edit18,'string',num2str(handles.xmin));
set(handles.edit23,'string',num2str(handles.xmax));
set(handles.edit24,'string',num2str(handles.ymin));
set(handles.edit25,'string',num2str(handles.ymax));
set(handles.edit26,'string',num2str(handles.pointsInX));
set(handles.edit27,'string',num2str(handles.pointsInY));
set(handles.edit28,'string',num2str(handles.itime));
set(handles.edit29,'string',num2str(handles.ftime));
set(handles.edit82,'string',num2str(handles.intermediatePointsForAveraging));

function [handles] = initializeAdvectionDomain(handles)
handles.xminAd = min(handles.xc);
handles.xmaxAd = max(handles.xc);
handles.yminAd = min(handles.yc);
handles.ymaxAd = max(handles.yc);
handles.pointsInXAd = 100;
handles.pointsInYAd = 100;
handles.itimeAd = min(handles.time);
handles.ftimeAd = max(handles.time);

set(handles.edit30,'string',num2str(handles.xminAd));
set(handles.edit31,'string',num2str(handles.xmaxAd));
set(handles.edit32,'string',num2str(handles.yminAd));
set(handles.edit33,'string',num2str(handles.ymaxAd));
set(handles.edit34,'string',num2str(handles.pointsInXAd));
set(handles.edit35,'string',num2str(handles.pointsInYAd));
set(handles.edit36,'string',num2str(handles.itimeAd));
set(handles.edit37,'string',num2str(handles.ftimeAd));


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Spinner(gcf,'Busy','Start',[615,154,80,80]);
if isfield(handles,'velocity_file')
    handles = velocityData(handles);
    handles = computeTensorFieldData(handles);
    handles = writeTensorFieldData(handles);
else
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg(['\fontsize{13}','Please specify an input file for the velocity field. '], ' Input File Error ', mode);
end
Spinner(gcf,'Done','Stop',[615,154,80,80]);

guidata(hObject,handles)

function [handles] = velocityData(handles)

handles.xmin = str2double(get(handles.edit18,'String'));
handles.xmax = str2double(get(handles.edit23,'String'));
handles.ymin = str2double(get(handles.edit24,'String'));
handles.ymax = str2double(get(handles.edit25,'String'));
handles.pointsInX = str2double(get(handles.edit26,'String'));
handles.pointsInY = str2double(get(handles.edit27,'String'));
handles.itime = str2double(get(handles.edit28,'String'));
if ~handles.eulerian
    handles.ftime = str2double(get(handles.edit29,'String'));
    if ~handles.b_h{1,1}
        handles.intermediatePointsForAveraging = str2double(get(handles.edit82,'String'));
    end
end

function [handles] = velocityDataAdvection(handles)
handles.xminAd = str2double(get(handles.edit30,'String'));
handles.xmaxAd = str2double(get(handles.edit31,'String'));
handles.yminAd = str2double(get(handles.edit32,'String'));
handles.ymaxAd = str2double(get(handles.edit33,'String'));
handles.pointsInXAd = str2double(get(handles.edit34,'String'));
handles.pointsInYAd = str2double(get(handles.edit35,'String'));
handles.itimeAd = str2double(get(handles.edit36,'String'));
handles.ftimeAd = str2double(get(handles.edit37,'String'));

function [handles] = writeTensorFieldData(handles)
if ismac
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '/Output/TensorFieldData.mat');
elseif ispc
    filename = fullfile(fileparts(mfilename('fullpath')), '..', '\Output\TensorFieldData.mat');
end
%filename = strcat(parentdir,filename);
    x1_g = handles.x1_g;
    x2_g = handles.x2_g;
    C11 = handles.C11;
    C12 = handles.C12;
    C22 = handles.C22;
    handles.tensor_file = 'TensorFieldData.mat';
    save(filename,'x1_g','x2_g','C11','C12','C22');


function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xminAd = str2double(get(hObject,'String'));
if xminAd > max(handles.xc) || xminAd < min(handles.xc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Minimum x you selected is out of the computational domain. Please specify your Minimum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    xminAdTemporary = num2str(handles.xminAd);
    set(handles.edit30,'string',xminAdTemporary);
else
    if xminAd >= handles.xmaxAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Minimum x value smaller than Maximum x.', ' Input Error', mode);
        uiwait(er);
        xminAdTemporary = num2str(handles.xminAd);
        set(handles.edit30,'string',xminAdTemporary);
    else
        handles.xminAd = xminAd;
    end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
xmaxAd = str2double(get(hObject,'String'));
if xmaxAd > max(handles.xc) || xmaxAd < min(handles.xc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Maximum x you selected is out of the computational domain. Please specify your Maximum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    xmaxAdTemporary = num2str(handles.xmaxAd);
    set(handles.edit31,'string',xmaxAdTemporary);
else
    if xmaxAd <= handles.xminAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Maximum x value greater than Minimum x.', ' Input Error', mode);
        uiwait(er);
        xmaxAdTemporary = num2str(handles.xmaxAd);
        set(handles.edit31,'string',xmaxAdTemporary);
    else
        handles.xmaxAd = xmaxAd;
    end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yminAd = str2double(get(hObject,'String'));
if yminAd > max(handles.yc) || yminAd < min(handles.yc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Minimum y you selected is out of the computational domain. Please specify your Minimum x inside this domain.', ' Input Error', mode);
    uiwait(er);
    yminAdTemporary = num2str(handles.yminAd);
    set(handles.edit32,'string',yminAdTemporary);
else
    if yminAd >= handles.ymaxAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Minimum y value smaller than Maximum y.', ' Input Error', mode);
        uiwait(er);
        yminAdTemporary = num2str(handles.yminAd);
        set(handles.edit32,'string',yminAdTemporary);
    else
        handles.yminAd = yminAd;
    end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ymaxAd = str2double(get(hObject,'String'));
if ymaxAd > max(handles.yc) || ymaxAd < min(handles.yc)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Maximum y you selected is out of the computational domain. Please specify your Maximum y inside this domain.', ' Input Error', mode);
    uiwait(er);
    ymaxAdTemporary = num2str(handles.ymaxAd);
    set(handles.edit33,'string',ymaxAdTemporary);
else
    if ymaxAd <= handles.yminAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Maximum y value greater than Minimum x.', ' Input Error', mode);
        uiwait(er);
        ymaxAdTemporary = num2str(handles.ymaxAd);
        set(handles.edit33,'string',ymaxAdTemporary);
    else
        handles.ymaxAd = ymaxAd;
    end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
itimeAd = str2double(get(hObject,'String'));
if itimeAd > max(handles.time) || itimeAd < min(handles.time)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Initial time you selected is out of the computational domain. Please specify your Initial time inside this domain.', ' Input Error', mode);
    uiwait(er);
    itimeAdTemporary = num2str(handles.itimeAd);
    set(handles.edit36,'string',itimeAdTemporary);
else
    if itimeAd >= handles.ftimeAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify an Initial time smaller than Final time.', ' Input Error', mode);
        uiwait(er);
        itimeAdTemporary = num2str(handles.itimeAd);
        set(handles.edit36,'string',itimeAdTemporary);
    else
        handles.itimeAd = itimeAd;
    end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ftimeAd = str2double(get(hObject,'String'));
if ftimeAd > max(handles.time) || ftimeAd < min(handles.time)
    mode = struct('WindowStyle','non-modal','Interpreter','tex');
    er = errordlg('\fontsize{13} The Final time you selected is out of the computational domain. Please specify your Final time inside this domain.', ' Input Error', mode);
    uiwait(er);
    ftimeAdTemporary = num2str(handles.ftimeAd);
    set(handles.edit37,'string',ftimeAdTemporary);
else
    if ftimeAd <= handles.itimeAd
        mode = struct('WindowStyle','non-modal','Interpreter','tex');
        er = errordlg('\fontsize{13} Please specify a Final time value greater than Initial Time.', ' Input Error', mode);
        uiwait(er);
        ftimeAdTemporary = num2str(handles.ftimeAd);
        set(handles.edit37,'string',ftimeAdTemporary);
    else
        handles.ftimeAd = ftimeAd;
    end
end
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit61_Callback(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit61 as text
%        str2double(get(hObject,'String')) returns contents of edit61 as a double


% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit62_Callback(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit62 as text
%        str2double(get(hObject,'String')) returns contents of edit62 as a double


% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit63_Callback(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit63 as text
%        str2double(get(hObject,'String')) returns contents of edit63 as a double


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit64_Callback(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit64 as text
%        str2double(get(hObject,'String')) returns contents of edit64 as a double


% --- Executes during object creation, after setting all properties.
function edit64_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit68_Callback(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit68 as text
%        str2double(get(hObject,'String')) returns contents of edit68 as a double


% --- Executes during object creation, after setting all properties.
function edit68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit69_Callback(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit70_Callback(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit70 as text
%        str2double(get(hObject,'String')) returns contents of edit70 as a double


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.eulerian = false;
radiobutton2_Callback(handles.radiobutton2,eventdata,handles);
set(handles.radiobutton2,'String','Material Diffusion Barriers');
set(handles.radiobutton3,'String','Lagrangian Coherent Structures');
handles = diffusive(handles);
%set(findall(handles.uipanel12, '-property', 'enable'), 'enable', 'on')
set(handles.edit1,'Enable','on');
set(handles.edit29,'Enable','on');
handles.b_h{1,1} = false;
%if ~handles.b_h{1,1}
    handles.pushbutton3.String = 'Compute Material Diffusion Barriers';
    handles.pushbutton7.String = 'Compute OuterMost Material Diffusion Barriers and Plot';
    handles.pushbutton12.String = 'Advect Material Diffusion Barriers and Create GIF';
    handles.uipanel6.Title = 'Material Diffusion Barriers';
    handles.uipanel12.Title = 'Advection of Material Diffusion Barriers';
    handles.uipanel17.Title = 'Time-Averaged Cauchy-Green Tensor Field';
%{
else
    handles.pushbutton3.String = 'Compute Lagrangian Coherent Structures';
    handles.pushbutton7.String = 'Compute Outermost Lagrangian Coherent Structures and Plot';
    handles.pushbutton12.String = 'Advect Lagrangian Coherent Structures and Create GIF';
    handles.uipanel6.Title = 'Lagrangian Coherent Structures';
    handles.uipanel12.Title = 'Advection of Lagrangian Coherent Structures';
    handles.uipanel17.Title = 'Cauchy-Green Tensor Field';
end
%}
guidata(hObject,handles)
% Hint: get(hObject,'Value') returns toggle state of radiobutton10


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.eulerian = true;
radiobutton2_Callback(handles.radiobutton2,eventdata,handles);
set(handles.radiobutton2,'String','Diffusive Instantaneous Barriers');
set(handles.radiobutton3,'String','Objective Eulerian Barriers');
set(handles.edit82,'Enable','off');
handles.b_h{1,1} = false;
set(handles.edit1,'Enable','off');
set(handles.edit29,'Enable','off');
%set(findall(handles.uipanel12, '-property', 'enable'), 'enable', 'off')
guidata(hObject,handles)
handles.pushbutton3.String = 'Compute Diffusive Instantaneous Barriers';
handles.pushbutton7.String = 'Compute OuterMost Diffusive Instantaneous Barriers and Plot';
handles.pushbutton12.String = 'Advect Diffusive Instantaneous Barriers and Create GIF';
handles.uipanel6.Title = 'Diffusive Instantaneous Barriers';
handles.uipanel12.Title = 'Advection of Diffusive Instantaneous Barriers';
handles.uipanel17.Title = 'Diffusive Flux-Rate Tensor Field';
guidata(hObject,handles)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11



function edit71_Callback(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit71 as text
%        str2double(get(hObject,'String')) returns contents of edit71 as a double


% --- Executes during object creation, after setting all properties.
function edit71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit72_Callback(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit72 as text
%        str2double(get(hObject,'String')) returns contents of edit72 as a double


% --- Executes during object creation, after setting all properties.
function edit72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit73_Callback(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit73 as text
%        str2double(get(hObject,'String')) returns contents of edit73 as a double


% --- Executes during object creation, after setting all properties.
function edit73_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton13


% --- Executes on button press in radiobutton15.
function radiobutton15_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton15



function edit76_Callback(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit76 as text
%        str2double(get(hObject,'String')) returns contents of edit76 as a double


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit75_Callback(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit75 as text
%        str2double(get(hObject,'String')) returns contents of edit75 as a double


% --- Executes during object creation, after setting all properties.
function edit75_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit74_Callback(hObject, eventdata, handles)
% hObject    handle to edit74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit74 as text
%        str2double(get(hObject,'String')) returns contents of edit74 as a double


% --- Executes during object creation, after setting all properties.
function edit74_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit78_Callback(hObject, eventdata, handles)
% hObject    handle to edit78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit78 as text
%        str2double(get(hObject,'String')) returns contents of edit78 as a double


% --- Executes during object creation, after setting all properties.
function edit78_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit79_Callback(hObject, eventdata, handles)
% hObject    handle to edit79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit79 as text
%        str2double(get(hObject,'String')) returns contents of edit79 as a double


% --- Executes during object creation, after setting all properties.
function edit79_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit80_Callback(hObject, eventdata, handles)
% hObject    handle to edit80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit80 as text
%        str2double(get(hObject,'String')) returns contents of edit80 as a double


% --- Executes during object creation, after setting all properties.
function edit80_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit82_Callback(hObject, eventdata, handles)
% hObject    handle to edit82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit82 as text
%        str2double(get(hObject,'String')) returns contents of edit82 as a double


% --- Executes during object creation, after setting all properties.
function edit82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function radiobutton10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
