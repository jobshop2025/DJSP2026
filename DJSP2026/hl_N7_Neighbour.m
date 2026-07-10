function [N7_Exchange,data2,data1]=hl_N7_Neighbour(xnow,iter)
global   job_gongxu 
n7_exchange=xnow.jobamount;
Cmax=xnow.value;
data1=xnow.data;
count=size(data1,1);
data_1=[xnow.code xnow.data];%增加一列，将编码放在第一列，目前一共是9列
data2=DJSP_later_data(data_1);%最晚开完工时间表
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:count  %++++++++++++++++
    %本道工序的尾长   9   （u,n）
    data1(i,9)=Cmax-data2(i,7);
    %工件前序的头长   10  JPu      % 本道工序的头长为8
    if data1(i,3)~=1
        data1(i,10)=data1(i-1,7); % 工件前续的开工时间
        data1(i,15)=data1(i-1,6);
    else
        data1(i,10)=0;
        data1(i,15)=0;
    end
    %后序工序的尾长   11   JSu
    if data1(i,3)~=job_gongxu
        data1(i,11)=Cmax-data2(i+1,7);
        data1(i,14)=data1(i+1,6);% 工件后序的加工时间
    else
        data1(i,11)=0;
        data1(i,14)=0;% 工件后序的加工时间
    end
end
%工件排序
data1=sortrows(data1,7);%%按照开工时间升序
data1=sortrows(data1,5);%%再按照机器升序
%机器排序
data2=sortrows(data2,7);%%按照开工时间升序
data2=sortrows(data2,5);%%再按照机器升序
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=1;
for i=1:count
    %机器上每道工序的排序   4
    data1(i,4)=m;
    %     12  MPu
    if m~=1
        data1(i,12)=data1(i-1,7);
        data1(i,16)=data1(i-1,6);%机器前序加工时间
    else
        data1(i,12)=0;
        data1(i,16)=0;
    end
    %   13   MSu
    if m~=n7_exchange
        data1(i,13)=Cmax-data2(i+1,7);
    else
        data1(i,13)=0;
    end
    if m==n7_exchange
        m=0;
    end
    m=m+1;
end
%%%%%%%%%%%%%%%%%最早开工时间与最晚开工时间相同的即为关键工序%%%%%%%%%%%%%%%%%%
arr=1;
key_gx=[];
for r=1:count
    if data1(r,7)==data2(r,7)
        key_gx(arr,:)=data1(r,:);%存储有可能关键块的行
        arr=arr+1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%寻找关键块%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k_g=size(key_gx,1);%一共有几个可能的关键块
flagg=1;
for mac=1:k_g-1
    keyjiqi=key_gx(mac,5);
    keyshijian=key_gx(mac,8);
    key_gx(mac,2)=flagg;
    if key_gx(mac+1,5)~=keyjiqi||key_gx(mac+1,7)~=keyshijian
        flagg=flagg+1;
    end
end
key_gx(k_g,2)=flagg;
vc=1;
for kgj=1:flagg
    pp=sum(key_gx(:,2)==kgj);
    if pp>1
        flag_key(vc,1)=kgj;
        vc=vc+1;
    end
end
%%%%%%%%%%%%%%%%%%%%编码所代表工件的工序%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%禁忌搜索算法+N7邻域+障碍图模型%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e7=1;
N7_Exchange=[];%交换编码
for i=1:vc-1%从第一个块开始
    B=key_gx(key_gx(:,2)==flag_key(i,1),:);%将该块的工序存储起来
    machine=B(1,5);%机器号
    a=B(1,4);%块首在机器上加工的序号
    b=size(B,1);%该块中关键工序的个数
    A=B(b,4);%块尾在机器上加工的序号
    if b==2%关键块只有两个工序
        if B(2,9)>=B(1,11)-B(1,14)                   %判断v的尾长是否大于等于JS[u]，或者说是否会产生不可行解
            N7_Exchange(e7,1)=a;                     %块首在机器上加工的序号
            N7_Exchange(e7,2)=A;                     %块尾在机器上加工的序号
            N7_Exchange(e7,3)=machine;               %机器号
            %%%%%%%%%%%%%%%近似评价  R_v  %%%%%%%%%%%%%%%%%%
            R_v=max(B(2,10)+B(2,15),B(1,12)+B(1,16));                %v的工件前序 或 u的机器前序
            R_u=max(B(1,10)+B(1,15),R_v+B(2,6));
            %%%%%%%%%%%%%%%近似评价  Q_v  %%%%%%%%%%%%%%%%%%
            Q_u=max(B(1,11),B(2,13))+B(1,6);       %u的工件后序 或 v的机器后序 +u的加工时间
            Q_v=max(B(2,11),Q_u)+B(2,6);           %v的工件后序 或 u两种情况最大+v的加工时间
            %%%%%%%%%%%%%%%  R+Q  %%%%%%%%%%%%%%%%%%%%%%%%%%
            N7_Exchange(e7,4)=max(R_v+Q_v,Q_u+R_u);  %评估值
            e7=e7+1;
        end
    else
        if b==3 % U L V
            a2=B(2,4);%块内的机器编码
            %%%%%%%%%%%%%%%%%%%%%块内工序移动要块尾之后%%%%%%%%%%%%%%%%%%%%%%%%
            if B(3,9)>=B(2,11)-B(2,14)      %判断v的尾长是否大于等于JS[u]，或者说是否会产生不可行解
                N7_Exchange(e7,1)=a2;%块内的编码
                N7_Exchange(e7,2)=A;%块尾的编码
                N7_Exchange(e7,3)=machine;
                %%%%%%%%%%%%%%%近似评价  R_v  新头长%%%%%%%%%%%%%%%%%%
                R_v=max(B(3,10)+B(3,15),B(2,12)+B(2,16));                %v的工件前序 或 L的机器前序
                R_l=max(R_v+B(3,6),B(2,10)+B(2,15));
                %%%%%%%%%%%%%%%近似评价  Q_v  新尾长%%%%%%%%%%%%%%%%%%
                J_M_l=max(B(2,11),B(3,13))+B(2,6);       %u的工件后序 或 v的机器后序 +u的加工时间
                Q_v=max(B(3,11),J_M_l)+B(3,6);           %v的工件后序 或 u两种情况最大+v的加工时间
                %%%%%%%%%%%%%%%  R+Q  %%%%%%%%%%%%%%%%%%%%%%%%%%
                N7_Exchange(e7,4)=max(R_v+Q_v,R_l+J_M_l);               %评估值
                e7=e7+1;
            end
            %%%%%%%%%%%%块内工序移动要块首之前%%%%%%%%
            if B(1,8)>=B(2,10)%%%%%%移动条件 块首工序的完工时间要≥v的前序工序的头长JPv
                N7_Exchange(e7,1)=a2;%块内的编码
                N7_Exchange(e7,2)=a;%块首的编码
                N7_Exchange(e7,3)=machine;
                %%%%%%%%%%%%%%%近似评价  R_v  %%%%%%%%%%%%%%%%%%
                J_M_l=max(B(1,12)+B(1,16),B(2,10)+B(2,15));
                R_v=max(B(1,10)+B(1,15),J_M_l+B(2,6));
                %%%%%%%%%%%%%%%近似评价  Q_v  %%%%%%%%%%%%%%%%%%
                Q_v=max(B(1,11),B(3,9))+B(1,6);
                Q_l=max(Q_v,B(2,11))+B(2,6);
                %%%%%%%%%%%%%%%  R+Q  %%%%%%%%%%%%%%%%%%%%%%%%%%
                N7_Exchange(e7,4)=max(R_v+Q_v,J_M_l+Q_l);               %评估值
                e7=e7+1;
            end
            %块首移动到块尾之后
            if B(3,9)>=B(1,11)-B(1,14)
                N7_Exchange(e7,1)=a;%块首的编码
                N7_Exchange(e7,2)=A;%块尾的编码
                N7_Exchange(e7,3)=machine;
                Rl=max(B(1,12)+B(1,16),B(2,10)+B(2,15));
                Rv=max(Rl+B(2,6),B(3,10)+B(3,15));
                Ru=max(Rv+B(3,6),B(1,10)+B(1,15));
                Qu=max(B(1,11),B(3,13))+B(1,6);
                Qv=max(Qu,B(3,11))+B(3,6);
                Ql=max(Qv,B(2,11))+B(2,6);
                temp=max(Rl+Ql,Rv+Qv);
                N7_Exchange(e7,4)=max(temp,Ru+Qu);
                e7=e7+1;
            end
            if B(1,8)>=B(3,10)
                N7_Exchange(e7,1)=A;%块首的编码
                N7_Exchange(e7,2)=a;%块尾的编码
                N7_Exchange(e7,3)=machine;
                Rv=max(B(1,12)+B(1,16),B(3,10)+B(3,15));
                Ru=max(Rv+B(3,6),B(1,10)+B(1,15));
                Rl=max(Ru+B(2,6),B(2,10)+B(2,15));
                Ql=max(B(2,11),B(3,13))+B(2,6);
                Qu=max(Ql,B(1,11))+B(1,6);
                Qv=max(Qu,B(3,11))+B(3,6);
                temp=max(Rl+Ql,Rv+Qv);
                N7_Exchange(e7,4)=max(temp,Ru+Qu);
                e7=e7+1;
            end
        else%关键工序大于3的情况
            R_vv=max(B(1,12)+B(1,16),B(2,10)+B(2,15));
            for g=2:b-1 %%%块首往后移动
                if B(g,9)>=B(1,11)-B(1,14)
                    R_v(1)=R_vv;
                    N7_Exchange(e7,1)=a;%块首
                    N7_Exchange(e7,2)=B(g,4);%块内
                    N7_Exchange(e7,3)=machine;
                    %%%%%%%%%%%%%%%近似评价  R_v  %%%%%%%%%%%%%%%%%%
                    G=g;
                    gg=2;
                    while G-2>0%更新头长
                        R_v(gg)=max(R_v(gg-1)+B(gg,6),B(gg+1,10)+B(gg+1,15));
                        gg=gg+1;
                        G=G-1;
                    end
                    R_v(g)=max(R_v(g-1)+B(g-1,6),B(g,10)+B(g,15));
                    Q_v(g)=max(B(1,11),B(g+1,9))+B(1,6);
                    Q_v(g-1)=max(B(g,11),Q_v(g))+B(g,6);
                    G=g;
                    gg=2;
                    while G-2>0%更新尾长
                        Q_v(g-gg)=max(Q_v(g-gg+1),B(g-gg+1,11))+B(g-gg+1,6);
                        gg=gg+1;
                        G=G-1;
                    end
                    Cm=R_v(1)+Q_v(1);
                    for k=2:g
                        temp=R_v(k)+Q_v(k);
                        if temp>Cm
                            Cm=temp;
                        end
                    end
                    N7_Exchange(e7,4)=Cm;               %评估值
                    e7=e7+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%
                if B(b,9)>=B(g,11)-B(g,14)%块内工序往后移动
                    N7_Exchange(e7,1)=B(g,4);%块内
                    N7_Exchange(e7,2)=A;%块尾
                    N7_Exchange(e7,3)=machine;
                    R_u(1)=max(B(g+1,10)+B(g+1,15),B(g,12)+B(g,16));
                    GG=b-g;
                    s_m=1;
                    while GG>1
                        R_u(s_m+1)=max(R_u(s_m)+B(g+s_m,6),B(g+s_m+1,10)+B(g+s_m+1,15));
                        s_m=s_m+1;
                        GG=GG-1;
                    end
                    R_u(b-g+1)=max(R_u(b-g)+B(b,6),B(g,10)+B(g,15));
                    Q_u(b-g+1)=max(B(g,11),B(b,13))+B(g,6);
                    Q_u(b-g)=max(Q_u(b-g+1),B(b,11))+B(b,6);
                    GG=b-g;
                    s_m=1;
                    while GG>1
                        Q_u(b-g-s_m)=max(Q_u(b-g-s_m+1),B(b-s_m,11))+B(b-s_m,6);
                        s_m=s_m+1;
                        GG=GG-1;
                    end
                    Cm=R_u(1)+Q_u(1);
                    for k=1:b-g+1
                        temp=R_u(k)+Q_u(k);
                        if temp>Cm
                            Cm=temp;
                        end
                    end
                    N7_Exchange(e7,4)=Cm;               %评估值
                    e7=e7+1;
                end
            end
            for y=2:b-2%块尾移动到块内之前
                if B(y,8)>=B(b,10)%g-1是
                    N7_Exchange(e7,1)=A;%块尾
                    N7_Exchange(e7,2)=B(y,4);%块内
                    N7_Exchange(e7,3)=machine;
                    Q_v(1)=max(B(b-1,11),B(b,13))+B(b-1,6);
                    Q_v(2)=max(Q_v(1),B(b-2,11))+B(b-2,6);
                    Y=y;
                    bb=2;
                    while b-Y>2
                        Q_v(bb+1)=max(Q_v(bb),B(b-bb+1,11))+B(b-bb+1,6);
                        bb=bb+1;
                        Y=Y+1;
                    end
                    Q_v(b-y+1)=max(Q_v(b-y),B(b,11))+B(b,6);
                    R_u(b-y+1)=max(B(y-1,8),B(b,10)+B(b,15));
                    R_u(b-y)=max(R_u(b-y+1)+B(b,6),B(y,10)+B(y,15));
                    R_u(b-y-1)=max(R_u(b-y)+B(y,6),B(y+1,10)+B(y+1,15));
                    Y=y;
                    bb=2;
                    while b-Y>2
                        R_u(b-y-bb)=max(R_u(b-y-bb+1)+B(y+bb-1,6),B(y+bb,10)+B(y+bb,15));
                        bb=bb+1;
                        Y=Y+1;
                    end
                    Cm=R_u(1)+Q_v(1);
                    for k=2:b-y+1
                        temp=R_u(k)+Q_v(k);
                        if temp>Cm
                            Cm=temp;
                        end
                    end
                    N7_Exchange(e7,4)=Cm;               %评估值
                    e7=e7+1;
                end
                %si_y=y+1;%块内工序往前移动
                if B(1,8)>=B(y,10)
                    N7_Exchange(e7,1)=B(y,4);%块内
                    N7_Exchange(e7,2)=a;%块首
                    N7_Exchange(e7,3)=machine;
                    Q_v(1)=max(B(y-1,11),B(y+1,9))+B(y-1,6);
                    %Q_v(2)=max(Q_v(1),B(si_y-2,11))+B(si_y-2,6);
                    MIy=y;
                    aa=2;
                    while MIy>2
                        Q_v(aa)=max(Q_v(aa-1),B(y-aa,11))+B(y-aa,6);
                        aa=aa+1;
                        MIy=MIy-1;
                    end
                    Q_v(y)=max(Q_v(y-1),B(y,11))+B(y,6);
                    R_v(y)=max(B(y,10)+B(y,15),B(1,12)+B(1,16));
                    R_v(y-1)=max(R_v(y)+B(y,6),B(1,10)+B(1,15));
                    MIy=y;
                    aa=2;
                    while MIy>2
                        R_v(y-aa)=max(R_v(y-aa+1)+B(aa-1,6),B(aa,10)+B(aa,15));
                        aa=aa+1;
                        MIy=MIy-1;
                    end
                    Cm=R_v(1)+Q_v(1);
                    for k=2:y
                        temp=R_v(k)+Q_v(k);
                        if temp>Cm
                            Cm=temp;
                        end
                    end
                    N7_Exchange(e7,4)=Cm;               %评估值
                    e7=e7+1;
                end
            end
        end
    end
end
