function V_required = calculate_voltage(I_desired)
    % Assumes parameters are loaded from sim_params.m
    S = system_matrix(fc, k, R1, L1, C1, R2, L2, C2);  % Calculate system matrix
    V_required = S * I_desired; % Use V = S * I to find required voltage
end

function D = calculate_duty_cycle(V_required)
    % Assumes driving_voltage and relative_deadtime are defined in sim_params.m
    D_amp = asin((pi / 4) * V_required / driving_voltage) * 2 / pi;
    % Account for deadtime, ensuring D_amp does not exceed limits
    D_amp = max(D_amp + relative_deadtime, 0);
    D = D_amp * exp(1i * angle(V_required)); % Use desired phase from V_required
end