function data1=DJSP_Left_shift(new_code,data1)
global  decode_GongJian decode_JiQi 
Count_gongxu=size(new_code,1);
GongJian=decode_GongJian;
JiQi=decode_JiQi;      %同属一台机器
for i=1:Count_gongxu                    %遍历所有的工序
    k=new_code(i,1);                    %工件，从第一个点开始,也表示k工件所在GJ行的位置
    [aa,~]=find(data1(:,1)==k&data1(:,3)==GongJian(k,2));
    jiqi=data1(aa,5);%所在的加工机器，也表示JQ所在的行
    time=data1(aa,6);%该工序的加工时长
    data1(aa,7)=max(GongJian(k,1),JiQi(jiqi,1));
    data1(aa,8)=data1(aa,7)+time;
    GongJian(k,1)=data1(aa,8);
    JiQi(jiqi,1)=data1(aa,8);
    GongJian(k,2)=GongJian(k,2)+1;
end
end