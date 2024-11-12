% Load Simulink parameters
sim_params;

% Open the Simulink model
model_name = "Calibration_model.slx";

% Define the impedance magnitude function
function Z_mag = impedance_magnitude(omega_val, model_name)
    % Update the MATLAB parameter 'omega' used in Simulink
    assignin('base', 'omega', omega_val);
    simIn = Simulink.SimulationInput(model_name);
    simIn = simIn.setVariable('omega', omega_val);
    simOut = sim(simIn);

    V1 = simOut.logsout{4}.Values.Data(:);
    I1 = simOut.logsout{1}.Values.Data(:)*150;

    N = round(0.2 * length(V1));
    % 
    V1_amp_t = abs(hilbert(V1));
    V1_amp = mean(V1_amp_t(N:end-N));
    % 
    I1_amp_t = abs(hilbert(I1));
    I1_amp = mean(I1_amp_t(N:end-N));

    % exclude the transient
    %peak_V = max(V1(end-1000:end));
    %peak_I = max(I1(end-1000:end));
    %Z_mag = peak_V / peak_I;
    Z_mag = V1_amp/ I1_amp;

    %Z_mag = rms(V1)/ rms(I1);
end

% Golden Section Search function (Linesearch method)
function optimal_omega = golden_section_search(f, a, b, tol, model_name)
    % Golden ratio constant
    phi = (sqrt(5) - 1) / 2;

    % Initial points
    x1 = b - phi * (b - a);
    x2 = a + phi * (b - a);
    f1 = f(x1, model_name);
    f2 = f(x2, model_name);
    
    % Iteratively narrow down the interval
    while abs(b - a) > tol
        if f1 < f2
            b = x2;
            x2 = x1;
            f2 = f1;
            x1 = b - phi * (b - a);
            f1 = f(x1, model_name);
        else
            a = x1;
            x1 = x2;
            f1 = f2;
            x2 = a + phi * (b - a);
            f2 = f(x2, model_name);
        end
    end
    
    % The minimum is approximately at the midpoint of [a, b]
    optimal_omega = (a + b) / 2;
end


% Perform the Golden Section Search
omega_0_est = golden_section_search(@impedance_magnitude, omega_min, omega_max, tol, model_name);

% Get the minimum impedance magnitude
R_est = impedance_magnitude(omega_0_est, model_name);

% Display the result
fprintf('The minimum impedance magnitude is R = %.4f at omega = %.2f rad/s\n', R_est, omega_0_est);

% Close the Simulink model without saving changes
close_system('Calibration_model', 0);

save('calibration_params.mat', 'R_est', 'omega_0_est');