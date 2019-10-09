function RunOneNNMinkowski(DataSetStartIndex, DataSetEndIndex, NormalizationIndex)  

    % Normalization
    % 1 - ZScoreNorm
    % 2 - MinMaxNorm
    % 3 - UnitLengthNorm
    % 4 - MeanNorm
    % 5 - MedianNorm
    % 6 - AdaptiveNorm
    % 7 - Sigmoid
    % 8 - Tanh
    % 9 - SlidingZScore (ONLY FOR ED/Manhattan - needs tuning)
    
    Normalizations = [cellstr('ZScoreNorm'), 'MinMaxNorm', 'UnitLengthNorm', 'MeanNorm', 'MedianNorm', 'AdaptiveNorm' ...
        'Sigmoid', 'Tanh', 'SlidingZScore'];
    
    addpath(genpath('normalizations/.'));
    
    % first 2 values are '.' and '..' - UCR Archive 2018 version has 128 datasets
    dir_struct = dir('./UCR2018-NEW/');
    Datasets = {dir_struct(3:130).name};
                     
    % Sort Datasets
    
    [Datasets, DSOrder] = sort(Datasets);  
    
    addpath(genpath('distancemeasures/.'));

    Results = zeros(length(Datasets),3);

    for i = 1:length(Datasets)

            if (i>=DataSetStartIndex && i<=DataSetEndIndex)

                    LeaveOneOutAccuracies = zeros(length(Datasets),25);
                    LeaveOneOutRuntimes = zeros(length(Datasets),25);

                    disp(['Dataset being processed: ', char(Datasets(i))]);
                    DS = LoadUCRdataset(char(Datasets(i)));
                    
                    gammaValues = [0.01,0.03,0.05,0.07,0.09,0.1,0.3,0.5,0.7,0.9,1,1.3,1.5,1.7,1.9,2,3,5,7,9,11,13,15,17,20];
                    
                    for gammaIter = 1:25

                        gammaIter
                        tic;
                        acc = LOOCMinkowski(DS,gammaValues(gammaIter), NormalizationIndex);
                        LeaveOneOutRuntimes(i,gammaIter) = toc;
                        LeaveOneOutAccuracies(i,gammaIter) = acc;
                    end
                    
                    [MaxLeaveOneOutAcc,MaxLeaveOneOutAccGamma] = max(LeaveOneOutAccuracies(i,:));

                    OneNNAcc = OneNNClassifierMinkowski(DS, gammaValues(MaxLeaveOneOutAccGamma), NormalizationIndex);
                                 
                    Results(i,1) = gammaValues(MaxLeaveOneOutAccGamma);
                    Results(i,2) = MaxLeaveOneOutAcc;
                    Results(i,3) = OneNNAcc;
                    
                    
            end
            dlmwrite( strcat('RESULTS_RunOneNNMinkowski_', char(Normalizations(NormalizationIndex)), '_', num2str(DataSetStartIndex), '_', num2str(DataSetEndIndex) ), Results, 'delimiter', '\t');
   
            
    end
    
end