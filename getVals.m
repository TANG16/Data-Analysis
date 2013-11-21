function arraysFieldsVals = getVals(array,field,firstIndex,lastIndex)
% GETVALS returns an array of all the values in a field of an array between
%   two indices
%
% Returns an array of the values of field 'field' in elements between 
% firstIndex and lastIndex, inclusive, of array 'array'.  Works for cell or 
% struct arrays.  VALUES MUST BE SCALAR.  If firstIndex and lastIndex are
% not specified, the function uses the whole array.


if(nargin==2)
    firstIndex=1;
    lastIndex=length(array);
end

arraysFieldsVals=zeros(lastIndex-firstIndex+1,1);

if isstruct(array)
    for i=firstIndex:lastIndex
        arraysFieldsVals(i-firstIndex+1,1)=getfield(array,{i,1},field,{1});
    end
elseif iscell(array)
    for i=firstIndex:lastIndex
        arraysFieldsVals(i-firstIndex+1,1)=array{i-firstIndex+1}.(field);
    end    
end

end
