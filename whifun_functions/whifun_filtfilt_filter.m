function ts_f = whifun_filtfilt_filter(b,a,ts)
% Subtract per-row mean, zero NaNs, apply zero-phase filtering, restore mean

mean_ = mean(ts,2);          % compute mean of each row (time series)
ts_f = ts - mean_;           % remove row-wise mean
ts_f(isnan(ts_f)) = 0;       % replace NaNs with zeros for filtering
ts_f = filtfilt(b,a,ts_f');  % apply zero-phase filter along columns (transpose)
ts_f = ts_f';                % transpose back to original orientation
ts_f = ts_f + mean_;         % add the row-wise mean back
end