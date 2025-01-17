function  handles = renderEpochSpectrogram(handles)
%Plot current spectrogram window

handles.data.lastWindowPosition = handles.data.windowposition;

if handles.data.settings.spect.nfft == 0
    handles.data.settings.spect.nfft = handles.data.settings.spect.nfftsmp/handles.data.audiodata.SampleRate;
    handles.data.settings.spect.windowsize = handles.data.settings.spect.windowsizesmp/handles.data.audiodata.SampleRate;
    handles.data.settings.spect.noverlap = handles.data.settings.spect.noverlap/handles.data.audiodata.SampleRate;
elseif handles.data.settings.spect.nfftsmp == 0
    handles.data.settings.spect.nfftsmp = handles.data.settings.spect.nfft*handles.data.audiodata.SampleRate;
    handles.data.settings.spect.windowsizesmp = handles.data.settings.spect.windowsize*handles.data.audiodata.SampleRate;
end
handles.data.saveSettings();
windowsize = round(handles.data.audiodata.SampleRate * handles.data.settings.spect.windowsize);
noverlap = round(handles.data.audiodata.SampleRate * handles.data.settings.spect.noverlap);
nfft = round(handles.data.audiodata.SampleRate * handles.data.settings.spect.nfft);

if noverlap >= windowsize
    warning('Overlap must be less than window size - automatically reducing to window size-1')
    noverlap = windowsize-1;
end

%% Get audio within the page range, padded by focus window size
window_start = max(handles.data.windowposition - handles.data.settings.focus_window_size/2, 0);
window_stop = handles.data.windowposition + handles.data.settings.pageSize + handles.data.settings.focus_window_size/2;
audio = handles.data.AudioSamples(window_start, window_stop);

%% Make the spectrogram
[s, f, t] = spectrogram(audio,windowsize,noverlap,nfft,handles.data.audiodata.SampleRate,'yaxis');
t = t + window_start; % Add the start of the window the time units
s_display = scaleSpectrogram(s, handles.data.settings.spect.type, windowsize, handles.data.audiodata.SampleRate);

%% Denoise
if handles.data.bDenoise
    minval = min(s_display,[],'all');
    ind_reset = s_display - handles.data.medspec;
    s_display(ind_reset<0) = minval;
end

%% Find the color scale limits
% handles.data.clim = prctile(s_display(20:10:end-20, 1:20:end),[10,90], 'all')';
% handles.data.clim = prctile(handles.data.clim,90,1);
% clim = handles.data.clim + range(handles.data.clim) * [.1, 1] * handles.data.settings.spectrogramContrast;

%% Plot Spectrogram in the page view
% set(handles.spectrogramWindow,...
%     'Xlim', [handles.data.windowposition, handles.data.windowposition + handles.data.settings.pageSize],...
%     'Ylim',[handles.data.settings.LowFreq, min(handles.data.settings.HighFreq, handles.data.audiodata.SampleRate/2000)]);
set(handles.spectrogramWindow,...
    'Xlim', [handles.data.windowposition, handles.data.windowposition + handles.data.settings.pageSize],...
    'Ylim',f([1,end])/1000);
set(handles.epochSpect,'CData',s_display,'XData', t, 'YData',f/1000);

% If StTime exists as a variable, and there are calls to display, and the
% contents of StTime are datetime format, set start time of the file to the StTime of
% the first call in the audio file - the # of seconds into file the call is
if height(handles.data.calls) > 0 && ...
        any(strcmp('StTime', handles.data.calls.Properties.VariableNames)) && ...
        ~isempty(handles.data.thisaudst) && ~isempty(handles.data.thisaudend) && ...
        isa(handles.data.calls.StTime(handles.data.thisaudst),'datetime') && ...
        ~isnat(handles.data.calls.StTime(handles.data.thisaudst))
    sttime = handles.data.calls.StTime(handles.data.thisaudst) - handles.data.calls.Box(handles.data.thisaudst,1)/86400;
else
    sttime = 0;
end
    
% set(handles.spectrogramWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim', clim);
set_tick_timestamps(handles.spectrogramWindow,false,sttime);


%% Plot Spectrogram in the focus view
% set(handles.focusWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',[0 get_spectrogram_max(hObject,handles)]);
set(handles.focusWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1])
% set(handles.spect,'Parent',handles.focusWindow);
% set(handles.spect,'CData',zoomed_s,'XData', zoomed_t,'YData',zoomed_f/1000);


%% Send the spectrogram back to handles
handles.data.page_spect.s = s;
handles.data.page_spect.f = f;
handles.data.page_spect.t = t;
handles.data.page_spect.s_display = s_display;

