% Load Simulink parameters
sim_params;
load('calibration_params.mat');  % This should load 'k' if defined in this file

% Open the Simulink model
model_name = "Calibration_model.slx";

omega_val = omega_0 * 0.1;  % Assuming omega_0 is already defined


function Z_mag = impedance_magnitude(omega_val, model_name, driving_voltage, k)
    % Update the MATLAB parameter 'omega' used in Simulink
    assignin('base', 'omega', omega_val);
    simIn = Simulink.SimulationInput(model_name);
    simIn = simIn.setVariable('omega', omega_val);
    simIn = simIn.setVariable('k_calibrate', k);
    simIn = simIn.setVariable('V_calibrate_1', driving_voltage);  % Using driving_voltage
    simIn = simIn.setVariable('V_calibrate_2', 0);
    simOut = sim(simIn);

    % Extract simulation outputs
    V1 = simOut.logsout{3}.Values.Data(:);
    I1 = simOut.logsout{1}.Values.Data(:) * 150;  % Scaling factor

    % Define window to exclude transient effects
    N = round(0.2 * length(V1));

    % Compute magnitudes using the Hilbert transform
    V1_amp_t = abs(hilbert(V1));
    V1_amp = mean(V1_amp_t(N:end-N));

    I1_amp_t = abs(hilbert(I1));
    I1_amp = mean(I1_amp_t(N:end-N));

    % Compute impedance magnitude
    Z_mag = V1_amp / I1_amp;
end

% Ensure 'omega', 'k', and other parameters are set for the Simulink simulation
simIn = Simulink.SimulationInput(model_name);
simIn = simIn.setVariable('omega', omega_val);
simIn = simIn.setVariable('k_calibrate', k);  % Set k here for calibration
simIn = simIn.setVariable('V_calibrate_1', driving_voltage);  % Assuming driving_voltage is defined
simIn = simIn.setVariable('V_calibrate_2', 0);

% Run the simulation
simOut = sim(simIn);

% Extract simulation outputs
V1 = simOut.logsout{4}.Values.Data(:);
I1 = simOut.logsout{1}.Values.Data(:) * 150;
I2 = simOut.logsout{2}.Values.Data(:) * 150;
V2 = simOut.logsout{3}.Values.Data(:);

% Define window to exclude transient effects
N = round(0.3 * length(V1));

% Compute magnitudes using Hilbert transform
V2_amp_t = abs(hilbert(V2));
V2_amp = mean(V2_amp_t(N:end-N));

I1_amp_t = abs(hilbert(I1));
I1_amp = mean(I1_amp_t(N:end-N));

I2_amp_t = abs(hilbert(I2));
I2_amp = mean(I2_amp_t(N:end-N));

% Print results
fprintf('V_2_amp: %.30e\n', V2_amp);
fprintf('I_1_amp: %.20e\n', I1_amp);

% Compute impedance magnitude (Z2) and mutual inductance (M)
Z2 = impedance_magnitude(omega_val, model_name, driving_voltage, k);
M = I2_amp * Z2 / (omega_val * I1_amp);
fprintf('M: %.20e\n', M);

% Estimate 'k' using mutual inductance and inductances
k_est = M / sqrt(L1_est * L2);  % Assuming L1_est and L2 are defined
fprintf('k: %.20e\n', k_est);
