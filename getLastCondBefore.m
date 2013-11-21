% this little example script gets the last conductance in each heat pulse
% in heatPulses and puts them in an array lastCondBefore.  Run this script 
% after creating heatPulses

condsBefore={};

numHeatPulses=length(heatPulses);
for i=1:numHeatPulses
    condsBefore{i}=heatPulses(i).condsBefore;
end
% condsBefore is now a cell array with numHeatPulses elements,
% element i is an array of the conductances before the ith heat pulse

for i=1:numHeatPulses
    lastCondBefore(i)=condsBefore{i}(end);
end
% lastCondBefore is a numeric array with numHeatPulses elements,
% element i is the last conductance before the ith heat pulse