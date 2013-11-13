function output = randpermarray( horizArray , nRepeats )
% horizArray: horizontal array of numbers
% nRepeats: number of times to repeat array before randomizing

reparray=repmat(horizArray,1,nRepeats);
n=length(reparray);
randarray=randperm(n);

for i=1:n
    output(i,1)=reparray(randarray(i));
end

end

