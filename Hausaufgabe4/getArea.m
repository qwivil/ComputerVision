% getArea版本1  
function a = getArea(wd,varargin)

 p = inputParser;

 p.addRequired('width', @isnumeric); % 检查输入必须是数值型的
 p.addOptional('height', 10, @isnumeric);

 p.parse(wd, varargin{:});

 a = p.Results.width*p.Results.height;  % 从Results处取结果
end