%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%By Abe Davis:
%This code runs a very basic version of the Visual Microphone on high speed
%video of a bag of chips being hit by a linear ramp of frequencies. 
%
%The provided default video (crabchipsRamp.avi) has a very strong signal, 
%so you can still get results if you downsample by a significant factor. 
%The default below is to downsample to 0.1 times the original size, which 
%is enough to make things runable on my laptop in a reasonable amount of 
%time.

%This code does not leverage rolling shutter.
%note that the recovered sound is sampled at 2200Hz, which may not play by
%default in some media players. It will play in MATLAB though.

%this code also uses matlabPyrTools by Eero P. Simoncelli
%parts of it also use the signal processing toolbox

%A lot of the functions pass around objects that represent sounds. They
%have fields:
%'x' - the time signal
%'samplingRate' - the sampling rate.

%This work is based on:
%"The Visual Microphone: Passive Recovery of Sound from Video"
%by Abe Davis, Michael Rubinstein, Neal Wadhwa, Gautham J. Mysore,
%Fredo Durand, and William T. Freeman
%from SIGGRAPH 2014
%
%MIT has a patent pending on this work.
%
%(c) Myers Abraham Davis (Abe Davis), MIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%

%change the below path to wherever you put the VisualMicCode Directory
%cd H:\VisualMicCode

clear
setPath
currentDirectory = pwd;
%dataDir = fullfile('', 'data');%dataDir should be directory to data
dataDir = uigetdir();
vidName = 'crabchipsRamp';
vidExtension = '.avi';
testcasename = vidName;
nscales = 1;
norientations = 2;
dsamplefactor = 0.1; %downsample to 0.1 full size

filename = [vidName vidExtension];

vr = VideoReader(fullfile(dataDir, filename));

%if the video is saved with the actual framerate, you can set as follows. 
%samplingrate = vr.FrameRate;

%otherwise, specify the framerate manually
samplingrate = 2200;

wndw = 80;
olap = 40;


%%
S = vmSoundFromVideo(vr, nscales, norientations, 'SamplingRate', samplingrate,'DownsampleFactor', dsamplefactor);
S.fileName = vidName;

%For very clean videos (loud sound, good magnification) S will already be
%enough. Videos with more noise may not be clean enough to hear the result
%right away, in which case you should try spectral subtraction. The best
%way to do this is manually in software like Adobe Audition, but if that is
%not available you can try our MATLAB implementation.

%%
%show spectrogram and play sound
close all;
spectrogram(S.x, 100, 50)
vmPlaySound(S)

%%
%compute spectral subtraction (often helps with noisier signals)
Sspecsub = vmGetSoundSpecSub(S);

%%
close all;
spectrogram(Sspecsub.x, wndw, olap)
vmPlaySound(Sspecsub)

%%
%in this case you will see that highpassing and spectral subtraction 
%weren't completely necessary, but each helps a little bit.
%The signal is already pretty clear in this video.

%Spectral subtraction seems to take away a bit of signal once the ramp
%starts, but it helps remove noise in the silent portion.

wndw = 80;
olap = 40;

S_unfiltered = S;
S_unfiltered.x = S.aligned;

nc = 3;nr = 2;pn=1;
close all;

subplot(nc,nr,pn);pn=pn+1;
plot(S_unfiltered.x);
title('recovered time signal')
subplot(nc,nr,pn);pn=pn+1;
spectrogram(S_unfiltered.x, wndw, olap)
title('recovered spectrogram')

subplot(nc,nr,pn);pn=pn+1;
plot(S.x);
title('highpass time signal')
subplot(nc,nr,pn);pn=pn+1;
spectrogram(S.x, wndw, olap)
title('highpass spectrogram')

subplot(nc,nr,pn);pn=pn+1;
plot(Sspecsub.x)
title('spec sub time signal')
subplot(nc,nr,pn);pn=pn+1;
spectrogram(Sspecsub.x, wndw, olap)
title('spec sub spectrogram')


%%
vmWriteWAV(S, 'RecoveredSound.wav');

