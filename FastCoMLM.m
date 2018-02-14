function [MODEL]=FastCoMLM(objParam)

    if nargin<1
        disp('Error: no arguments.');
        return
    end
    %%MLM Options
    warning('off','MATLAB:rankDeficientMatrix');
    option = 'distances';
    
    %%Default Options
    if(isempty(objParam.type))
        type = objParam.type;
    else type='fsolve';         
    end
 
    if(isempty(objParam.numberRepetitionsForCotraining))
        numberRepetitionsForCotraining=5;
    else numberRepetitionsForCotraining=objParam.numberRepetitionsForCotraining;
    end
    
    if(isempty(objParam.numberRepetitions))
        numberRepetitions=1;
    else numberRepetitions=objParam.numberRepetitions;
    end
    
    if(isempty(objParam.normalization))
        normalization=0;
    else normalization=objParam.normalization;
    end
    
    if(isempty(objParam.selectMethod))
        selectMethod=1;
    else selectMethod=objParam.selectMethod;
    end
    
    if(isempty(objParam.paramLabel))
        paramLabel=0.6;
    else paramLabel=objParam.paramLabel;
    end
    
    if(isempty(objParam.dataName))
        dataName='default';
    else dataName=objParam.dataName;
    end
    
    if(isempty(objParam.bias))
        bias=0;
    else bias=objParam.bias;
    end
    
    if(isempty(objParam.lambda))
        lambda=0;
    else lambda=objParam.lambda;
    end
    
    if selectMethod~=1
        dataName=strcat(dataName,'_Random_')
    end
    
    
    %% pre-processing / 1-of-S output encoding scheme
    [Nexp,Natt]=size(objParam.dataSet.xtrain{1});
    labels = unique(objParam.dataSet.ytrain{1});
    code = zeros(length(labels), length(labels));
    nLabels=length(labels);
    for j = 1: length(labels),
        code(j, j) = 1;
    end
    IndexColuns=[1:Nexp]';


    for i = 1: numberRepetitions,
        for j = length(labels):-1:1,
            ind = (objParam.dataSet.ytrain{i} == labels(j));
            ind2 = (objParam.dataSet.ytest{i} == labels(j));
            ind3 = (objParam.dataSet.yval{i} == labels(j));
            tam = length(find(ind==1));
            tam2 = length(find(ind2==1));
            tam3 = length(find(ind3==1));
            dataset_ytrain{i}(ind, :) = repmat(code(j, :), tam, 1);
            dataset_ytest{i}(ind2, :) = repmat(code(j, :), tam2, 1);    
            dataset_yval{i}(ind3, :) = repmat(code(j, :), tam3, 1);  
        end

        if normalization==1
            objParam.dataSet.xtrain{i}=[normc(objParam.dataSet.xtrain{i}) IndexColuns];
            objParam.dataSet.xtest{i}=normc(objParam.dataSet.xtest{i});
            objParam.dataSet.xval{i}=normc(objParam.dataSet.xval{i});
        else
            objParam.dataSet.xtrain{i}=[objParam.dataSet.xtrain{i} IndexColuns];
        end

    end

    %% basic methodologyrates 
    count=1;
    for labeled=paramLabel,
        portionExemples=round((Nexp*labeled)/10);
        Original_L=1:portionExemples;
        time=zeros(1,numberRepetitions);
        for i = 1:numberRepetitions,
                originalData.x = objParam.dataSet.xtrain{i}(Original_L,1:end-1);
                originalData.y = dataset_ytrain{i}(Original_L,:);
                repetion=i;        
                valData.x = objParam.dataSet.xval{i};
                valData.y = dataset_yval{i};
                pointsTrain.x=objParam.dataSet.xtrain{i}(1:portionExemples,1:end-1);  
                pointsTrain.y=dataset_ytrain{i}(1:portionExemples,:);
                S=struct('classifier','');
                R = struct('D','','Rate','','C','','Ref','');
                M = struct('Model','');
                Points = struct('p','');
                t = cputime;
                
                for v=1:objParam.validation,
                    %split data and U unlabelled data and L labelled data
                    %L labelled data
                    %split 2 views
                    if(isempty(objParam.permutationVector))
                        portionAttributes=round((5.0*Natt)/10);
                        permutation=randperm(Natt);
                        S.classifier{1}=permutation(1:portionAttributes);            
                        S.classifier{2}=permutation(portionAttributes+1:end-1);
                    else 
                        permutation=objParam.permutationVector;
                        S.classifier{1}=permutation(:,1:floor(size(permutation,2)/2));            
                        S.classifier{2}=permutation(:,1+floor(size(permutation,2)/2):end);
                    end
                    
                    %%lop for co-training
                    BeforeRate=0;
                    for alpha=objParam.paramPoints,                        
                        opt_parameter=alpha; 
                        L=1:portionExemples;
                        U=portionExemples+1:Nexp;
                        Y_train=dataset_ytrain{i};
                        for k=1:numberRepetitionsForCotraining                    
                            %for each view
                            for c=1:2,
                                %%basic MLM Training
                                data.x = objParam.dataSet.xtrain{i}(L,S.classifier{c});
                                [Lin Col]=size(data.x);
                                data.y = Y_train(L,:);      
                                if k==1
                                    K = floor(opt_parameter*size(data.x, 1));
                                    if selectMethod==1
                                        [~,~,~,~,midx] = kmedoids(data.x,K);
                                        refPoints.x = data.x(midx, :);
                                        refPoints.y = data.y(midx, :);
                                        points=midx;
                                    else
                                        ind = randperm(size(data.x,1));
                                        refPoints.x = data.x(ind(1:K), :);
                                        refPoints.y = data.y(ind(1:K), :);
                                        points=ind(1:K);
                                    end
                                    Points.p{c}=points;
                                else
                                    refPoints.x = data.x(Points.p{c}, :);
                                    refPoints.y = data.y(Points.p{c}, :);
                                end
                                
                                if (k==1)
                                    [Dx,Dy] = Remap( refPoints,data );
                                    M.Model{c}=pinv(Dx)*Dy; 
                                    [Ml Mc]=size(M.Model{c});    
                                    P=pinv(Dx'*Dx);
                                    if (c==1)
                                        PA=P; 
                                    else   
                                        PB=P;                                 
                                    end
                                    new=1;
                                else
                                    [newDx,newDy] = Remap( refPoints,data );
                                    if (c==1)
                                        [ M.Model{c},PA ] = Multi_RLS_Online(M.Model{c},PA,newDx(Lin-new+1:end,:),newDy(Lin-new+1:end,:));
                                    else                                        
                                        [ M.Model{c},PB ] = Multi_RLS_Online(M.Model{c},PB,newDx(Lin-new+1:end,:),newDy(Lin-new+1:end,:));
                                    end
                                end
                                
                                UnlabeledData.x = objParam.dataSet.xtrain{i}(U,S.classifier{c}); 
                                UnlabeledData.y = Y_train(U,:);   
                                %%R.D(view), objParam dor each view 
                                [R.D{c},R.C{c}]=test_nnMLM(M.Model{c},UnlabeledData,refPoints);                             
                                R.Ref{c}=refPoints;
                            
                                Data.x = originalData.x(:,S.classifier{c}); 
                                Data.y = originalData.y;                                
                                [~,Yh]=test_nnMLM(M.Model{c},Data,refPoints);
                                
                                for j = 1: length(Data.y),
                                [~, indexVal(j)] = max(Yh(j,:));
                                [~, targetVal(j)] = max(Data.y(j, :));
                                end  
                                R.Rate{c} = length(find(indexVal == targetVal))/length(Data.y);
                            end
                            %%%the best exemple per class for each classifier
                            [bestIndex,badIndex, classes] = best_online(R,1);
                            [Rlin,Rcol] = size(bestIndex);
                            if Rlin>Rcol
                                int=Rlin;
                            else
                                int=Rcol;
                            end
                            new=int;
                            for exemple=1:int,
                                %% add best exemple for each view
                                %best_index is the index that we will working know.                                
                                best_index=bestIndex(exemple);                                
                                
                                AddIndex=U(best_index);
                                L=[L AddIndex]; 

                                %% add label
                                [a b]=max(R.D{1}(best_index,:));
                                Y_train(AddIndex,:)=classes(best_index,:); 

                            end                    
                            %%Remove exemples in U
                            U(bestIndex)=[];
                            if (size(bestIndex,2)<1) ||(size(badIndex,2)<1)
                                break;
                            end    
                        end
                        dataTrain.x=objParam.dataSet.xtrain{i}(L,1:end-1);                
                        dataTrain.y=Y_train(L,:);
                        
                        if numberRepetitionsForCotraining==0
                            [opt_parameter, ~] = optimize_MLM(pointsTrain, paramPoints, bias, lambda, type, 10, option);
                        end
                        
                        K = floor(opt_parameter*size(dataTrain.x, 1));
                        
                        if selectMethod==1
                            [~,~,~,~,midx] = kmedoids(dataTrain.x,K);
                            refPoints.x = dataTrain.x(midx, :);
                            refPoints.y = dataTrain.y(midx, :);
                        else
                            ind = randperm(size(dataTrain.x,1));
                            refPoints.x = dataTrain.x(ind(1:K), :);
                            refPoints.y = dataTrain.y(ind(1:K), :);
                        end
                        
                                         
                        [Dx,Dy ] = Remap( refPoints,dataTrain );
                        Beta=pinv(Dx)*Dy;
                        [~,Yh]=test_nnMLM(Beta,valData,refPoints); 
                           

                        for j = 1: length(valData.y),
                            [~, indexVal(j)] = max(Yh(j,:));
                            [~, targetVal(j)] = max(valData.y(j, :));
                        end  
                        rate = length(find(indexVal == targetVal))/length(valData.y);
                        if rate>=BeforeRate
                            finalBeta=Beta;
                            BeforeRate=rate;
                            numberOFpoints(i)=opt_parameter;                            
                            finalpermutation(i,:)=permutation;
                            finalrefPoints=refPoints;
                        end
                    end
                end
                time(i)=cputime-t;    
                testData.x = objParam.dataSet.xtest{i};
                testData.y = dataset_ytest{i};

                [~,Yh]=test_nnMLM(finalBeta,testData,finalrefPoints); 

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
        targets = objParam.dataSet.ytest;
        if numberRepetitionsForCotraining>0
            s1 = strcat(dataName,'_CoMLM_Online_results_');    
            s2 = num2str(labeled);
            s3=  strcat(s1,num2str(numberRepetitionsForCotraining));  
            s4=strcat(s3,'_');
            name = strcat(s4,s2);
            save(name, 'rates', 'finalBeta','finalrefPoints','confusionMatrices','finalpermutation','numberOFpoints','output', 'targets','time');
        else
            s1 = strcat(dataName,'_MLM_Online_results_');    
            s2 = num2str(labeled);
            name = strcat(s1,s2);
            save(name, 'rates', 'finalBeta','finalrefPoints','confusionMatrices','finalpermutation','numberOFpoints','output', 'targets','time');
        end
        
        ReturnMODEL.rates=rates;
        ReturnMODEL.finalBeta=finalBeta;
        ReturnMODEL.finalrefPoints=finalrefPoints;
        ReturnMODEL.confusionMatrices=confusionMatrices;
        ReturnMODEL.finalpermutation=finalpermutation;
        ReturnMODEL.numberOFpoints=numberOFpoints;
        ReturnMODEL.output=output;
        ReturnMODEL.targets=targets;
        ReturnMODEL.time=time;
        MODEL{count}=ReturnMODEL;
        count=count+1;
    end
    
    
end