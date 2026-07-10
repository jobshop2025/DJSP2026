function Benceng=newJieDian(FenCeng,xNode,yNode,MAX_X,H2,data2,xTarget,yTarget)
Benceng=[];
column = 2;
num=yNode;
row_index=FenCeng(:,column) == num;
B=FenCeng(row_index,:);%%%取出该层%%%
b=size(B,1);
B(b+1,:)=[MAX_X,yNode];%将左端点存入该层
%%%%%%%%%%判断节点在该层的位置%%%%%%%%%%%%%首先将该节点转化为本层节点%%%%%%%%%%%%%%%%%%%%
h=0;
i=1;
a=1;
for y=1:H2%判断该点应该跨过的y轴的大小
    if yNode<data2(y,8)
        Y=data2(y,8)-yNode;
        break
    end
end
if (xNode~=xTarget)&&(yNode~=yTarget)
    while h<1
        %%%%%%%%%奇循环%%%%%%%
        if xNode<=B(i,1)%在障碍块的外部
            h=1;%大循环结束
            x=B(i,1)-xNode;
            Benceng(a,:)=[xNode,yNode,x];%将该点与该点距离障碍块左端点的值记录下来
            if (B(i,1)-xNode)>=Y%如果当前的距离大于y轴，则结束
                i=i+1000;
            end
            while i<b
                if (B(i+2,1)-B(i+1,1))>x
                    x=B(i+2,1)-B(i+1,1);%将最大值赋值给x
                    a=a+1;
                    Benceng(a,:)=[B(i+1,1),yNode,x];
                    if (B(i+2,1)-B(i+1,1))>=Y%如果当前的距离大于y轴，则结束
                        i=i+1000;
                    end
                    i=i+2;
                else
                    i=i+2;
                end
            end
        end
        i=i+1;%%%%%%%%%%%%%%%%%%偶循环,该点在障碍块的底部%%%%%%%%%%
        if h<1
            if xNode<=B(i,1)
                h=1;
                x2=B(i+1,1)-B(i,1);
                Benceng(a,:)=[B(i,1),yNode,x2];%将该点与该点距离障碍块右端点的值记录下来
                if (B(i+1,1)-B(i,1))>=Y%如果当前的距离大于y轴，则结束
                    i=i+1000;
                end
                while i<b-1
                    if (B(i+3,1)-B(i+2,1))>x2
                        x2=B(i+3,1)-B(i+2,1);
                        a=a+1;
                        Benceng(a,:)=[B(i+2,1),yNode,x2];
                        if (B(i+3,1)-B(i+2,1))>=Y%如果当前的距离大于y轴，则结束
                            i=i+1000;
                        end
                        i=i+2;
                    else
                        i=i+2;
                    end
                end
            end
        end
        i=i+1;
        if xNode>=B(b,1)%超出障碍块的位置
            Benceng(1,:)=[xNode,yNode,MAX_X-xNode];
        end
    end
    count=size(Benceng,1);
    for k=1:count
        Benceng(k,4)=Benceng(k,1)+min(Benceng(k,3),Y);
        Benceng(k,5)=Benceng(k,2)+Y;
    end
else
    Benceng(1,:)=[xNode,yNode,0,xTarget,yTarget];
end
end