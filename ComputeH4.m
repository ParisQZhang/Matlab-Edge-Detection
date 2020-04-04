function H = ComputeH4(corner, p1)

movingPoints = corner;   

H=p1(2);W=p1(1);
p = [1,1;W,1;W,H;1,H];
fixedPoints = p;
H = fitgeotrans(movingPoints,fixedPoints,'projective');
end
