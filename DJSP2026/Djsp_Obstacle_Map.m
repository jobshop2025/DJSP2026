function Obstacle_Map=Djsp_Obstacle_Map(Left_shift,del_data)
[H1,~]=size(Left_shift);  % H1代表行数，也代表障碍图的个数，L代表列数
if H1==0
    Obstacle_Map=del_data(:,1);
    return;
end
data2=del_data;
MAX_X=max(Left_shift(:,8));
Zhangaitu=[];
fenceng=[];
ii=1;
% max_GJ=max(Left_shift(:,1));
% max_GX=max(Left_shift(:,3));
%选择待调度的工件%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[H2,~]=size(data2);
MAX_Y=max(data2(:,8));
%%%%%%%%%%%%%%%%%%%%绘制障碍图%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAX=max(MAX_X,MAX_Y);
exp_count=1;
for i=1:H1%将产生障碍图的点记录在 Zhangaitu
    a=Left_shift(i,5);
    [j,~]=find(data2(:,5)==a);
    Zhangaitu(exp_count,1)=Left_shift(i,7);
    Zhangaitu(exp_count,2)=data2(j,8);%  N-W 西北角 1,2位置****
    Zhangaitu(exp_count,3)=Left_shift(i,8);
    Zhangaitu(exp_count,4)=data2(j,8);%  N-E 东北角
    Zhangaitu(exp_count,5)=Left_shift(i,8);
    Zhangaitu(exp_count,6)=data2(j,7);%  S-E 东南角 5,6位置****
    Zhangaitu(exp_count,7)=Left_shift(i,7);
    Zhangaitu(exp_count,8)=data2(j,7);%  S-W 西南角
    fenceng(ii,1)=Left_shift(i,8);
    fenceng(ii,2)=data2(j,7);
    ii=ii+1;
    fenceng(ii,1)=Left_shift(i,7);
    fenceng(ii,2)=data2(j,7);
    ii=ii+1;
    exp_count=exp_count+1;
end

Fenceng=sortrows(fenceng,1);
FenCeng=sortrows(Fenceng,2);%%%%%%%%%%分层%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OPEN=[];      %路径坐标
CLOSED=[]; %障碍坐标
OPEN_COUNT=1;%open计数
CLOSED_COUNT=0;%closed计数
xNode=0;%起点
yNode=0;
xStart=0;%起点
yStart=0;
gu=0;%原点到原点
gus=0;%原点到父节点
xTarget=MAX_X;%终点
yTarget=MAX_Y;
zhongjianjiedian=[];
K=1;
fns=yanchidistance(xNode,yNode,xTarget,yTarget);%父节点到终点（子节点） ，刚开始赋值
OPEN(OPEN_COUNT,:)=insert_open(xNode,yNode,xNode,yNode,gu,gus,fns);%将起点加入OPEN
OPEN(1,1)=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%算法开始%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NoPath=1;
while((xNode ~= xTarget || yNode ~= yTarget) && NoPath == 1) %算法从后往前进行搜索，当终点不等于起点时，程序继续执行
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Benceng=newJieDian(FenCeng,xNode,yNode,MAX_X,H2,data2,xTarget,yTarget);
    exp=[];
    exp_count=1;
    I=size(Benceng,1); %后序节点的个数
    for k=1:I  %%对后序节点进行延迟距离赋值
        exp(exp_count,1)=Benceng(k,4);%将后序节点赋值给exp
        exp(exp_count,2)=Benceng(k,5);
        exp(exp_count,3)=gu;%起点到父点的实际延误距离
        exp(exp_count,4)=exp(exp_count,3)+yanchidistance(xNode,yNode,Benceng(k,1),Benceng(k,2))+yanchidistance(Benceng(k,1),Benceng(k,2),Benceng(k,4),Benceng(k,5));%起点到父点+父点到该层节点+该层节点到子节点的实际延误距离
        exp(exp_count,5)=exp(exp_count,4)+yanchidistance(Benceng(k,4),Benceng(k,5),xTarget,yTarget);%再加上后序节点到终点的理论延误距离
        exp_count=exp_count+1;
        zhongjianjiedian(K,:)=[xNode,yNode,Benceng(k,1),Benceng(k,2),Benceng(k,4),Benceng(k,5)];
        K=K+1;
    end
    exp_count=size(exp,1);%附近可行点的个数
    for i=1:exp_count%对附近可行点进行逐个检查
        flag=0;
        for j=1:OPEN_COUNT %将所有的OPEN节点
            if(exp(i,1) == OPEN(j,2) && exp(i,2) == OPEN(j,3) )%判断下一个点是否与前面的点相同
                OPEN(j,8)=min(OPEN(j,8),exp(i,5)); %#ok<*SAGROW>
                if OPEN(j,8)== exp(i,5)
                    OPEN(j,4)=xNode;
                    OPEN(j,5)=yNode;
                    OPEN(j,6)=exp(i,3);
                    OPEN(j,7)=exp(i,4);
                end
                flag=1;
            end
        end
        if flag == 0
            OPEN_COUNT = OPEN_COUNT+1;%将exp中的所有值赋值给OPEN，其中还多加一个父节点的坐标
            OPEN(OPEN_COUNT,:)=insert_open(exp(i,1),exp(i,2),xNode,yNode,exp(i,3),exp(i,4),exp(i,5));
        end
    end
    index_min_node = min_fn(OPEN,OPEN_COUNT,xTarget,yTarget);%记录最小的点在OPEN中的位置
    if (index_min_node ~= -1)   %将open中第八列最小的点找出，并关闭（删除），然后存入CLOSED中
        xNode=OPEN(index_min_node,2);
        yNode=OPEN(index_min_node,3);
        CLOSED_COUNT=CLOSED_COUNT+1;
        CLOSED(CLOSED_COUNT,1)=xNode;
        CLOSED(CLOSED_COUNT,2)=yNode;
        OPEN(index_min_node,1)=0;
        gu=OPEN(index_min_node,7);
    else
        NoPath=0;
    end
end
%%%筛选合适的CLOSED节点%%%%%%%%%%%
i=size(CLOSED,1);
Optimal_path=[];
xval=CLOSED(i,1);
yval=CLOSED(i,2);
i=1;
Optimal_path(i,1)=xval;%将CLOSED中最后一个赋值给Optimal_path
Optimal_path(i,2)=yval;
i=i+1;
parent_x=OPEN(node_index(OPEN,xval,yval),4);%node_index查找该节点在OPEN中的位置
parent_y=OPEN(node_index(OPEN,xval,yval),5);
while(parent_x ~= xStart || parent_y ~= yStart)  %根据开始节点依次寻找
    Optimal_path(i,1) = parent_x;
    Optimal_path(i,2) = parent_y;
    inode=node_index(OPEN,parent_x,parent_y);
    parent_x=OPEN(inode,4);
    parent_y=OPEN(inode,5);
    i=i+1;
end
j=size(Optimal_path,1);
J=j+1;
Optimal_path(J,1)=0;
Optimal_path(J,2)=0;
t=1;
true_path=[];
for T=J:-1:1
    true_path(t,1)=Optimal_path(T,1);
    true_path(t,2)=Optimal_path(T,2);
    t=t+1;
end
%%%%增加本层节点%%%%
i=size(true_path,1);
new_closed=[];
new_closed(1,:)=[true_path(1,1),true_path(1,2)];
count_zhj=size(zhongjianjiedian,1);
a=2;
for s=1:i-1
    if (true_path(s,1)==true_path(s+1,1))||(true_path(s,2)==true_path(s+1,2))
        new_closed(a,:)=[true_path(s+1,1),true_path(s+1,2)];
        a=a+1;
    else
        for k=1:count_zhj
            if (true_path(s,1)==zhongjianjiedian(k,1))&&(true_path(s,2)==zhongjianjiedian(k,2))&&(true_path(s+1,1)==zhongjianjiedian(k,5))&&(true_path(s+1,2)==zhongjianjiedian(k,6))
                if zhongjianjiedian(k,1)~=zhongjianjiedian(k,3)
                    new_closed(a,:)=[zhongjianjiedian(k,3),zhongjianjiedian(k,4)];
                    a=a+1;
                    new_closed(a,:)=[true_path(s+1,1),true_path(s+1,2)];
                    a=a+1;
                    break
                else
                    new_closed(a,:)=[true_path(s+1,1),true_path(s+1,2)];
                    a=a+1;
                end
            end
        end
    end
end
%%%%%%%%%%%%增加中间节点%%%%%%%%%%%%%
J=size(new_closed,1);
n=1;
m=1;
new_CLOSED=[];
new_CLOSED(m,:)=new_closed(n,:);%将第一个点放入new_CLOSED
for h=1:J  %增加中间节点
    n=n+1;
    if n<=J
        if (new_CLOSED(m,1)~=new_closed(n,1))&&(new_CLOSED(m,2)~=new_closed(n,2))%不是0°或者90°
            if (new_closed(n,1)-new_CLOSED(m,1))>(new_closed(n,2)-new_CLOSED(m,2))
                x1=new_CLOSED(m,1);
                x2=new_closed(n,1);
                y1=new_CLOSED(m,2);
                y2=new_closed(n,2);
                m=m+1;
                new_CLOSED(m,1)=x1+y2-y1;
                new_CLOSED(m,2)=y2;
                m=m+1;
                new_CLOSED(m,:)=new_closed(n,:);
            else
                if (new_closed(n,1)-new_CLOSED(m,1))~=(new_closed(n,2)-new_CLOSED(m,2))%不是45°
                    x1=new_CLOSED(m,1);
                    x2=new_closed(n,1);
                    y1=new_CLOSED(m,2);
                    y2=new_closed(n,2);
                    m=m+1;
                    new_CLOSED(m,1)=x2;
                    new_CLOSED(m,2)=y1+x2-x1;
                    m=m+1;
                    new_CLOSED(m,:)=new_closed(n,:);
                else
                    m=m+1;
                    new_CLOSED(m,:)=new_closed(n,:);
                end
            end
        else %是0°或者90°则直接赋值
            m=m+1;
            new_CLOSED(m,:)=new_closed(n,:);
        end
    end
end
%%%%%%%%%%%%%%编码%%%%%%%%%%%%%%%%
% new_CLOSED=xlsread('10个工件比较.xlsx',-1); %调试专用
H=size(new_CLOSED,1);
% figure(1)
% plot(new_CLOSED(:,1),new_CLOSED(:,2),'LineWidth',2,'Color',[1 0 0])
G=H-1;

%  dietance=0;
% for hl=1:G
%     dietance= dietance+sqrt((new_CLOSED(hl+1,1)-new_CLOSED(hl,1))^2+(new_CLOSED(hl+1,2)-new_CLOSED(hl,2))^2);
% end
Obstacle_Map=[];%存取工件号
b=1;
T=[];%中间工序号
%%%%%%%%%%%%%%%删除机器%%%%%%%%%%%%%%
for k=1:H1
    if Left_shift(k,6)==0
        Left_shift(k,7)=10000;%标记该行已经访问
        Left_shift(k,8)=10000;
    end
end
for k=1:H2
    if data2(k,6)==0
        data2(k,7)=10000;%标记该行已经访问
        data2(k,8)=10000;
    end
end
for i=1:G%遍历关键点
    S=[];%临时存取工件号
    s=1;
    if new_CLOSED(i,2)==new_CLOSED(i+1,2)%0°
        for h=1:H1%遍历已调度的所有行
            if Left_shift(h,7)<new_CLOSED(i+1,1)%开工时间<x2
                S(s,1)=Left_shift(h,1);
                S(s,2)=Left_shift(h,7)-new_CLOSED(i,1);
                s=s+1;
                Left_shift(h,7)=10000;%标记该行已经访问
                Left_shift(h,8)=10000;
            end
        end
    else
        if (new_CLOSED(i+1,2)-new_CLOSED(i,2))==(new_CLOSED(i+1,1)-new_CLOSED(i,1))%45°斜线
            for h=1:H1%遍历x轴下方的所有行
                if Left_shift(h,7)<new_CLOSED(i+1,1)%开工时间<x2
                    S(s,1)=Left_shift(h,1);
                    S(s,2)=Left_shift(h,7)-new_CLOSED(i,1);
                    s=s+1;
                    Left_shift(h,7)=10000;
                    Left_shift(h,8)=10000;
                end
            end
            for j=1:H2 %45°遍历y轴
                if data2(j,7)<new_CLOSED(i+1,2)
                    S(s,1)=data2(j,1);
                    S(s,2)=0;
                    s=s+1;
                    data2(j,7)=10000;
                    Left_shift(j,8)=10000;
                end
            end
        else
            for j=1:H2 %45°遍历y轴
                if data2(j,7)<new_CLOSED(i+1,2)
                    S(s,1)=data2(j,1);
                    S(s,2)=0;
                    s=s+1;
                    data2(j,7)=10000;
                    Left_shift(j,8)=10000;
                end
            end
        end   %%%%%%%%%%%%%%%
    end
    z=size(S);
    if z>0
        T=sortrows(S,2);
        A=size(T(:,1));
        for a=1:A
            Obstacle_Map(b,1)=T(a,1);
            b=b+1;
        end
    end
end