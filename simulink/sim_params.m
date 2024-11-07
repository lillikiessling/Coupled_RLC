clc; clear;
warning('off', 'SimulinkFixedPoint:util:Overflowoccurred');
%%
fm = 100;                           % Modulation frequency, Hz

k                   = 0.01;          % Coil coupling factor
fc                  = 34.63e3;      % Carrier frequency, Hz

R1                  = 0.26;         % Coil 1 series resitance, Ohm
L1                  = 44.45e-6;     % Coil 1 inductance, H
C1                  = 468e-9;       % Coil 1 series capacitance, F

R2                  = 0.26;         % Coil 2 series resitance, Ohm
L2                  = 44.45e-6;     % Coil 2 inductance, H
C2                  = 468e-9;       % Coil 2 series capacitance, F


max_current         = 150;          % Current sensor max scale, A
driving_voltage     = 48;           % Power supply voltage, V
samples_per_period  = 32*4;         % Number of current sensor samples per period of the carrier wave
phase_nbits         = 16;           % Number of bit represnting phase on the FPGA

sample_time         = 1/(fc*samples_per_period);
deadtime            = 200/(64e6);   % Deadtime of the PWM driver
relative_deadtime = deadtime / (0.5/fc);
