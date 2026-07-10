function  data1=DJSP_later_data(data1)
global count_job count_machine job_gongxu 
new_Gongxu=data1(:,1);%选择工序的编码序号S
data1(:,1)=[];%备用数据
Cmax=max(data1(:,8));%最大完工时间
count=size(data1,1);
for a=1:count_job%%%%%%%%%%%工件进度表的初始值
    GongJian(a,1)=Cmax;%求最晚开完工
    GongJian(a,2)=job_gongxu;%求最晚开完工
end
for b=1:count_machine%%%%%%%%%%%机器进度表的初始值
    JiQi(b,1)=Cmax;%求最晚开完工
    JiQi(b,2)=0;%求反转邻域结构
end
for i=count:-1:1%遍历所有的编码工序，从后往前，与主动解码是一个相反的过程
    k=new_Gongxu(i,1);%工件，从第一个点开始,也表示k工件所在GJ行的位置
    [aa,~]=find(data1(:,1)==k&data1(:,3)==GongJian(k,2));
    jiqi=data1(aa,5);%所在的加工机器，也表示JQ所在的行
    time=data1(aa,6);%该工序的加工时长
    data1(aa,8)=min(GongJian(k,1),JiQi(jiqi,1));%最晚完工时间
    data1(aa,7)=data1(aa,8)-time;%最晚开工时间
    GongJian(k,1)=data1(aa,7);%更新工件时间
    JiQi(jiqi,1)=data1(aa,7);%更新机器时间
    GongJian(k,2)=GongJian(k,2)-1;
end