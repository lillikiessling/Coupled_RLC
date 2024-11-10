% Load Simulink parameters
sim_params;
load('calibration_params.mat');

format long e;
model_name = "Calibration_model.slx";
omega = omega_0_est * 0.1;

simIn = Simulink.SimulationInput(model_name);
simIn = simIn.setVariable('omega', omega);
simOut = sim(simIn);

V1 = simOut.logsout{3}.Values.Data(:);
I1 = simOut.logsout{1}.Values.Data(:)*150;

L1_calc = abs(1i* omega * (I1 * R_est - V1) / (I1 * (omega - omega_0_est) * (omega + omega_0_est)));
C1_calc = abs(1i* I1 * (-omega^2 + omega_0_est^2) / (omega * omega_0_est^2 * (I1 * R_est - V1)));

L1_est = max(L1_calc(:)); 
C1_est = max(C1_calc(:));

fprintf('L1_est (mean): %.20e\n', L1_est);
fprintf('C1_est (mean): %.20e\n', C1_est);

fprintf('L1_real: %.20e\n', L1);
fprintf('C1_real: %.20e\n', C1);
