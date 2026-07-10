function  data3=DJSP_machine_decode(data3,n7_exchange)
global   count_machine   decode_GongJian Single_decode_JiQi
GongJian=decode_GongJian;%工件进度表
JiQi=Single_decode_JiQi;%机器进度表
g=1;
% n7_exchange=xnow.jobamount;
count=size(data3,1);
while g<=count%解码工序的个数
    for j=1:count_machine
        Machine_size=JiQi(j,2);%当前机器维度上该加工第几道工序
        if Machine_size<=n7_exchange
            number=(j-1)*n7_exchange+Machine_size;
            Job_size=data3(number,1);%该机器上的第几个工件
            if data3(number,3)==GongJian(Job_size,2)%如果某机器上的加工工序当前可加工
                start_time=max(GongJian(Job_size,1),JiQi(j,1));%开工时间
                end_time=start_time+data3(number,6);%完工时间
                data3(number,7)=start_time;%开工时间
                data3(number,8)=end_time;%完工时间
                JiQi(j,1)=end_time;%机器时间表更新
                JiQi(j,2)=JiQi(j,2)+1;%机器加工工序数量加1
                GongJian(Job_size,1)=end_time;%工件的加工时间
                GongJian(Job_size,2)=GongJian(Job_size,2)+1;%工件的工序加1
                g=g+1;
            end
        end
    end
end
end