function Mask=zeroBorder(I,W)
Mask=zeros(size(I));
Mask((W+1):(size(I,1)-W),(W+1):(size(I,2)-W))=1;
end