clear all
clc
dataset = load('uci-dataset/cancer2.mat');
dataset=dataset.dataset;
%% pre-processing / 1-of-S output encoding scheme
labels = unique(dataset.ytrain{1});
code = zeros(length(labels), length(labels));
nLabels=length(labels);
for j = 1: length(labels),
    code(j, j) = 1;
end
for i = 1: 1,
    for j = length(labels):-1:1,
        ind = (dataset.ytrain{i} == labels(j));
        ind2 = (dataset.ytest{i} == labels(j));
        ind3 = (dataset.yval{i} == labels(j));
        tam = length(find(ind==1));
        tam2 = length(find(ind2==1));
        tam3 = length(find(ind3==1));
        dataset_ytrain{i}(ind, :) = repmat(code(j, :), tam, 1);
        dataset_ytest{i}(ind2, :) = repmat(code(j, :), tam2, 1);    
        dataset_yval{i}(ind3, :) = repmat(code(j, :), tam3, 1);  
    end
end
X=dataset.xtrain{1};
y=dataset_ytrain{1};
obj = recursiveLS;
[theta,EstimatedOutput] = step(obj,dataset.yval{1},dataset.xval{1})