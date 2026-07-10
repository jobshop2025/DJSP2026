function new_row = insert_open(xval,yval,parent_xval,parent_yval,gu,gus,fus)

new_row(1,1)=1;
new_row(1,2)=xval;
new_row(1,3)=yval;
new_row(1,4)=parent_xval;
new_row(1,5)=parent_yval;
new_row(1,6)=gu;%起点到该点的延误距离
new_row(1,7)=gus;%hn+该点到下一点的延误距离。实际上起点到该点的实际延误距离
new_row(1,8)=fus;%gn+下一点到终点的理论延误距离

end