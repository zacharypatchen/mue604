[cleanAudio,fs] = audioread("SpeechDFT-16-8-mono-5secs.wav");
sound(cleanAudio,fs)

noise = audioread("WashingMachine-16-8-mono-1000secs.mp3");

% Extract a noise segment from the noise file

noiseSegment = noise(1:length(cleanAudio));

speechPower = sum(cleanAudio.^2);
noisePower = sum(noiseSegment.^2);
noisyAudio = cleanAudio + sqrt(speechPower/noisePower)*noiseSegment;

% listen
sound(noisyAudio,fs)

%This example uses a subset of the Mozilla Common Voice dataset to 
% train and test the deep learning networks. The data set contains 48 kHz 
% recordings of subjects speaking short sentences. Download the data set 
% and unzip the downloaded file.
% https://commonvoice.mozilla.org/en/datasets

downloadFolder = matlab.internal.examples.downloadSupportFile("audio","commonvoice.zip");
dataFolder = tempdir;
unzip(downloadFolder,dataFolder)
dataset = fullfile(dataFolder,"commonvoice");


%Use audioDatastore to create a datastore for the training set. To speed up 
% the runtime of the example at the cost of performance, set speedupExample 
% to true.
adsTrain = audioDatastore(fullfile(dataset,"train"),IncludeSubfolders=true);
speedupExample = true;
if speedupExample
    adsTrain = shuffle(adsTrain);
    adsTrain = subset(adsTrain,1:1000);
end

%Use read to get the contents of the first file in the datastore.
[audio,adsTrainInfo] = read(adsTrain);

%Listen to the speech signal.
sound(audio,adsTrainInfo.SampleRate);

%Plot the speech signal.
t = (1/adsTrainInfo.SampleRate) * (0:numel(audio)-1);
plot(t,audio)

