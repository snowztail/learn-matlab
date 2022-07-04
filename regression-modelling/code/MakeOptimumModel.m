function [CountOpt,Rmax,mdl_opt,CriteriaOtp] = MakeOptimumModel(tbl,PolyPowers)
% Find optimum model fit to data

% Iterate through polynomial model definition to find optimum R^2 and AIC.
Rmax = 0;           %Initial R value to be optimised
count = 1;           %Set counter for number of equations
for m = 1:PolyPowers;               %Iterate powers of mass
    for E = 1:PolyPowers;           %Iterate powers of engine size
        for a = 1:PolyPowers;       %Iterate powers of acceleration time
            for mi = 0:PolyPowers-1;  %Iterate powers of mass in mass:fueltype interaction term
            % Define model with iterative indices:
            model = ['Efficiency ~ Mass^' num2str(m) '+ EngineSize^' num2str(E) '+ AccelTime^' num2str(a) '+ FuelType +' 'Mass^' num2str(mi) ':FuelType + EngineSize:FuelType + AccelTime:FuelType + Mass:AccelTime + EngineSize:AccelTime'];
            
            %Form model:
            name(count,:) = strcat('mdl_M', num2str(m), 'E', num2str(E), 'A', num2str(a),'MI', num2str(mi));
            mdl_temp = fitlm(tbl,model);
            Criteria.Rsquared(count) = mdl_temp.Rsquared.Adjusted;
            Criteria.MSE(count) = mdl_temp.MSE;
            Criteria.AIC(count) = mdl_temp.ModelCriterion.AIC;
            
            %If new model has R^2 greater than previous best, save model.
            if max(Criteria.Rsquared(count)) > Rmax
                mdl_opt = mdl_temp;                   %Store model
                Rmax = max(Criteria.Rsquared(count)); %Set R as new Rmax
                CountOpt = count;   %Store counter value fo optimum
            end
            
            count = count +1;    %Increase counter by one on each iteration
            end
        end
    end 
    CriteriaOtp.Rsquared = Criteria.Rsquared(CountOpt);
    CriteriaOtp.MSE = Criteria.MSE(CountOpt);
    CriteriaOtp.AIC = Criteria.AIC(CountOpt);

end
