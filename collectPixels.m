function I = collectPixels(img,x,y)

linearInd = sub2ind(size(img),y,x);
I = img(linearInd);

end