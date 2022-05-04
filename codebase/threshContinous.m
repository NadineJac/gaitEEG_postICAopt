function EEG = threshContinous(EEG, V_tsh)

%% mark segments w/ extreme values (exceeding threschold V_tsh)
% will be stored in EEG.etc.valid_eeg

EEG.etc.valid_eeg = true(EEG.pnts,1); % edit these indices later to keep samples out of analysis

bad_seg = find(any(abs(EEG.data) > V_tsh));
bad_EEG = false(EEG.pnts,1);

for bad_cnt = 1:length(bad_seg) % loop through all bad samples
    % keep data anyway if it is within the edges that will be cut later anyway
    if bad_seg(bad_cnt) > round(EEG.srate) && bad_seg(bad_cnt) <= EEG.pnts - round(EEG.srate)
        bad_EEG(bad_seg(bad_cnt)-round(EEG.srate):bad_seg(bad_cnt)+round(EEG.srate)) = true;
    elseif bad_seg(bad_cnt) <= round(EEG.srate)
        bad_EEG(1:bad_seg(bad_cnt)+round(EEG.srate)) = true;
    elseif bad_seg(bad_cnt) > EEG.pnts - round(EEG.srate)
        bad_EEG(bad_seg(bad_cnt)-round(EEG.srate):bad_seg(end)) = true;
    end
end

EEG.etc.valid_eeg(bad_EEG) = false;
disp( [ num2str(round(1e4*sum(EEG.etc.valid_eeg)/ EEG.pnts)/100) '% valid'])
end


