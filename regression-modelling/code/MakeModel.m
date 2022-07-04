function [Rmax,mdl,Criteria] = MakeModel(tbl,model)
% Fit given model to to data

%Form model:
%             name(count,:) = strcat('mdl_M', num2str(m), 'E', num2str(E), 'A', num2str(a),'MI', num2str(mi));
mdl = fitlm(tbl,model);
Criteria.Rsquared = mdl.Rsquared.Adjusted;
Criteria.MSE = mdl.MSE;
Criteria.AIC = mdl.ModelCriterion.AIC;

Rmax = Criteria.Rsquared;            
end