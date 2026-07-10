function  data2=DJSP_I_i_dataExchange(i,I,MAChine,data2,n7_exchange,count)
Number=(MAChine-1)*n7_exchange;
i=i+Number;%第几行
I=I+Number;
if i<I
    if I~=count%说明I不是最后一台机器上的最后一道工序
        if i~=1%i不是第一道工序
            data2=[data2(1:I,:);data2(i,:);data2(I+1:end,:)];%将i放在I后面
            data2=[data2(1:i-1,:);[];data2(i+1:end,:)];%再把i去掉
        else
            data2=[data2(2:I,:);data2(i,:);data2(I+1:end,:)];%i去掉，将i放在I后面
        end
    else%I为最后一道工序
        data2=[data2(1:I,:);data2(i,:)];%将i放在I后面
        data2=[data2(1:i-1,:);[];data2(i+1:end,:)];%再把i去掉
    end
else%i>I
    if i~=count%i不是最后一道工序
        if I==1
            data2=[data2(i,:);data2(1:end,:)];%将i放在I前面
            data2=[data2(1:i,:);[];data2(i+2:end,:)];%再把i去掉
        else
            data2=[data2(1:I-1,:);data2(i,:);data2(I:end,:)];%将i放在I前面
            data2=[data2(1:i,:);[];data2(i+2:end,:)];%再把i去掉
        end
    else
        data2=[data2(1:I-1,:);data2(i,:);data2(I:end-1,:)];%将i放在I前面
    end
end
end