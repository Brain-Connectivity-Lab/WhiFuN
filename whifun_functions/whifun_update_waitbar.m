% Helper function to update the waitbar
function whifun_update_waitbar(hWaitbar, numIterations)
    persistent count;
    if isempty(count)
        count = 0;
    end
    count = count + 1;
    waitbar(count / numIterations, hWaitbar);
    if count == numIterations
        clear count; % Reset for future use
    end
end