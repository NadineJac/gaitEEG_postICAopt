function [ERDS_corr, GPM_corr, PSC1, PSC, V] = specPCAdenoising(ERDS, varargin)
% PSCA denoising, removing broadband component
%abapted from Martin Seeber's work
% IN: ERDS (mean gait ERSP, power as dB change to standing BL)
% OUT: ERDS with main component removed

if isempty(varargin) % check whether eigenvalues are Provided, if not calculate from data

% PCA of ERSP --> dim = num freqs
CC = cov(squeeze(mean(ERDS))); %freq x freq

[v, d] = eig(CC);

% find component with greatest eigenvalue
[~, sort_ix] = sort(diag(d),'descend');
V = v(:,sort_ix);
else
    V = varargin{1};
end

Ai = inv(V); % take inverse

% set it to 0
PSC1 = zeros(size(ERDS));
ERDS_corr = zeros(size(ERDS));
PSC = cell(1,length(V));

% loop through all samples and correct them
for t_cnt = 1:size(ERDS,1)
    W = squeeze(ERDS(t_cnt,:,:)) * V;
    
    PSC1(t_cnt,:,:) = W(:,1) * Ai(1,:);
    ERDS_corr(t_cnt,:,:) = W(:,2:end) * Ai(2:end,:);
    for p_cnt = 1:size(W,2)
        if t_cnt==1
          PSC{p_cnt} = zeros(size(ERDS));
        end
        PSC{p_cnt}(t_cnt,:,:)  = W(:,p_cnt) * Ai(p_cnt,:);
    end
    
end

% W2 = V(:,2:end) *Ai(2:end,:);?

GPM_corr = bsxfun(@minus,ERDS_corr,mean(ERDS_corr));
end