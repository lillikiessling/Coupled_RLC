function [V] = equivalent_voltage_ps_pwm(D, driving_voltage, relative_deadtime)
% Returns the equivalent sinusoidal voltage of the applied phase-shift PWM 
% voltage. Equivalent voltage amplitude is calculated as the first
% coefficient of the fourier series expansion of the phase-shift PWM
% voltage.
% D: complex number where the magnitude is 2*Tp/T where Tp is the duration
% of positive voltage in the PWM signal and T is the period of the PWM
% signal. The phase of the output equivalent voltage is the same as the
% phase of D

D_amp = abs(D);

% account for deadtime
D_amp = max(D_amp-relative_deadtime,0);

V_amp = (4/pi)*sin((pi/2)*D_amp)*driving_voltage;
V_phase = angle(D);

V = V_amp .* exp(1i*V_phase);

end

