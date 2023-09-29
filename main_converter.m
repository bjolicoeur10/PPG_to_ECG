clear all
close all
format long
ppg_name = 'PPGData_pcvipr_0908202315_51_55_913'
ppg_trig_name = 'PPGTrig_pcvipr_0908202315_51_55_913'
gating_name = 'Gating_Track_154541551.pcvipr_track_real.full';
new_file_name = 'NewGating.full';
r = load_gating(gating_name);
g = load_gating(gating_name);
g_time_old = g.time;
g_tr = 7688e-6 - 3e-6;
g.time = (0:numel(g.time)-1)*g_tr;
disdaq_time = 1;
effective_tr = 4*g_tr;
pr_disdaqs = 1 + round(disdaq_time / effective_tr);
ppg_dt = 10e-3;
ppg_vals = textread(ppg_name);
ppg_time = (0:numel(ppg_vals)-1)*ppg_dt - 30 - pr_disdaqs*effective_tr;
ppg_trigger = textread(ppg_trig_name);
ppgtt = ppg_time(ppg_trigger);
slope = 1000;

% Custom stop time

stop_time = max(r.time); %max(r.time)


desired_length = numel(r.time); %numel(r.time)

time_step = stop_time / (desired_length - 1);

ecg_array_time = linspace(0, stop_time, desired_length);
ecg_array = zeros(1, desired_length);

current_time = 0;
current_value = 644; % a non zero start time
reset_flag = false;

for t = 1:numel(ecg_array)
    current_value = current_value + slope * time_step;
    current_time = current_time + time_step;

    if any(abs(current_time - ppgtt) < time_step)
        if ~reset_flag
            current_value = 0;
            reset_flag = true;
        end
    else
        reset_flag = false;
    end

    ecg_array(t) = current_value;
    
    if current_time >= stop_time
        break;
    end
end

ecg_array_time = ecg_array_time +0.03;
ecg_array = ecg_array + 200;

%plotting
figure
hold on
% plot(output_array_time, output_array);
plot(r.time,ecg_array)
%plot(r.time,r.ecg)
plot(g.time, r.ecg);
plot(ppg_time(ppg_trigger), ppg_vals(ppg_trigger), '*')
xlim([0 10]) 
xlabel('Time');
ylabel('Value');

d1 = ecg_array;
d2 = 4095 - r.resp;
d3 = r.time * 1e6;
d4 = r.prep;
d5 = r.acq;

fid = fopen('NewGating.full','w');
fwrite(fid, d1,'int32','b');
fwrite(fid, d2,'int32','b');
fwrite(fid, d3,'int32','b');
fwrite(fid, d4,'int32','b');
fwrite(fid, d5,'int32','b');
fclose(fid);

p = load_gating(new_file_name);

