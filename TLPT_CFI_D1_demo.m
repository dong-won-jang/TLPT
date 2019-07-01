% parameters
picRow=4; % Number of sub lipimages via row
picCol=5; % Number of sub lipimages via col
L=picRow*picCol; % Number of sub lipimages in the CFI
lambda=0.1; % lambda
CFISize=224;
subRow=CFISize/picRow; % sub image height
subCol=CFISize/picCol; % sub image width these will be resized final CFI making
mode='nearest'; % nearest or bilinear
% mode='bilinear'; % nearest or bilinear

% load data
dataroot='images';
imageList=ls(fullfile(dataroot,'*.png'));
numimg=size(imageList,1);

mkdir('results');

% For example Rs=1, Re=end of utterance
Rs=1;
Re=numimg;

% TLPT step 1: generating random sections
var=max(floor(numimg*lambda),1); 
varList=-var:1:var; % possible values of alpha and beta
nk = nchoosek([varList varList],2);
p=zeros(0,2);
for i=1:size(nk,1) % All possible pairs of alpha and beta
    pi = perms(nk(i,:)); 
    p = unique([p; pi],'rows', 'stable'); % unique pairs only
end

% reference section is always at first CFI for convenience of test sequence
for i=1:numel(p)
    if norm(p(i,:)) == 0
        idx=i;
        break;
    end
end
p=[p(idx,:);p]; 
p(idx+1,:)=[];

% TLPT step 2: making CFIs
for rnd=1:size(p,1)
    s=Rs+p(rnd,1);
    e=Re+p(rnd,2);
    T=e-s+1;
    n=1:L;
    l=s+ceil(n.*T./L)-1; % new index using (2)
    phi_l=max(min(l,numimg),1); %clipping using (3)

    temp_idx=1;
    CFI=cell(picRow,picCol);
    for i=phi_l
        img=imresize(imread(fullfile(dataroot,imageList(i,:))),[subRow,subCol]);
        CFI{ceil(temp_idx/picCol), temp_idx-picCol*floor(temp_idx/(picCol+10^-8))}=img;
        temp_idx=temp_idx+1;
    end
    D1=imresize(uint8(cell2mat(CFI)),[CFISize,CFISize]);
    str = sprintf('results/%04d.png',rnd);
    imwrite(D1, str, 'png');
end