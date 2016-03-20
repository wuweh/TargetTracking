
[ESMMeasure,Vol] = GenerateMeasurement( TrueTrace, ObserveTrace, ESMInfo, N);
for i = 1:length(ESMMeasure)
    for j =1:length(ESMMeasure{i})
        ESMMeasure{i}(j).Echo([1,4],:) = [];
        ESMMeasure{i}(j).Property = [0.8;0.2];        
    end
end