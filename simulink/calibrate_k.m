
% Load Simulink parameters
sim_params;
load('calibration_params.mat');

% Open the Simulink model
model_name = "Calibration_model.slx";

omega_val = omega_0*0.9;

%assignin('base', 'omega', omega_val);
simIn = Simulink.SimulationInput(model_name);
simIn = simIn.setVariable('omega', omega_val);
simOut = sim(simIn);


V1 = simOut.logsout{4}.Values.Data(:);
I1 = simOut.logsout{1}.Values.Data(:)*150;
I2 = simOut.logsout{2}.Values.Data(:)*150;
V2 = simOut.logsout{3}.Values.Data(:); 

N = round(0.3 * length(V1));

V2_amp_t = abs(hilbert(V2));
V2_amp = mean(V2_amp_t(N:end-N));

I1_amp_t = abs(hilbert(I1));
I1_amp = mean(I1_amp_t(N:end-N));

fprintf('V_2_amp=: %.30e\n', V2_amp);
fprintf('I_1_amp=: %.20e\n', I1_amp);

Z_M = V2_amp / I1_amp;

fprintf('Z_M=: %.20e\n', Z_M);

M = Z_M/omega_val;
k_est = M/(sqrt(L1*L2)); % lateron replace this with L2 est
fprintf('k_est=: %.20e\n', k_est);



