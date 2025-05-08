addpath(genpath('/projects/illinois/las/psych/cgratton/networks-pm/software/bramila'))
addpath('/projects/illinois/las/psych/cgratton/networks-pm/software/nifti')

sequence = 'pilot_bids_cups';
mainpath ='/projects/illinois/las/psych/cgratton/networks-pm/7t'; 
savepath = sprintf('%s/%s/derivatives/tsnr',mainpath, sequence);


files = dir(sprintf('%s/%s/sourcedata',mainpath,sequence));
files = files(3:end);

for i=1:length(files)
    data = load_untouch_nii(sprintf('%s/%s', files(i).folder, files(i).name));

    %make masks
    kk=size(data.img);
    T=kk(4);
    mask =  ones(kk(1:3));
    for t=1:T  
        temp=squeeze(data.img(:,:,:,t));
        mask=mask.*(temp>0.1*quantile(temp(:),.98));
    end

    mask = logical(mask);
    se = strel('sphere',10);
    maskErode = imerode(mask,se);
    CC = bwconncomp(mask,26);
    siz = cellfun(@numel, CC.PixelIdxList);
    [~,idxMax] = max(siz);
    maskBrain = false(size(mask));
    maskBrain(CC.PixelIdxList{idxMax}) = true;

    epi_mask = data;
    epi_mask.img = maskBrain;
    epi_mask.hdr.dime.dim(1)=3;
    epi_mask.hdr.dime.dim(5)=1;
    epi_mask.hdr.dime.pixdim(5)=0;

    save_untouch_nii(epi_mask,sprintf('%s/%s_mask.nii',savepath,files(i).name(1:27)))
    
    %apply mask
    mask = double(mask);
    data_vol= double(data.img);
    vol=zeros(kk);
    for t=1:T
        vol(:,:,:,t)=mask.*data_vol(:,:,:,t); % this can be made faster with reshape
    end

    tsnr_vol = bramila_tsnr(vol);
    epi_mask.img = tsnr_vol;

    save_untouch_nii(epi_mask,sprintf('%s/%s_tsnr.nii',savepath, files(i).name(1:27)))

end

%plot the distribution per session
files = dir(savepath);
files = files(4:2:end);

for i=1:length(files)
    data = load_untouch_nii(sprintf('%s/%s', files(i).folder, files(i).name));
    tsnr_vec(:,i)=data.img(:);
end

tsnr_vec = double(tsnr_vec);
tsnr_vec(tsnr_vec==0)=NaN;

set(0,'DefaultFigureVisible','off')
fig = figure('visible','off');
violinplot(tsnr_vec)
xticklabels({'run-1','run-2','run-3','run-4','run-5','run-6'})
title(sequence)

outfile = fullfile(savepath,[sequence '_tsnr_violin.png']);
print(fig,outfile,'-dpng','-r300')      % or exportgraphics(fig,outfile,'Resolution',300)
close(fig)