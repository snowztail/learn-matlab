function [standard] = Standardise(cont,FieldNames,ArMean,ArStd,GeoMean,GeoStd,ArithOrGeo)

if ArithOrGeo == 'G'
    
% Use geometric standardisation because the data is positively skewed.
for i = 1:length(FieldNames)    %Standardize all variables to geometric mean/GeoStd
    if i == 3
        Field = char(FieldNames(i));        %For mass, use arithmetic mean as mass is not skewed
        standard.(Field) = (cont.(Field) - GeoMean.(Field))./ArMean.(Field);
    else
    Field = char(FieldNames(i));
    standard.(Field) = (cont.(Field) - GeoMean.(Field))./GeoStd.(Field);
    end
   
end

elseif ArithOrGeo == 'A'
    for i = 1:length(FieldNames)    %Standardize all variables to geometric mean/GeoStd
        if i == 3
            Field = char(FieldNames(i));        %For mass, use arithmetic mean as mass is not skewed
            standard.(Field) = (cont.(Field) - ArMean.(Field))./ArMean.(Field);
        else
    Field = char(FieldNames(i));
    standard.(Field) = (cont.(Field) - ArMean.(Field))./ArStd.(Field);
        end
    end

end

end