clear vis_region vis_value subj

% HAP
subj{1} = 'HAP';
vis_region{1} = [8 56; 11 59; 14 62; 88 40; 96 48];
vis_value{1} = [.8947 .5939 1.1446 -.5039 -.6671];
% LBX
subj{2} = 'LBX';
vis_region{2} = [14 62; 41 89; 54 6; 59 11; 81 33];
vis_value{2} = [.5642 .5677 -.5486 -.6097 -.56];
% MBX
subj{3} = 'MBX';
vis_region{3} = [8 56; 14 62; 15 63; 27 75; 64 16; 86 38; 88 40];
vis_value{3} = [.6211 .713 1.625 1.2123 -.6914 -1.0909 -.5194];
% MJD
subj{4} = 'MJD';
vis_region{4} = [16 64; 57 9; 86 38];
vis_value{4} = [.5049 -.9757 -.7360];
% NSP
subj{5} = 'NSP';
vis_region{5} = [63 15; 83 35];
vis_value{5} = [-.5495 -.5476];
% RTS
subj{6} = 'RTS';
vis_region{6} = [41 89; 82 34];
vis_value{6} = [.6147 -.775];
% TSL
subj{7} = 'TSL';
vis_region{7} = [34 82; 85 37; 92 44];
vis_value{7} = [.6066 -.7685 -1.6959];

% if vis_region{s,r,c) c==1, color red, otherwise c==2, blue

%%
clc
clear red_region_name red_region_size blue_region_name blue_region_size vis_region_num_red vis_region_siz_red vis_region_num_blue vis_region_siz_blue

for s = 1:7
    mask_pair = vis_region{s};
    for row = 1:size(mask_pair,1)
        col = 1;
        if mask_pair(row,col) <=48
            red_region_name(row) = mask_pair(row,col);
            red_region_size(row) = 'L';
        else
            red_region_name(row) = mask_pair(row,col)-48;
            red_region_size(row) = 'R';
        end
        col = 2;
        if mask_pair(row,col) <=48
            blue_region_name(row) = mask_pair(row,col);
            blue_region_size(row) = 'L';
        else
            blue_region_name(row) = mask_pair(row,col)-48;
            blue_region_size(row) = 'R';
        end
    end
    vis_region_num_red{s} = red_region_name;
    vis_region_siz_red{s} = red_region_size;
    vis_region_num_blue{s} = blue_region_name;
    vis_region_siz_blue{s} = blue_region_size;
    %
    value_vector = vis_value{s};
    value_vector_mod = zeros(length(value_vector),1);
    sign_pos = find(value_vector>0);
    sign_neg = find(value_vector<0);
    value_vector_mod(sign_pos) = value_vector(sign_pos) - .5;
    value_vector_mod(sign_neg) = -value_vector(sign_neg) - .5;
    vis_value{s} = value_vector_mod;
end

clear red_region_name red_region_size blue_region_name blue_region_size col row mask_pair

%%
norm_base = max(vis_value{7});

for s = 1:7
    close
    t1 = MRIread(sprintf('~/Desktop/Epilepsy/T1_in_func_%s.nii.gz',subj{s}));
%     t1 = MRIread(sprintf('~/Desktop/Epilepsy/%sRegistered.nii.gz',subj{s}));
        %%
%         base_vol.vol(:,:,1:3) = 0;
%         
%         vol_t1.vol = zeros(size(base_vol.vol));
%         vol_t1.vol(find(base_vol.vol)) = 1;
% %%
%         vol_t1s = smooth3(vol_t1.vol);
%         close
    
%     t1.vol(:,1:32,:) = 0;

    hcap = patch(isosurface(t1.vol(:,:,:,1),.01),...
        'FaceColor',[.9,.9,.9],...
        'EdgeColor','none','FaceAlpha',.2);
    %%
    red_region_name = vis_region_num_red{s};
    red_region_side = vis_region_siz_red{s};
    blue_region_name = vis_region_num_blue{s};
    blue_region_side = vis_region_siz_blue{s};
    
    for mask_index = 1:length(vis_value{s})
        red_mask{mask_index} = MRIread(sprintf('~/Desktop/Epilepsy/%s%sReg%dMask.nii.gz',subj{s},red_region_side(mask_index),red_region_name(mask_index)));
        blue_mask{mask_index} = MRIread(sprintf('~/Desktop/Epilepsy/%s%sReg%dMask.nii.gz',subj{s},blue_region_side(mask_index),blue_region_name(mask_index)));
%         red_mask{mask_index}.vol(:,1:32,:) = 0;
%         blue_mask{mask_index}.vol(:,1:32,:) = 0;
%%

%     hcap = patch(isosurface(t1.vol(:,:,:,1),.01),...
%         'FaceColor',[.9,.9,.9],...
%         'EdgeColor','none','FaceAlpha',.15);
    
%             'FaceColor',[1,.5-value_vector(mask_index)/norm_base,1]/2,...    
        value_vector = vis_value{s};
        hiso = patch(isosurface(smooth3(red_mask{mask_index}.vol),.35),...
            'FaceColor',[1,.5-value_vector(mask_index)/norm_base/2,0],...    
            'EdgeColor','none','FaceAlpha',1);
        set(hiso,'AmbientStrength',.6)
        set(hiso,'SpecularColorReflectance',0,'SpecularExponent',5)

%             'FaceColor',[1,1,value_vector(mask_index)/norm_base],...        
        hiso = patch(isosurface(smooth3(blue_mask{mask_index}.vol),.35),...
            'FaceColor',[.5-value_vector(mask_index)/norm_base/2,.5-value_vector(mask_index)/norm_base/2,1],...    
            'EdgeColor','none','FaceAlpha',1);
        set(hiso,'AmbientStrength',.6)
        set(hiso,'SpecularColorReflectance',0,'SpecularExponent',5)
    end
    
%     lighting GOURAUD
    set(gca,'color',[1,1,1]);
    lighting none
    lightangle(45,10);
    lightangle(260,-20);
    daspect([1 1 1])
    view(140,15)
    set(gca,'Visible','off')
    zoom(1.5)
    axis vis3d
    
    savedir = '~/Desktop/Epilepsy';
    view(0,-90)
    saveas(gca,sprintf('%s/subj %s bottom.png',savedir,subj{s}))
    view(180,0)
    saveas(gca,sprintf('%s/subj %s front.png',savedir,subj{s}))
    view(90,0)
    saveas(gca,sprintf('%s/subj %s side.png',savedir,subj{s}))
    fig_rotate_save(sprintf('%s/subj %s',savedir,subj{s}))
end



%%






















