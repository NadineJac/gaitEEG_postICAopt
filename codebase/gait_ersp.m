function [Gait_avg, ERDS, GPM, cycle_cnt, si] = gait_ersp(EEG_block, F_Rest,...
    N_freq, f_axis, FWHM,...
    gait_event,gait_timeNextHs, gait_event_order, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%v1.2 Nadine Jacobsen, April 2022: added IC option

% add documentation here

timeNextHs = gait_timeNextHs*EEG_block.srate; % time of next RHS in s

if ~isempty(varargin)
    switch varargin{1}
        case 'EEG'
            data = permute(EEG_block.data, [2,1]); % pnts x chans
            N_comp = EEG_block.nbchan;
        case 'IC'
            EEG_block.icaact = (EEG_block.icaweights*EEG_block.icasphere)*EEG_block.data(EEG_block.icachansind,:);
            data = permute(EEG_block.icaact, [2, 1]); % pnts x chans! --> BS way?
            N_comp = size(EEG_block.icasphere,1);
    end
else %no specification:EEG
    data = permute(EEG_block.data, [2,1]); % pnts x chans
     N_comp = EEG_block.nbchan;
end

% CAR (common average refrence), make sure you have 'clean' data before
data = bsxfun(@minus, data, mean(data,2));

% time frequency transform
TF = morlet_transform_fast(data,[0,1/EEG_block.srate],f_axis,1, FWHM,'n');
TF = abs(TF); %take magnitude (not power), pnts x chans x freqs

idxHS = find(strcmp({EEG_block.event.type}, gait_event));
Gait_TF = zeros(length(idxHS)-1,100,N_comp*N_freq); %strides/trials x pnts x chans x freqs

si = 1; % step counter, increased for each valid step
for cycle_cnt = 1:length(idxHS)-1 % resample each stride to the same legth (100 pnts)
    % find first and last sample of stride
    
    cycle_edge = round([EEG_block.event(idxHS(cycle_cnt)).latency,...
        EEG_block.event(idxHS(cycle_cnt+1)).latency-1]); % first and last frame of gait cycle
    cycle_event = {EEG_block.event([idxHS(cycle_cnt):idxHS(cycle_cnt+1)]).type}; % labels of all events within this cycle
    % only keep labels of gait events to check their order:
    cycle_gaitEvent = cycle_event(contains(cycle_event,gait_event_order));
    if gait_timeNextHs(1) <= cycle_edge(2)-cycle_edge(1) &&... % check time until next HS
            cycle_edge(2)-cycle_edge(1) <= timeNextHs(2) &&...
            all(ismember(gait_event_order,cycle_gaitEvent)) && ...% oder of gait events correct
            all(EEG_block.etc.valid_eeg(cycle_edge(1):cycle_edge(2))) % no high amplitude samples
        TF_cycle = TF(cycle_edge(1):cycle_edge(2),:,:); % extract data
        TF_cycle = reshape(TF_cycle,size(TF_cycle,1),N_comp*N_freq); % reshape to be able to use the resample function, skip but resample over different dimension?
        Gait_TF(si,:,:) = resample(TF_cycle,100,cycle_edge(2)-cycle_edge(1)+1,0); % resample and store
        si = si+1;
    end
end
disp([num2str(round(si/cycle_cnt*100)) '% of the gait cycles are valid'])

% Gait_TF now: strides/trials x pnts + chans x freqs
Gait_TF = reshape(Gait_TF,size(Gait_TF,1),100,N_comp,N_freq); % reshape to trials x pnts x chans x freqs
Gait_avg = squeeze(mean(Gait_TF)); % average over trials

ERDS = 20*bsxfun(@minus,log10(Gait_avg), log10(F_Rest)); % baseline correct to dB power change to standing baseline (also called ERSP)
GPM = bsxfun(@minus,ERDS,mean(ERDS)); % further baseline correct to dB change to mean gait cycle baseline (aka gait power modulation)

end

