function dist = yanchidistance(x1,y1,x2,y2)%任意两点之间的延误距离
%x1,y1是起点 x2,y2是后序节点
dist=abs(y2-y1-x2+x1);
