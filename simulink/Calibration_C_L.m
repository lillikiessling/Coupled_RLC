% Main script
sim_params;
load('calibration_params.mat');

format long e;
model_name = "Calibration_model.slx";
omega = omega_0_est * 0.1;

% Configuration 1: V1 is driving voltage, V2 is 0
[L1_est, C1_est] = calculate_LC(driving_voltage, 0, model_name, omega, R_est, omega_0_est);

% Configuration 2: V1 is 0, V2 is driving voltage
[L2_est, C2_est] = calculate_LC(0, driving_voltage, model_name, omega, R_est, omega_0_est);

% Display the results
fprintf('Iteration %d:\n', i);
fprintf('L1_est: %.20e, C1_est: %.20e\n', L1_est, C1_est);
fprintf('L2_est: %.20e, C2_est: %.20e\n', L2_est, C2_est);


% Save final estimates
save('calibration_params.mat', 'L1_est', 'C1_est', 'L2_est', 'C2_est');

%% Function Definition
function [L_est, C_est] = calculate_LC(V1_in, V2_in, model_name, omega, R_est, omega_0_est)
    % Function to calculate L and C based on input voltages
    % V1_in, V2_in: Input voltages
    % model_name: Simulink model file (string)
    % omega: Operating frequency
    % k: Calibration constant
    % R_est: Estimated resistance
    % omega_0_est: Resonant frequency
    
    % Set up simulation input
    simIn = Simulink.SimulationInput(model_name);
    simIn = simIn.setVariable('omega', omega);
    simIn = simIn.setVariable('k_calibrate', 0);
    simIn = simIn.setVariable('V_calibrate_1', V1_in);
    simIn = simIn.setVariable('V_calibrate_2', V2_in);
    simOut = sim(simIn);

    % Extract outputs
    V1 = simOut.logsout{3}.Values.Data(:);
    V2 = simOut.logsout{4}.Values.Data(:);
    I1 = simOut.logsout{1}.Values.Data(:) * 150;
    I2 = simOut.logsout{2}.Values.Data(:) * 150;

    % Determine which configuration is being used
    N = round(0.2 * length(V1));
    
    if V2_in == 0  % Calculating L1, C1
        V_amp_t = abs(hilbert(V1));
        V_amp = mean(V_amp_t(N:end-N));
        
        I_amp_t = abs(hilbert(I1));
        I_amp = mean(I_amp_t(N:end-N));
        
        L_calc = abs(1i * omega * (I_amp * R_est - V_amp) / (I_amp * (omega - omega_0_est) * (omega + omega_0_est)));
        C_calc = abs(1i * I_amp * (-omega^2 + omega_0_est^2) / (omega * omega_0_est^2 * (I_amp * R_est - V_amp)));
        
        L_est = max(L_calc(:)); 
        C_est = max(C_calc(:));
        
    elseif V1_in == 0  % Calculating L2, C2
        V_amp_t = abs(hilbert(V2));
        V_amp = mean(V_amp_t(N:end-N));
        
        I_amp_t = abs(hilbert(I2));
        I_amp = mean(I_amp_t(N:end-N));
        
        L_calc = abs(1i * omega * (I_amp * R_est - V_amp) / (I_amp * (omega - omega_0_est) * (omega + omega_0_est)));
        C_calc = abs(1i * I_amp * (-omega^2 + omega_0_est^2) / (omega * omega_0_est^2 * (I_amp * R_est - V_amp)));
        
        L_est = max(L_calc(:)); 
        C_est = max(C_calc(:));
    else
        error('Invalid input configuration: Either V1 or V2 must be zero');
    end
end
