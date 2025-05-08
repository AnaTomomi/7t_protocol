addpath(genpath('/projects/illinois/las/psych/cgratton/networks-pm/software/bramila'))
addpath('/projects/illinois/las/psych/cgratton/networks-pm/software/nifti')

sequence = 'pilot_bids_cups';
mainpath ='/projects/illinois/las/psych/cgratton/networks-pm/7t'; 
savepath = sprintf('%s/%s/derivatives/tsnr',mainpath, sequence);


files = dir(sprintf('%s/%s/sourcedata',mainpath,sequence));
masks = files(4:3:end);
files = files(5:3:end);

for i=1:length(files)
    data = load_untouch_nii(sprintf('%s/%s', files(i).folder, files(i).name));
    files(i).name

    %read mask
    mask_data = load_untouch_nii(sprintf('%s/%s', masks(i).folder, masks(i).name));
    
    %apply mask
    kk=size(data.img);
    T=kk(4);

    mask = double(mask_data.img);
    data_vol= double(data.img);
    vol=zeros(kk);
    for t=1:T
        vol(:,:,:,t)=mask.*data_vol(:,:,:,t); % this can be made faster with reshape
    end

    tsnr_vol = bramila_tsnr(vol);
    mask_data.img = tsnr_vol;

    save_untouch_nii(mask_data,sprintf('%s/%s_tsnr-after.nii',savepath, files(i).name(1:27)))

end

%plot the distribution per session
% files = dir(savepath);
% files = files(4:2:end);
% 
% for i=1:length(files)
%     data = load_untouch_nii(sprintf('%s/%s', files(i).folder, files(i).name));
%     tsnr_vec(:,i)=data.img(:);
% end
% 
% tsnr_vec = double(tsnr_vec);
% tsnr_vec(tsnr_vec==0)=NaN;
% 
% set(0,'DefaultFigureVisible','off')
% fig = figure('visible','off');
% violinplot(tsnr_vec)
% xticklabels({'run-1','run-2','run-3','run-4','run-5','run-6'})
% title(sequence)
% 
% outfile = fullfile(savepath,[sequence '_tsnr_violin.png']);
% print(fig,outfile,'-dpng','-r300')      % or exportgraphics(fig,outfile,'Resolution',300)
% close(fig)
