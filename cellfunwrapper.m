function Y = cellfunwrapper(fun,Data)
% wrapper for cellfun

Y = num2cell(Data,1);
Y = cell2mat(cellfun(str2func(fun),Y,'UniformOutput',false));

end