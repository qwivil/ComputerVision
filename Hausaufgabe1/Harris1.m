function [posr,posc]=Harris1(in_image,a)
% 功能：检测图像harris角点
% in_image-待检测的rgb图像数组
% a--角点参数响应，取值范围：0.04~0.06
% [posr，posc]-角点坐标
in_image=rgb2gray(in_image);
I=double(in_image);
%%%%计算xy方向梯度%%%%%

fx=[-1,0,1];%x方向梯度模板
Ix=filter2(fx,I);%x方向滤波
fy=[-1;0;1];%y方向梯度模板(注意是分号)
Iy=filter2(fy,I);
%%%%计算两个方向梯度的乘积%%%%%
Ix2=Ix.^2;
Iy2=Iy.^2;
Ixy=Ix.*Iy;
%%%%使用高斯加权函数对梯度乘积进行加权%%%%
%产生一个7*7的高斯窗函数，sigma值为2
h=fspecial('gaussian',[7,7],2);
IX2=filter2(h,Ix2);
IY2=filter2(h,Iy2);
IXY=filter2(h,Ixy);
%%%%%计算每个像元的Harris响应值%%%%%
[height,width]=size(I);
R=zeros(height,width);
%像素(i,j)处的Harris响应值
for i=1:height
    for j=1:width
        M=[IX2(i,j) IXY(i,j);IXY(i,j) IY2(i,j)];
        R(i,j)=det(M)-a*(trace(M))^2;
    end
end
%%%%%去掉小阈值的Harris值%%%%%
Rmax=max(max(R));
%阈值
t=0.01*Rmax;
for i=1:height
    for j=1:width
        if R(i,j)<t
            R(i,j)=0;
        end
    end
end
%%%%%进行3*3领域非极大值抑制%%%%%%%%%
corner_peaks=imregionalmax(R);
%imregionalmax对二维图片，采用8领域（默认，也可指定）查找极值，三维图片采用26领域
%极值置为1，其余置为0
num=sum(sum(corner_peaks));
%%%%%%显示所提取的Harris角点%%%%
[posr,posc]=find(corner_peaks==1);
figure
imshow(in_image);
hold on
for i=1:length(posr)
    plot(posc(i),posr(i),'r+');
end
end




