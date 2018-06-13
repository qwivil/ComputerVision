function a = getArea(wd,ht)

 p = inputParser;

 validationFcn = @(x) validateattributes(x,{'numeric'},{'even','positive'});
 
 p.addRequired('width', validationFcn); % 检查输入必须是数值型的
 p.addRequired('height',@isnumeric);

 p.parse(wd,ht);

 a = p.Results.width*p.Results.height;  % 从Results处取结果
end