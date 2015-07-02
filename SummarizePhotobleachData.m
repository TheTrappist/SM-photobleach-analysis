function numSteps = AnalyzePhotobleach 
% Summarizes photobleaching file data
plotEachTrace = 1;

range = 0:5; % range for histogram

files = dir('*.mat');
%fitResult = struct(); % intialize fitResult
numSteps = [];

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



