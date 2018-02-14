function En_Co_training_MLM(numberRepetitions,numberRepetitionsForCotraining,numberOFpoints,normalization,select,ParamLabel,DataName,C)

    validation=[1 2 3];
    normalization=0;
    param = 0.1:0.1:1;
    bias = 0;
    lambda = 0; %10e-10;
    type = 'fsolve';
    nFolds = 10;
    option = 'distances';
    Directory='uci-dataset/';
    dataset = load(strcat(strcat(Directory,DataName),'.mat'));
    dataset=dataset.dataset;
    warning('off','MATLAB:rankDeficientMatrix');
    %% pre-processing / 1-of-S output encoding scheme
    [Nexp,Natt]=size(dataset.xtrain{1});

    IndexColuns=[1:Nexp]';
    labels = unique(dataset.ytrain{1});
    code = zeros(length(labels), length(labels));
    nLabels=length(labels);
    for j = 1: length(labels),
        code(j, j) = 1;
    end
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



    for labeled=ParamLabel,    
        portionExemples=round((Nexp*labeled)/10);
        for i = 1: numberRepetitions,
                repetion=i        
                t = cputime;
                BeforeRate=0;
                %Rel-Rasco
                [discrete_data] =Discritize(dataset.xtrain{i}(1:portionExemples,:),10);    
                [Rel] = MI( discrete_data,dataset.ytrain{i}(1:portionExemples,:));
                pointsTrain.x=dataset.xtrain{i}(1:portionExemples,1:end-1);                
                pointsTrain.y=dataset_ytrain{i}(1:portionExemples,:);
                opt_parameter=numberOFpoints(i);
                for v=validation,
                    %split data and U unlabelled data and L labelled data
                    %L labelled data
                    portionAttributes=round((v*Natt)/10);
                    L=1:portionExemples;
                    U=portionExemples+1:Nexp;
                    Y_train=dataset_ytrain{i};

                    %split c views
                    S=struct('classifier','');
                    for c=1:C,            
                        S.classifier{c}=tournament(Rel,portionAttributes);      
                    end
                    %%lop for co-training
                    R = struct('D','');
                    valData.x = dataset.xval{i};
                    valData.y = dataset_yval{i};
                    for alpha=0.5:0.1:0.5,
                        for k=1:numberRepetitionsForCotraining                    
                            %for each view
                            for c=1:C,
                                %%basic MLM Training
                                data.x = dataset.xtrain{i}(L,S.classifier{c});
                                data.y = Y_train(L,:);       

                                K = floor(opt_parameter*size(data.x, 1));
                                ind = randperm(size(data.x,1));
                                refPoints.x = data.x(ind(1:K), :);
                                refPoints.y = data.y(ind(1:K), :);

                                [model] = train_MLM(refPoints, data, bias, lambda);
                                UnlabeledData.x = dataset.xtrain{i}(U,S.classifier{c}); 
                                UnlabeledData.y = Y_train(U,:);   
                                %%R.D(view), model dor each view 
                                [R.D{c}, ~] = test_MLM(model, UnlabeledData, type);
                            end
                            %%best index, where for each exemple ClassModel1(ex)=ClassModel2(ex)
                            [bestIndex,badIndex] = vote2(R,1);
                            [~,Rcol] = size(bestIndex);          
                            for exemple=1:Rcol,

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
                                %%Remove exemple in U
                            end
                            U(bestIndex)=[];
                            if (size(bestIndex,2)<1) ||(size(badIndex,2)<1)
                                break;
                            end    
                        end
                        dataTrain.x=dataset.xtrain{i}(L,1:end-1);                
                        dataTrain.y=Y_train(L,:);


                        K = floor(opt_parameter*size(dataTrain.x, 1));
                        ind = randperm(size(dataTrain.x,1));

                        refPoints.x = dataTrain.x(ind(1:K), :);
                        refPoints.y = dataTrain.y(ind(1:K), :);

                        [model] = train_MLM(refPoints, dataTrain, bias, lambda);

                        [Yh, error] = test_MLM(model, valData, type);  

                        for j = 1: length(valData.y),
                            [~, indexVal(j)] = max(Yh(j,:));
                            [~, targetVal(j)] = max(valData.y(j, :));
                        end  
                        rate = length(find(indexVal == targetVal))/length(valData.y);
                        BeforeRate;
                        if rate>=BeforeRate
                            FinalModel=model;
                            BeforeRate=rate;
                            numberOFpoints(i)=v;
                        end
                    end
                end

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
        std(rates)
        1-m
        targets = dataset.ytest;
        s1 = strcat(strcat(strcat(DataName,'_EnMLM_results_'),num2str(C)),'_');    
        s2 = num2str(labeled);
        name = strcat(s1,s2);
        save(name, 'rates', 'confusionMatrices','numberOFpoints', 'output', 'targets');
    end
end