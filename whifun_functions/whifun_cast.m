function [casted_data, additive_offset, multiplicative_scale] = whifun_cast(data, data_type)
    % WHIFUN_CAST Quantizes input data into a specified integer type.
    %
    % INPUTS:
    %   data      - The original double-precision array/matrix
    %   data_type - The target integer type as a string (e.g., 'int16', 'uint8')
    %
    % OUTPUTS:
    %   casted_data - The quantized data in the requested data_type
    %   offset      - The additive offset used for scaling
    %   scale       - The multiplicative scale used for scaling

    % 1. Get the boundaries of the target integer type
    % Cast to double to ensure precision during calculation
    int_min = double(intmin(data_type));
    int_max = double(intmax(data_type));

    % 2. Get the boundaries of the input data
    % data(:) ensures this works regardless of array dimensions
    data_min = min(data(:));
    data_max = max(data(:));

    % 3. Calculate Scale and Offset
    % Check if all elements are the same to avoid divide-by-zero error
    if data_max == data_min
        multiplicative_scale = 1;
        additive_offset = data_min;
    else
        multiplicative_scale = (data_max - data_min)/(int_max - int_min) ;
        additive_offset = data_min - (int_min * multiplicative_scale);
    end

    % 4. Apply formula, round, and cast to the target type
    casted_data = cast(round((data - additive_offset) / multiplicative_scale), data_type);
end