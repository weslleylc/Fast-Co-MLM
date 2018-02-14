function [ dataset ] = constructData( data, iterations, rate_train,rate_test)
    [~,I] = sort(data(:,end),'ascend');
    data=data(I,:);
    [lin col]=size(data);
    [~,first,~] = unique(data(:,end),'first');
    [~,last,~] = unique(data(:,end),'last');
    m_classes=length(first);
    SplitClass = struct('class','');
    for i=1:m_classes,
        SplitClass.class{i}=data(first(i):last(i),:);
    end

    dataset = struct();
    train=floor((lin)*rate_train)-m_classes*3;
    val=floor((lin)*(1-rate_test))-m_classes*3;

    for p=1:iterations,
        for i=1:m_classes,
            perm=randperm(last(i)-first(i)+1);
            SplitClass.class{i}=SplitClass.class{i}(perm,:);
        end
        trainData_labeled=zeros(1,col);
        ValData=zeros(1,col);
        TestData=zeros(1,col);

        for i=1:m_classes,
            trainData_labeled=[trainData_labeled ;SplitClass.class{i}(1,:)];
            ValData=[ValData ;SplitClass.class{i}(2,:)];
            TestData=[TestData ;SplitClass.class{i}(3,:)];
        end
        trainData_labeled(1,:)=[];
        ValData(1,:)=[];
        TestData(1,:)=[];
        Data_base=zeros(1,col);
        for i=1:m_classes,
            Data_base=[Data_base ;SplitClass.class{i}(4:end,:)];
        end
        Data_base(1,:)=[];
        Data_base=Data_base(randperm(size(Data_base,1)),:);
        X=Data_base(:,1:end-1);
        y=Data_base(:,end);

        dataset.ytrain{p}=[trainData_labeled(:,end) ;y(1:train)]; 
        dataset.xtrain{p}=[trainData_labeled(:,1:end-1) ;X(1:train,:)];

        dataset.yval{p}=[ValData(:,end) ;y(train+1:val,:)]; 
        dataset.xval{p}=[ValData(:,1:end-1) ;X(train+1:val,:)];

        dataset.ytest{p}=[TestData(:,end) ;y(val+1:end)]; 
        dataset.xtest{p}=[TestData(:,1:end-1) ;X(val+1:end,:)];
    end


end

