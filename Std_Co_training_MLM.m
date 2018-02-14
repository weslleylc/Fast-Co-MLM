function Std_Co_training_MLM(numberRepetitions,numberRepetitionsForCotraining,normalization,select,ParamLabel,param,Directory,DataName)
    DataName
    validation=1;
    bias = 0;
    lambda = 0; %10e-10;
    type = 'fsolve';
    option = 'distances';
    dataset = load(strcat(strcat(Directory,DataName),'.mat'));
    dataset=dataset.dataset;
    warning('off','MATLAB:rankDeficientMatrix');
    %% pre-processing / 1-of-S output encoding scheme
    [Nexp,Natt]=size(dataset.xtrain{1});
    labels = unique(dataset.ytrain{1});
    code = zeros(length(labels), length(labels));
    nLabels=length(labels);
    for j = 1: length(labels),
        code(j, j) = 1;
    end
    IndexColuns=[1:Nexp]';


    for i = 1: numberRepetitions,
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

        if normalization==1
            dataset.xtrain{i}=[normc(dataset.xtrain{i}) IndexColuns];
            dataset.xtest{i}=normc(dataset.xtest{i});
            dataset.xval{i}=normc(dataset.xval{i});
        else
            dataset.xtrain{i}=[dataset.xtrain{i} IndexColuns];
        end

    end

    %% basic methodologyrates
    if select~=1
        DataName=strcat(DataName,'_Random_')
    end
    portionAttributes=round((5.0*Natt)/10);
    for labeled=ParamLabel,
        portionExemples=round((Nexp*labeled)/10);
%         portionExemples=ParamLabel;
        Original_L=1:portionExemples;
        time=zeros(1,numberRepetitions);
        for i = 1:numberRepetitions,
                originalData.x = dataset.xtrain{i}(Original_L,1:end-1);
                originalData.y = dataset_ytrain{i}(Original_L,:);
                repetion=i;        
                valData.x = dataset.xval{i};
                valData.y = dataset_yval{i};
                pointsTrain.x=dataset.xtrain{i}(1:portionExemples,1:end-1);  
                pointsTrain.y=dataset_ytrain{i}(1:portionExemples,:);
%                 opt_parameter=numberOFpoints(i);
                t = cputime;
                for v=1:validation,
                    %split data and U unlabelled data and L labelled data
                    %L labelled data
                    %split 2 views

                    S=struct('classifier','');
                    permutation=randperm(Natt);
                    S.classifier{1}=permutation(1:portionAttributes);            
                    S.classifier{2}=permutation(portionAttributes+1:end);
%                     permutation=1:3000;
%                     S.classifier{1}=1:1500;            
%                     S.classifier{2}=1501:3000;
                    %%lop for co-training
                    R = struct('D','','Rate','');
                    M = struct('Model','');
                    BeforeRate=0;
                    for alpha=param,                        
                        opt_parameter=alpha;
%                         if numberRepetitionsForCotraining>0
%                             [opt_parameter, ~] = optimize_MLM(pointsTrain, param, bias, lambda, type, 10, option);
%                         end    
                        L=1:portionExemples;
                        U=portionExemples+1:Nexp;
                        Y_train=dataset_ytrain{i};
                        for k=1:numberRepetitionsForCotraining                    
                            %for each view
                            for c=1:2,
                                %%basic MLM Training
                                data.x = dataset.xtrain{i}(L,S.classifier{c});
                                data.y = Y_train(L,:);      

                                K = floor(opt_parameter*size(data.x, 1));
                                if select==1
                                    [~,~,~,~,midx] = kmedoids(data.x,K);
                                    refPoints.x = data.x(midx, :);
                                    refPoints.y = data.y(midx, :);
                                else
                                    ind = randperm(size(data.x,1));
                                    refPoints.x = data.x(ind(1:K), :);
                                    refPoints.y = data.y(ind(1:K), :);
                                end
                                
                                [M.Model{c}] = train_MLM(refPoints, data, bias, lambda);
                                UnlabeledData.x = dataset.xtrain{i}(U,S.classifier{c}); 
                                UnlabeledData.y = Y_train(U,:);   
                                %%R.D(view), model dor each view 
                                [R.D{c}, ~] = test_MLM(M.Model{c}, UnlabeledData, type);
                                
                                
                            
                                Data.x = originalData.x(:,S.classifier{c}); 
                                Data.y = originalData.y;                                
                                [Yh, ~] = test_MLM(M.Model{c}, Data, type);
                                for j = 1: length(Data.y),
                                [~, indexVal(j)] = max(Yh(j,:));
                                [~, targetVal(j)] = max(Data.y(j, :));
                                end  
                                R.Rate{c} = length(find(indexVal == targetVal))/length(Data.y);
                            end
                            %%%the best exemple per class for each classifier
                            [bestIndex,badIndex] = best6(R,1);
                            [Rlin,Rcol] = size(bestIndex);
                            if Rlin>Rcol
                                int=Rlin;
                            else
                                int=Rcol;
                            end
                            for exemple=1:int,

                                %% add best exemple for each view
                                %best_index is the index that we will working know.
                                best_index=bestIndex(exemple);
                                AddIndex=dataset.xtrain{i}(U(best_index),end); 
                                L=[L AddIndex];                           

                                %% add label
                                [Max Idmax]=max(R.D{1}(best_index,:));
                                AddExample=zeros(1,nLabels);
                                AddExample(Idmax)=1;
                                Y_train(AddIndex,:)=AddExample; 
                            end                    
                            %%Remove exemples in U
                            U(bestIndex)=[];
                            if (size(bestIndex,2)<1) ||(size(badIndex,2)<1)
                                break;
                            end    
                        end
                        dataTrain.x=dataset.xtrain{i}(L,1:end-1);                
                        dataTrain.y=Y_train(L,:);
%                         [opt_parameter, ~] = optimize_MLM(dataTrain, param, bias, lambda, type, 10, option);
                        if numberRepetitionsForCotraining==0
                            [opt_parameter, ~] = optimize_MLM(pointsTrain, param, bias, lambda, type, 10, option);
                        end 
                        K = floor(opt_parameter*size(dataTrain.x, 1));
                        ind = randperm(size(dataTrain.x,1));
                        refPoints.x = dataTrain.x(ind(1:K), :);
                        refPoints.y = dataTrain.y(ind(1:K), :);
%                         if select==1
%                             [~,~,~,~,midx] = kmedoids(dataTrain.x,K);
%                             refPoints.x = dataTrain.x(midx, :);
%                             refPoints.y = dataTrain.y(midx, :);
%                         else
%                             ind = randperm(size(dataTrain.x,1));
%                             refPoints.x = dataTrain.x(ind(1:K), :);
%                             refPoints.y = dataTrain.y(ind(1:K), :);
%                         end
                        
                        [model] = train_MLM(refPoints, dataTrain, bias, lambda);

                        [Yh, error] = test_MLM(model, valData, type);  

                        for j = 1: length(valData.y),
                            [~, indexVal(j)] = max(Yh(j,:));
                            [~, targetVal(j)] = max(valData.y(j, :));
                        end  
                        rate = length(find(indexVal == targetVal))/length(valData.y);
                        if rate>=BeforeRate
                            FinalModel=model;
                            BeforeRate=rate;
                            numberOFpoints(i)=opt_parameter;                            
                            Finalpermutation(i,:)=permutation;
                        end
                    end
                end
                time(i)=cputime-t;    

                    
                testData.x = dataset.xtest{i};
                testData.y = dataset_ytest{i};

                [Yh, error] = test_MLM(FinalModel, testData, type);  

                for j = 1: length(testData.y),
                    [~, index(j)] = max(Yh(j,:));
                    [~, target(j)] = max(testData.y(j, :));
                end  
                rate = length(find(index == target))/length(testData.y)

                confusionMatrix = zeros(size(code, 1));
                for j = 1 : length(testData.y),
                    confusionMatrix(index(j), target(j)) = confusionMatrix(index(j), target(j)) + 1;
                end
                rates(i) = rate;
                output{i} = Yh;
                confusionMatrices{i} = confusionMatrix;

        end
        m=mean(rates)
        std(rates);
        1-m;
        targets = dataset.ytest;
        if numberRepetitionsForCotraining>0
            s1 = strcat(DataName,'_CoMLM_results_');    
            s2 = num2str(labeled);
            s3=  strcat(s1,num2str(numberRepetitionsForCotraining));  
            s4=strcat(s3,'_');
            name = strcat(s4,s2);
            save(name, 'rates', 'confusionMatrices','Finalpermutation','numberOFpoints','output', 'targets','time');
        else
            s1 = strcat(DataName,'_MLM_results_');    
            s2 = num2str(labeled);
            name = strcat(s1,s2);
            save(name, 'rates', 'confusionMatrices','Finalpermutation','numberOFpoints','output', 'targets','time');
        end
    end
end