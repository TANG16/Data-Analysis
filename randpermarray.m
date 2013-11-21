function output = randpermarray( horizArray , nRepeats )
% RANDPERMARRAY Returns a vertical array which contains a random 
%   permutation of the elements of n copies of a horizontal array
%
% INPUTS
%   horizArray: horizontal array of numbers
%   nRepeats: number of times to repeat array before randomizing
%
% OUTPUT
%   output: output array

reparray=repmat(horizArray,1,nRepeats);
n=length(reparray);
randarray=randperm(n);

for i=1:n
    output(i,1)=reparray(randarray(i));
end

end

