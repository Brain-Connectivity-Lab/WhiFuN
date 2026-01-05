function B = whifun_make_unique(A)

B = zeros(size(A));   % output array
countMap = containers.Map('KeyType','double','ValueType','double');

for i = 1:length(A)
    val = A(i);
    if isKey(countMap, val)
        % increment count
        countMap(val) = countMap(val) + 1;
        B(i) = val + countMap(val)/10;   % append .1, .2, .3 etc
    else
        % first occurrence → keep original
        countMap(val) = 0;
        B(i) = val;
    end
end
