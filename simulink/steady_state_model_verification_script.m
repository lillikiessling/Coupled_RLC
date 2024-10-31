% Load simulation parameters from sim_params.m script
sim_params;

% Simulink model used for verification
model_name = "steady_state_model_verification.slx";

% Set simulation duration. Should be long enough for system to reach
% steady-state
tmax = 10e-3; % seconds    

% Comparing simulated vs predicted response for different values of k and
% phase differences
k_vals = 0:0.025:0.2;
phi_vals = [0, 0,25, 0.5]; % portion of pi

for phi = phi_vals
    fprintf("At phi = %0.2f*pi:\n", phi);
    % amplitudes and phases of driving PS-PWM voltage of the two RLCs
    D_amp   = [0.5; 0.5];
    D_phase = [-phi/2; phi/2] * pi;     % radians
    
    % complex PS-PWM voltages driving each coil
    D = D_amp .* exp(1i*D_phase);
    
    % calculate the equivalent sinusoidal voltage of the PS-PWM voltage
    V = equivalent_voltage_ps_pwm(D, driving_voltage, relative_deadtime);

    for i = 1:length(k_vals)
        k = k_vals(i); % set current value of k
        out = sim(model_name); % run simulation
        
        % time domain values of current from the stimulation
        t = out.tout; 
        I_t = max_current * [out.logsout{1}.Values.Data(:), ...
                             out.logsout{2}.Values.Data(:)];
        
        % predicted steady-state current using the system_matrix model
        S = system_matrix(fc, k, R1, L1, C1, R2, L2, C2);
        I_ss_pred = S\V; % same as inv(S) * V; frequency domain currents
        % convert to time domain
        I_t_pred = [ 
            abs(I_ss_pred(1)) * sin(2*pi*fc*t + angle(I_ss_pred(1))), ...
            abs(I_ss_pred(2)) * sin(2*pi*fc*t + angle(I_ss_pred(2)))];
    
        
        % calculate prediction error as the mean absolute difference
        % between actual current and predicted current, divided by the
        % predicted current magnitude. Exclude points at beginning of
        % simulation (transient response)
        N1 = round(0.75*size(I_t, 1));
        error = mean(abs(I_t(N1:end, 1) - I_t_pred(N1:end, 1))) ...
            ./ abs(I_ss_pred);
        
        fprintf("\tAt k = %0.3f, prediction error = %0.3f%%  for I1 " + ...
            "and %0.3f%%  for I2\n", k, error(1)*100, error(2)*100);
    end
end
