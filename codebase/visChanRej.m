function h = visChanRej(EEG, newChanlocs)
% document
% identify removed channels:
rejChanMask = ismember({EEG.chanlocs.labels}, {newChanlocs.labels});
if all(rejChanMask)
    plotRej = 0;
else
    plotRej = 1;
end

nbChan = EEG.nbchan;

figure(); set(gcf, 'position', [0 0 600 450])

subplot(211); hold on
RMSchan = rms(EEG.data, 2);
mdnRMS = median(RMSchan);
sdRMS = std(RMSchan);

if plotRej; plot(find(~rejChanMask), RMSchan(~rejChanMask),'r*') ; end
plot(find(rejChanMask), RMSchan(rejChanMask),'k.') 

ylim([min(RMSchan)-5, max(RMSchan)+5]); 
yticks([-5:1:5]*sdRMS+mdnRMS); 
yticklabels(string(-5:1:5)); 
ylabel('Difference from median RMS (SD)')

xlim([0 nbChan+1]); 
xticks(1:nbChan); 
xticklabels({EEG.etc.orgChanlocs.labels})
xlabel('Channel')

grid on
title('RMS of kept (gray) and rejected (red) channels')

subplot(212); hold on
h1 = plot(EEG.times, EEG.data(rejChanMask,:),...
    'linestyle', '-', 'color', [.7 .7 .7]); 
if plotRej; h2 = plot(EEG.times, EEG.data(~rejChanMask,:), 'r-'); end
h3 = plot(EEG.times, std(EEG.data), 'k-');
ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
xlim([1 EEG.xmax*1000]), ylim([min(EEG.data,[], 'all') max(EEG.data,[], 'all')]);

if plotRej; legend([h1(1),h2(1),h3(1)], {'kept channels', 'rejected channels', 'GFP'});
else; legend([h1(1),h3(1)], {'kept channels', 'GFP'}); end
legend box off

title('Amplitude of kept (gray) and rejected (red) channels, GFP (black)')

if plotRej
    rmChanLab = strjoin({EEG.chanlocs(~rejChanMask).labels}, ', ');
else
    rmChanLab = 'none';
end
sgtitle({['Channel rejection of ', EEG.filename],...
    ['Removed channels: ' rmChanLab]}, 'interp', 'none')
end

