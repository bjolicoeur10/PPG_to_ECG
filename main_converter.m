clear all
close all
format long
ppg_name = 'PPGData_pcvipr_0908202315_51_55_913'
ppg_trig_name = 'PPGTrig_pcvipr_0908202315_51_55_913'
ppg_dt = 10e-3; % 10ms sampling time on ppg

newfilename = 'NewGating.full';
gating_name = 'Gating_Track_154541551.pcvipr_track.full';
%gating_name = 'modifiedgatingfiel.full';
%gating_name = newfilename;
out_gating_name = 'modifiedgatingfiel.full';
%7688
% load data
g_tr = 7688e-6 - 3e-6; % tr from  pfile_info ScanArchive_*.h5 print | grep -a imagehead.tr=
g = load_gating(gating_name);
g_time_old = g.time;
g.time = (0:numel(g.time)-1)*g_tr;
%g.time = g.time * 0.9994657


disdaq_time = 1;
effective_tr = 4*g_tr;
pr_disdaqs = 1 + round(disdaq_time / effective_tr);

% 30s time, 1s disdaq
ppg_vals = textread(ppg_name);
ppg_time = (0:numel(ppg_vals)-1)*ppg_dt - 30 - pr_disdaqs*effective_tr;
ppg_trigger = textread(ppg_trig_name);
% check plot


figure
yyaxis left
plot(g.time, g.ecg)
yyaxis right
plot(ppg_time, ppg_vals)
hold on
plot(ppg_time(ppg_trigger), ppg_vals(ppg_trigger),'*')
xlim([0 10])
title('Start of scan')

% check plot
figure
yyaxis left
plot(g.time, g.ecg)
yyaxis right
plot(ppg_time, ppg_vals)
hold on
plot(ppg_time(ppg_trigger), ppg_vals(ppg_trigger),'*')
xlim([max(g.time)-10 max(g.time)])
title('End of scan')

%figure:


% Find index greater than zero 
idx_zero = find(ppg_time>0, 1, 'First')
ppg_trigger_zero = ppg_trigger( ppg_trigger > idx_zero);

% Fit triggers from gating file vs ppg file
[c, idx] = findpeaks(g.ecg);
fit = fitlm(g.time(idx),ppg_time(ppg_trigger_zero(1:numel(g.time(idx)))))

% Estimate time offset between 2 sets (should be slope 1, offset 0)
slope = fit.Coefficients.Estimate(2)
tr_offset = (1-slope)*g_tr

tdelay = fit.Coefficients.Estimate(1)

% numppg = 1:numel(ppg_vals);
% tm = 5000;
% figure
% hold on
% plot(g.time(1:tm),g.ecg(1:tm))
% plot(ppg_time(1:tm),ppg_vals(1:tm))
% hold off



arr = ppg_vals;
threshold = 685;
result = findHighestLocalMaxima(arr, threshold);
patternArray = createPatternArray(result, arr);
% 
temppa = patternArray;
for v = 1:numel(temppa)
    if temppa(v) < 200
        temppa(v) = 200;
    end
end
tt = 1:numel(temppa);
tt = tt * 10e-3;
% figure
% hold on
% plot(tt,patternArray)
% plot(ppg_time,ppg_vals)
% hold off
% figure
% plot(1:numel(g.ecg),g.ecg)





for v = 1:numel(temppa)
    if temppa(v) < 200
        temppa(v) = 200;
    end
end
tt = 1:numel(temppa);
tt = tt * 10e-3;
% figure
% hold on
% % 
% plot(ppg_time,patternArray)
% plot(ppg_time,ppg_vals)
% plot(g.time,g.ecg)
% xlim([50 70])
% hold off
d1 = patternArray;
d2 = ones(1, numel(patternArray)) * 1234;;
d3 = tt;
d4 = ones(1,numel(patternArray));
dsf = numel(g.acq) / numel(patternArray);
ind = round(linspace(1,numel(g.acq),numel(patternArray)));
sm = g.acq(ind);
d5 = sm';
raw2 = [d1,d2,d3,d4,d5]';


fid = fopen('NewGating.full','w');
fwrite(fid, d1,'int32','b');
fwrite(fid, -(d2-4095),'int32','b');
fwrite(fid, d3*1e6,'int32','b');
fwrite(fid, d4,'int32','b');
fwrite(fid, d5,'int32','b');
fclose(fid);

% fid = fopen('NewGating.full');
% raw = fread(fid, 'int32', 'b');
% fclose(fid);

% fid = fopen('Gating_Track_154541551.pcvipr_track.full');
% rawr = fread(fid, 'int32', 'b');
% fclose(fid);

p = load_gating('NewGating.full');
r = load_gating('Gating_Track_154541551.pcvipr_track.full');


