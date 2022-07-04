%% Linear Regression Modelling - Graduate School Course
% Maxwell Munford
% mjm214@ic.ac.uk
% 28/03/2019

clear
clc
set(0,'DefaultFigureWindowStyle','docked')

%% Load data and rewrite variable names
%Load continuous data (mass, time, efficiency and displacement)
%Load also categoric data (colour and fuel type)
load('../assets/Data.mat');  

%Time in seconds, from 0 to 100km/hr
%Efficiency in litres per 100km
%Mass in kg
%Engine size in Litres
%Colour
%Fuel type; petrol or deisel

% Combined data and string array of variable names (for 1b)
Data = [cont.time100  cont.l100 cont.mass cont.displacement];
VariableNames = {'Time [s]','Fuel Efficiency [L/km]','Mass [kg]','Engine size [L]','Colour','Fuel type'};

%% Part 1 - Scatter Plots, Box Plots and Histogram

FieldNames = fieldnames(cont);  %Get array of all field names in continuous structure
for i = 1:length(FieldNames)    %Find mean, geomean, stdev, geostdev, mdeian and trimmed mean for all variables
    Field = char(FieldNames(i));      %Call current field name
    ArMean.(Field) = mean(cont.(Field));    %Calculate arithmetic mean 
    GeoMean.(Field) = geomean(cont.(Field));  %Calculate geometric mean 
    
    ArStd.(Field) = std(cont.(Field));    %Calculate arithmetic stdev
    GeoStd.(Field) = geostd(cont.(Field));  %Calculate geometric stdev 
    
    Median.(Field) = median(cont.(Field));          %Calculate median 
    TrimMean.(Field) = trimmean(cont.(Field),10);   %Calculate 10% trimmed mean
end

figure(1)   %Figure for histogram
histogram(cont.l100,30);
L1 = line([ArMean.l100 ArMean.l100], [0 100], 'color','r');
L2 = line([GeoMean.l100 GeoMean.l100], [0 100], 'color','g');
L3 = line([Median.l100 Median.l100], [0 100], 'color','b');
L4 = line([TrimMean.l100 TrimMean.l100], [0 100], 'color','k');

xlabel(VariableNames(2),'fontsize',15);
ylabel('Frequency [%]','fontsize',15);
ylim ([0 80]);
xlim ([2.5 max(cont.l100)]);

legend([L1 L2 L3 L4],{'Arithmetic Mean', 'Geometric Mean', 'Median', '10% Trimmed Mean'});

figure(2);      %Figure for scatter plots
for i = 1:3;    %i and j correspond to the continuous variables and subplot position
    for j =2:4;
        if j>i
            subplot(3,3,i + 3*(j-2))
            scatter(Data(:,i),Data(:,j));
            xlabel(VariableNames(i),'fontsize',15);
            ylabel(VariableNames(j),'fontsize',15);
        end
    end
end 
            
figure(3);      %Figure for box plots
for i = 1:4;
    for j = 1:2;
            subplot(2,4,i + 4*(j-1))            %Select subplot in array of figures
            if j == 1;
                boxplot(Data(:,i),cat.colour);      %Plot box plots by colour
                xlabel(VariableNames(j+4),'fontsize',15);
                ylabel(VariableNames(i),'fontsize',15);
            else
                boxplot(Data(:,i),cat.type);       %Plot box plots by fuel type
                xlabel(VariableNames(j+4),'fontsize',15);
                ylabel(VariableNames(i),'fontsize',15);
            end
    end
end

%% Standardise variables to be used in Section 2.
% Standardisation is used because fuel efficiency depends on multiple
% variables (mass, fuel type and engine size).

% Recode categorical variables
for i = 1:500
    bin.colour(i) = strcmp(cat.colour(i),'white');  %Set colour_bin = 1 if white, else 0
    bin.type(i) = strcmp(cat.type(i),'petrol');   %Set type_bin = 1 if petrol, else 0
end

Skew = skewness (cont.l100);    %Calculate skewness

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'G' for geometric standardisation or 'A' for arithmetic standardisation
% standard = Standardise(cont,FieldNames,ArMean,ArStd,GeoMean,GeoStd,'A');
standard = Standardise(cont,FieldNames,ArMean,ArStd,GeoMean,GeoStd,'G');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Part 2 - Fit Model

% Make table of predictor, categorical and output variables
tbl = table(standard.l100,standard.mass, standard.displacement,standard.time100,'VariableNames',{'Efficiency','Mass','EngineSize','AccelTime'});
tbl.FuelType = nominal(bin.type');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Insert Model Here
% model = ['Efficiency ~ Mass']; % Rsquared: 0.4157
% model = ['Efficiency ~ EngineSize']; % Rsquared: 0.0643
% model = ['Efficiency ~ AccelTime']; % Rsquared: 0.0711
% model = ['Efficiency ~ FuelType']; % Rsquared: 0.2713

% model = ['Efficiency ~ Mass + FuelType']; % Rsquared: 0.6540 MSE: 0.4383
% model = ['Efficiency ~ Mass + AccelTime']; % Rsquared: 0.4684
% model = ['Efficiency ~ Mass + EngineSize']; % Rsquared: 0.4681
% model = ['Efficiency ~ FuelType + AccelTime']; % Rsquared: 0.3494
% model = ['Efficiency ~ FuelType + EngineSize']; % Rsquared: 0.3347
% model = ['Efficiency ~ AccelTime + EngineSize']; % Rsquared: 0.0712
% model = ['Efficiency ~ Mass + FuelType + AccelTime + EngineSize']; % Rsquared: 0.7137 MSE: 0.3627

% Other Examples for models
% model = ['Efficiency ~ Mass + EngineSize^2'];
% AccelTime
% EngineSize
% Mass
% FuelType
% Mass:FuelType % Example of an interaction term
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make Model:
[Rmax,mdl,Criteria] = MakeModel(tbl,model);
Criteria

%% Plot Model Figures
figure(5);     %Plot on 1 plot, with 2 y axis. 
yyaxis left
plot(Criteria.Rsquared,Criteria.AIC,'o');
ylabel('AIC','fontsize',15);
xlabel('R^{2}','fontsize',15);
title (' ')

yyaxis right
plot(Criteria.Rsquared,Criteria.MSE,'o');
ylabel('MSE','fontsize',15);
xlabel('R^{2}','fontsize',15);

%Plot fitted model against actual data
figure(6);
plot(mdl)
xlabel('Fitted model for Efficiency','fontsize',15);
ylabel('Data for Efficiency','fontsize',15);
title ('');

%% Part 3 - Plot data residuals 

figure(7);
subplot(2,2,[1 2]);
plotResiduals(mdl);   %Plot histogram of residuals
xlabel('Residuals','fontsize',15);
ylabel('Frequency','fontsize',15);
title (' ')
subplot(2,2,3);
plotResiduals(mdl,'fitted');  %Plot residuals against fitted values
xlabel('Fitted Values of Efficiency','fontsize',15);
ylabel('Studentized Residuals','fontsize',15);
title (' ')
subplot(2,2,4);
qqplot(mdl.Residuals.Raw); %Plot of quantiles against quantiles
xlabel('Standard Normal Quantiles','fontsize',15);
ylabel({'Quantiles of Raw'; 'Model Residuals'},'fontsize',15);
title (' ')

% [CountOpt,Rmax,mdl,Criteria] = MakeOptimumModel(tbl,3)
