addpath(genpath('/projects/illinois/las/psych/cgratton/networks-pm/software/bramila'))
addpath('/projects/illinois/las/psych/cgratton/networks-pm/software/nifti')

sequence = 'pilot_bids_sms';
mainpath ='/projects/illinois/las/psych/cgratton/networks-pm/7t'; 
savepath = sprintf('%s/%s/derivatives/tsnr',mainpath, sequence);


files = dir(savepath);
before = files(5:3:end);
after = files(4:3:end);

for i=1:length(before)
    data_a = load_untouch_nii(sprintf('%s/%s', after(i).folder, after(i).name));
    after(i).name
    data_b = load_untouch_nii(sprintf('%s/%s', before(i).folder, before(i).name));
    before(i).name
    tsnr_bef(:,i)=data_b.img(:);
    tsnr_aft(:,i)=data_a.img(:);
end

clear data_a
clear data_b

tsnr_bef = double(tsnr_bef);
tsnr_bef(tsnr_bef==0)=NaN;

tsnr_aft = double(tsnr_aft);
tsnr_aft(tsnr_aft==0)=NaN;

session_labels = {'run-1','run-2','run-3','run-4','run-5','run-6'};

set(0,'DefaultFigureVisible','off');                     
fig = figure('visible','off','Units','pixels','Position',[100 100 1200 500]);

% ---- subplot 1: before -------------------------------------------------
subplot(1,2,1);
boxplot(tsnr_bef);
xticklabels(session_labels);
title('before');

% ---- subplot 2: after --------------------------------------------------
subplot(1,2,2);
boxplot(tsnr_aft);
xticklabels(session_labels);
title('after');

% ---- save as PDF -------------------------------------------------------
outpdf = sprintf('%s/%s.pdf',savepath,sequence);
fig.PaperUnits   = 'inches';
w = 11;  h = 4.5;                % wide landscape strip
fig.PaperSize     = [w h];       % physical page size
fig.PaperPosition = [0 0 w h];   % use the whole page

print(fig,outpdf,'-dpdf','-bestfit');   % or use '-fillpage'
close(fig);
