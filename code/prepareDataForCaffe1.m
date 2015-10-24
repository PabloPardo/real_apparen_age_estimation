

%% TRAIN MODEL USING:
%       LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scratch_net/ehtor/rrothe/bin/anaconda/lib
%       export LD_LIBRARY_PATH
%       /home/rrothe/git/caffe/caffe_gpu/build/tools/caffe train -solver /home/rrothe/git/chalearn/code/models/age_classification_solver_gpu.prototxt -weights /home/rrothe/git/chalearn/code/data/bvlc_reference_caffenet.caffemodel
%       watch -n10 nvidia-smi

%clear all; load data/imdb_images.mat; results=batch_processImages(full_path); save('data/imdb_resultss_with_landmarks_conf.mat');
%clear all; load data/wiki_images.mat; results=batch_processImages(full_path); save('data/wiki_resultss_with_landmarks_conf.mat');

%% Load images path, detect faces and face landmarks
% [imgpath,age,std]=load_csv('../data/fgnet_chalearn_apparent_db.csv','data/all/');
% results=batch_processImages(imgpath); save('../data/fgnet_chalearn_apparent_resultss_with_landmarks_conf.mat');

%load('data/AGE_IDX_SPLIT.mat')
%ORIG_IDX_SPLIT=IDX_SPLIT;


%USE_ORIG_SPLIT=0;

%imgpath=load_img_from_folder();
%results=batch_processImages(imgpath); save('data/chalearn_resultss_with_landmarks_conf_test.mat');

%% Set Parameters
PREFIX='1';             % Prefix to the generated files
NR_NETWORKS=82;         % Number of Networks

% TRAIN_SET_SIZE=0.9;     % Percentage of data used to train
LANDMARKS_CONF_TH=0.1;  % Landmark confidence threshold

% Path to images data
% CHALEARN_IMG='data/fgnet_chalearn_apparent_resultss_with_landmarks_conf.mat';
CHALEARN_IMG='../data/fgnet_landmark_conf.mat';

[fp1,fp2,fp3]=fileparts(CHALEARN_IMG);
CHALEARN_NEW_PATH=[fp1 '/' PREFIX '_' fp2 fp3];
copyfile(CHALEARN_IMG,CHALEARN_NEW_PATH,'f');



%% Load data
img_info_chalearn=load(CHALEARN_IMG);

%% Define type of images 
%  Not sure what for ...
% M1 is the set of faces with ¿low? confidence threshold
% M2 is the set of faces with ¿high? confidence threshold

img_type_chalearn=zeros(length(img_info_chalearn.age),1);

for i=1:length(img_info_chalearn.age)
    if ~isnan(img_info_chalearn.results{i}.main_face_score) && img_info_chalearn.results{i}.valid_face && img_info_chalearn.age(i)>=0 && img_info_chalearn.age(i)<=100
        if  img_info_chalearn.results{i}.valid_landmarks && img_info_chalearn.results{i}.landmarks_conf<LANDMARKS_CONF_TH
            img_type_chalearn(i)=2;
        else
            img_type_chalearn(i)=1;
        end
    end
end

%% Split the data
% Split the data into 82 folds

IDX_SPLIT=ones(length(img_info_chalearn.age),NR_NETWORKS);

for i=1:NR_NETWORKS
    % Find images of subject 'i'
    idx=find(arrayfun(@(i) img_info_chalearn.results{i}.ind, 1:numel(img_info_chalearn.results))~=i);
    
    % Discard images with not detected face
%     idx(img_type_chalearn(idx)==0)=[];
    
    IDX_SPLIT(idx, i)=0;
end
% for i=0:100
%     idx=find(img_info_chalearn.age==i);
%     idx(img_type_chalearn(idx)==0)=[];
%     for j=1:NR_NETWORKS
%         idx=idx(randperm(length(idx)));
%         IDX_SPLIT(idx(1:ceil(length(idx)*TRAIN_SET_SIZE)),j)=0;
%     end
% end


%% Save the training files

% - Why from 11 to NR_NETWORKS? 
%   Could we change it from 1 to NR_NETWORKS and set NR_NETWORKS to 5?
% - What are the aguments? I guess it uses different face augmentations to
%   train ... are they necessary? 
%for j=11:NR_NETWORKS
for j=1:NR_NETWORKS
    
    save_training_file([PREFIX '_' num2str(j) '_age_m1_chalearn'],'%s_face.jpg',img_info_chalearn.imgpath,....
        img_info_chalearn.age,IDX_SPLIT(:,j),[1],0);

    %save_training_file([PREFIX '_age_m1_chalearn_fulltrain'],'%s_face.jpg',img_info_chalearn.imgpath,....
    %    img_info_chalearn.age,zeros(length(IDX_SPLIT),1),[1],0);

    save_training_file([PREFIX  '_' num2str(j) '_age_m1_chalearn_aug'],'%s_face.jpg',img_info_chalearn.imgpath,....
        img_info_chalearn.age,IDX_SPLIT(:,j),[1],10,'%s_aug_%d_face.jpg');

end

save(CHALEARN_NEW_PATH,'IDX_SPLIT', '-append')






%% Show face Images
%for i=1:min(length(train_test_split_m1),length(train_test_split_m2));
%    figure(1)
%    subplot(1,2,1)
%    imshow(imread(filepath_m1{i}));
%    title('M1');
%   subplot(1,2,2)
%   imshow(imread(filepath_m2{i}));
%    title('M2');
%    waitforbuttonpress
%end