function   [n7_ts,True]=tabu_search(xnow)
%%%%%%%%%%%%%%算法初始参数%%%%%%%%%%%%%%%%%
Bestsofar_Value=xnow.value;
n7_exchange=xnow.jobamount;
count=size(xnow.data,1);
iter=0;
tabu=[];
n7ts_size=1;
maxiter=200;
T=randi([8 15]);%%禁忌长度下界为L=10+N/M，N为工件数，M为机器数，若N小于等于2M,则上界为1.4L,否则为1.5L
True=0;
%%%%%%%%%%%%%%%% 迭代 %%%%%%%%%%%%%%%%%%%%%%
while iter<maxiter
    iter=iter+1;
    %%%%%%%%%%产生邻域解%%%%%%%%
    [neighbor_move,data2]=hl_N7_Neighbour(xnow,iter);
    size_move=size(neighbor_move,1);
%     if rand<0.95
    if size_move==0
        if iter==1%如果一个邻域解也没有直接退出
           n7_ts=xnow;
        end
        break
    end
    neighbor_move=sortrows(neighbor_move,4);
    
%     else
%         index=randperm(size_move);
%         neighbor_move=neighbor_move(index,:);
%     end
    for hl=1:size_move
        i=neighbor_move(hl,1);%i，I代表机器上编码的位置
        I=neighbor_move(hl,2);
        MAChine=neighbor_move(hl,3);%在哪个机器上交换
        old_tabu_L=[MAChine;data2((MAChine-1)*n7_exchange+1:MAChine*n7_exchange,1)];%保留老状态，禁忌使用
        Move_data=DJSP_I_i_dataExchange(i,I,MAChine,data2,n7_exchange,count);%交换
        tabu_L=[MAChine;Move_data((MAChine-1)*n7_exchange+1:MAChine*n7_exchange,1)];%新状态
        Ans=0;%禁忌表的标记，0 不在 ；1 在
        if isempty(tabu)%如果禁忌表是空的.
            tabu=old_tabu_L;
            break;
        else
            size_tabu=size(tabu,2);
            for f=1:size_tabu%判断是否在禁忌表里
                if tabu(1,f)==MAChine%首先判断机器是否相同
                    Ans=isequal(tabu(:,f),tabu_L);%相同为1，不同为0
                    if Ans==1  %一旦相同则退出 
                        break
                    end
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%更新禁忌表%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if Ans==0%该邻域移动不在禁忌表里
            tabu=[tabu old_tabu_L];%将老状态加入到禁忌表里
            break;
        else
            if  neighbor_move(hl,4)<Bestsofar_Value%是否满足特赦要求
                Ans=0;%标记不在禁忌表里
                break;
            end
        end
    end
    if size(tabu)>T
        tabu(:,1)=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%更新当前解和最优解%%%%%%%%%%%%%%%%%%%%%%    
    if Ans==0   %如果该邻域解不在禁忌表或满足特赦准则
        mdecode=DJSP_machine_decode(Move_data,n7_exchange);%精确解码
        mdecode=sortrows(mdecode,7);
        xnow.code=mdecode(:,1);%编码
        mdecode=sortrows(mdecode,1);
        xnow.value=max(mdecode(:,8));
        xnow.data=mdecode;
    else   %如果邻域解均未禁忌
        randnum=randi([1 size_move]);
        i=neighbor_move(randnum,1);%i，I代表机器上编码的位置
        I=neighbor_move(randnum,2);
        MAChine=neighbor_move(randnum,3);%在哪个机器上交换
        Move_data=DJSP_I_i_dataExchange(i,I,MAChine,data2,n7_exchange,count);%交换
        mdecode=DJSP_machine_decode(Move_data,n7_exchange);%精确解码
        mdecode=sortrows(mdecode,7);
        xnow.code=mdecode(:,1);%编码
        mdecode=sortrows(mdecode,1);
        xnow.value=max(mdecode(:,8));
        xnow.data=mdecode;
    end
%     if xnow.value<Bestsofar_Value
%         bestsofar.value=xnow.value;
%         bestsofar.code=xnow.code;
%         bestsofar.data=xnow.data;
%         True=1;
%     end
if xnow.value<Bestsofar_Value
    Bestsofar_Value=xnow.value;
end
    n7_ts(n7ts_size).value=xnow.value;
    n7_ts(n7ts_size).code=xnow.code;
    n7_ts(n7ts_size).data=xnow.data;
    n7ts_size=n7ts_size+1;
%     if bestsofar.value<=930
%         break
%     end

end
