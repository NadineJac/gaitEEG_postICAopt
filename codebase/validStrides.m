function [numStrides,numValidStrides, percValid, percThresh]  = validStrides(EEG_block, gait_event_order,gait_timeNextHs)
gait_event = gait_event_order{1};
timeNextHs = gait_timeNextHs*EEG_block.srate;
idxHS = find(strcmp({EEG_block.event.type}, gait_event));

%check whether threshold crossings were marked
if isfield(EEG_block.etc, 'valid_eeg')
    marked = 1;
else
    marked = 0;
end

si = 0; % step counter, increased for each valid step
ti = 0;  % step counter, increased for each step within threshold
numValidStrides = 0; %% step counter, increased if both crioteria met
for cycle_cnt = 1:length(idxHS)-1 
    % find first and last sample of stride
    cycle_edge = round([EEG_block.event(idxHS(cycle_cnt)).latency,...
        EEG_block.event(idxHS(cycle_cnt+1)).latency-1]); % first and last frame of gait cycle
    cycle_event = {EEG_block.event([idxHS(cycle_cnt):idxHS(cycle_cnt+1)]).type}; % labels of all events within this cycle
    % only keep labels of gait events to check their order:
    cycle_gaitEvent = cycle_event(contains(cycle_event,gait_event_order));
    if gait_timeNextHs(1) <= cycle_edge(2)-cycle_edge(1) &&... % check time until next HS
            cycle_edge(2)-cycle_edge(1) <= timeNextHs(2) &&...
            all(ismember(gait_event_order,cycle_gaitEvent)) % oder of gait events correct
      si = si+1;
    end
    if marked && all(EEG_block.etc.valid_eeg(cycle_edge(1):cycle_edge(2)))
      ti = ti+1;
    end
    
    if gait_timeNextHs(1) <= cycle_edge(2)-cycle_edge(1) &&... % check time until next HS
            cycle_edge(2)-cycle_edge(1) <= timeNextHs(2) &&...
            all(ismember(gait_event_order,cycle_gaitEvent))&&...
            marked && all(EEG_block.etc.valid_eeg(cycle_edge(1):cycle_edge(2))) %thresh
        numValidStrides = numValidStrides+1;
    end
end

numStrides = cycle_cnt;
percValid = si/cycle_cnt*100;
percThresh = ti/cycle_cnt*100;

disp([num2str(numStrides), ' gait cycles, ',num2str(round(percValid,2)),...
    '%  valid and ', num2str(round(percThresh,2)), '% withing threshold'])
end