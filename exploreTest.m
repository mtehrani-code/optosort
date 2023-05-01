

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%% Old data
%------------------------------------------------------------------------
%{
% data locations

% Data for 1382_20191212_02_02_3200 has good recordings on 
% Channels 4, 5, 11, 14
rawPath = '~/Work/Data/TestData/MT';
rawFile = '1382_20191212_02_02_3200_FREQ_TUNING.dat';
Channels = [4 5];

%
% Test WAV data
% 1382_20191212_02_02_3200_WAV.dat
% 1382_20191212_02_02_3200_WAV_PSTH.fig
% 1382_20191212_02_02_3200_WAV_wavinfo.mat
% Channels 4, 5, 11, 14
%{
rawPath = '~/Work/Data/TestData/MT';
rawFile = '1382_20191212_02_02_3200_WAV.dat';
Channels = [4 5];
%}
% data for FRA - this is correct data to use for testing as it was
% collected using updated FRA routine in opto program
%{
rawPath = '/Volumes/Wenstrup Laboratory/By User/SJS/Data/SpikeSort/IC-probe';
rawFile = '1407_20200305_01_01_550_FRA.dat';
Channels = 8;
%}

% create opto file name object (helps to create new file names for these
% data)

fI = OptoFileName(fullfile(rawPath, rawFile));

%% load data

%{
% loading mat file
tmpF = fullfile('~/Work/Data/TestData/MT', ...
			fI.newname(  sprintf('Chan%d-%d_TracesByStim', ...
														Channels(1), Channels(end)), ...
 							'mat') );
load(tmpF);
%}
%}
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%% load data
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% specify file to examine
%  path, dat file, _testdata.mat file
%------------------------------------------------------------------------
if strcmpi(computer, 'GLNXA64')
   dpath = '/media/sshanbhag/SSData/Data/Mouse/Raw/BLA/1500/20230213';
else
   dpath = '/Volumes/SSData/Data/Mouse/Raw/BLA/1500/20230213';
end
% dname = '1500_20230213_01_0_3352_BBN.dat';
% tname = '1500_20230213_01_0_3352_BBN_testdata.mat';
dname = '1500_20230213_01_0_3352_WAV.dat';
tname = '1500_20230213_01_0_3352_WAV_testdata.mat';

% define path to data file
F = defineSampleData({dpath}, {dname}, {tname});

%------------------------------------------------------------------------
% get the data and information from the raw files
%	cSweeps is a {nfiles, 1} cell array with each element holding an
% 	{nChannels X ntrials} cell array of data for each file
%	nexInfo is an instance of a SpikeInfo object
%
% use empty values for BPfilt (arg 3) and resampleData (arg 4) so 
% that no filtering or resampling is done
%------------------------------------------------------------------------
Channels = 1:16;
nChannels = length(Channels);
%------------------------------------------------------------------------
% filter parameters for raw neural data
%------------------------------------------------------------------------
% [highpass lowpass] cutoff frequencies in Hz
BPfilt.Fc = [250 4000];
% order of filter. note that the filtfilt() function in MATLAB is used,
% so the effective order is doubled. typically use 5
BPfilt.forder = 5;
% ramp time (ms) to apply to each sweep in order to cutdown on onset/offset
% transients from filtering
BPfilt.ramp = 1;
% filter type. 'bessel' or 'butter' (for butterworth). typically use butter
% as bessel is low-pass only and we need to remove low frequency crap from
% the raw data
BPfilt.type = 'butter';
resampleData = [];

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%% read and filter data, no resampling
%------------------------------------------------------------------------
%------------------------------------------------------------------------
[cSweeps, nexInfo] = read_data_for_export(F, Channels, ...
                                                BPfilt, resampleData);
                 
%------------------------------------------------------------------------
% get stimulus information
%------------------------------------------------------------------------
onset = nexInfo.FileInfo{1}.Dinf.audio.Delay;
offset = onset + nexInfo.FileInfo{1}.Dinf.audio.Duration;

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%% test multichanplot
%------------------------------------------------------------------------
%------------------------------------------------------------------------
fNum = 1;

% select trial
trialN = 15;

% get trial information
if strcmpi(nexInfo.FileInfo{fNum}.testname, 'BBN')
   if strcmpi(nexInfo.FileInfo{fNum}.testtype, 'LEVEL')
      testvar = nexInfo.FileInfo{fNum}.Dinf.test.stimcache.LEVEL;
   end
else
   error('unsupport testname %s', nexInfo.FileInfo{fNum}.testname);
end

%{
% transform cell array to matrix with time bins in rows, channels by column
T = cell2mat(D)';
% apply common average referencing to data
Ta = common_avg_ref(T);
% apply common median referencing to data
Tm = common_med_ref(T);
%}

%%


Fs = 0.001*nexInfo.Fs;

% NOTE 1 May 2023: to simplify this, need to create vectors 1:Ntrials
% with:
%        stimulus type (BBN or WAV name)
%        stimulus level
%        stimulus [onset offset]
dataExplore(cSweeps, nexInfo)



%%

%{
%% this is essentially multichanplot code


% get a single trial data in a matrix
data = cell2mat(cSweeps{fNum}(:, trialN))';

yLim = [min(data(:)) max(data(:))];
channels = 1:size(data,2);
% srate = 1;

L = size(data,1);
loc = 1;
yInterv = [];
yTotal = [];
nChan = [];
% x (time) axis vector
T = (1:L) / srate;

select_on = false;
curr_select = 0;

% plot data


h_fig = figure;
% set(h_fig,'KeyPressFcn',@f_KeyPress);

% this is from update_data
yInterv = yLim(2)-yLim(1);
nChan = length(channels);
yTotal = yInterv * nChan;

% this is from plotfig

yStart = (nChan:-1:1)*yInterv-(yInterv/2);

dataWin = bsxfun(@plus, data, yStart);

% create axes
h_ax = axes(h_fig, 'Position',[0.1 0.125 0.8 0.75]);
plot(h_ax, T, dataWin);
set(h_ax,'ytick',yStart(end:-1:1),'yticklabel',channels(end:-1:1))
ylim([0 yTotal]);
xlim([T(1) T(end)]);

set(get(h_ax,'children'),'hittest','off');

%}





%%




%{
multichanplot(T, 250, 'srate', 0.001*nexInfo.Fs)


return

%% plot data in explorable form

stimNames = unique(Dinf.test.wavlist, 'stable');

tracesByStim = Traces{1};
spikesByStim = spikes{1};

stimNum = 1;
sweepNum = 1;
stimTraces = tracesByStim{stimNum};
sweepData = stimTraces(:, sweepNum)';

[nPts, nTraces] = size(tracesByStim{currentStim});
fH = figure('Units','Normalized','Position',[0.25 0.25 0.5 0.5]);
aH =   axes('Units','Normalized','Position',[0.05 0.15, 0.75 0.75]);
stimCtrlH = uicontrol(fH, 'Style','listbox','Units','Normalized', ...
							'Position',[0.85 0.15, 0.1, 0.75],...
							'String', stimNames, ...
							 'Callback',{@changeStim, aH, sweepNum, stimTraces} );



%%
%{
function changeChannel(l,evtData,a,s,data)
	cla(a);
	chanNum = str2double(l.String{l.Value});
	%500Hz
	sR = 500;  
	%Reshape each epoch into a column
	tempData = reshape(data(chanNum,:,:),[],size(data,3)); 
	%Build time array
	tempTime = [0:1/sR:(size(data,2)-1)/sR]' + (0:1:size(data,3)-1)*2; 
	%plot all the lines
	plot(a,tempTime,tempData)
	%Rest Slider Position
	s.Value = 1; 
end
%}

%}