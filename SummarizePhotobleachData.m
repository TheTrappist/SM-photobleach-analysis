function numSteps = SummarizePhotobleachData 
% Summarizes photobleaching file data

% user settings:
plotEachTrace = 0;
plotResidenceTimes = 1;

% Histogram plotting settins
autoBinSizes = 0;
manualBinEdges = 0:5:50;


range = 0:5; % range for histogram

files = dir('*.mat');
%fitResult = struct(); % intialize fitResult
numSteps = [];
residenceTimes = [];

for i = 1:length(files)
    
    % get name of current file
    currFileName = files(i).name;
    
    clear fitResult; % to make sure new file contains fitResult
    load(currFileName); % get fitResult from current file
    
    % iterate over traces
    for ii = 1:length(fitResult)
        numSteps = [numSteps; fitResult(ii).numSteps]; %#ok<AGROW>
        if plotEachTrace
            figure;
            [~,Name,Ext] = fileparts(fitResult(ii).fileName);
            subplot(1,2,1); plot(fitResult(ii).intensity(:,1), ...
                fitResult(ii).intensity(:,2));
            title([Name, Ext], 'interpreter', 'none');
            subplot(1,2,2);
            image(fitResult(ii).image,'CDataMapping','scaled');
            colormap(gray);
        end
        
        if plotResidenceTimes
            arrivalTimes = fitResult(ii).startEndTimes(:,1);
            departureTimes = fitResult(ii).startEndTimes(:,2);
            residenceTimesCurr = departureTimes - arrivalTimes;
            residenceTimes = [residenceTimes; residenceTimesCurr]; %#ok<AGROW>
        end
    end

end
clear fitResult

% Plot

[bincounts] = histc(numSteps, range);

hFig = figure;
hBar = bar(range, bincounts, 0.7, 'hist');
hAxes = gca;

set(hAxes, 'FontSize', 14, 'FontName', 'Arial');
set(hBar, 'FaceColor',[0 .5 .5])
xlabel('Number of photobleaching steps')
ylabel('Counts')
title('Photobleaching steps')
xlim([0,5.5]);

if plotResidenceTimes
    if autoBinSizes == 1
        [bincounts, edges] = histcounts(residenceTimes);
    else
        [bincounts, edges] = histcounts(residenceTimes,manualBinEdges);
    end
    
    centers = (edges(2:end)+ edges(1:end-1))./2;
    hFig2 = figure;
    hBar2 = bar(centers, bincounts, 0.7, 'hist');
    hAxes2 = gca;
    
    set(hAxes2, 'FontSize', 14, 'FontName', 'Arial');
    set(hBar2, 'FaceColor',[0 .5 .5])
    xlabel('Residence time (s)')
    ylabel('Counts')
    title('Single-molecule residence times')
end


