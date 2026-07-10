function data1=DJSP_decode(new_code)
global count_gongxu data  decode_GongJian decode_JiQi  row_code
data1=data;%备用数据
% shop1=data;
% shop2=data;
GongJian=decode_GongJian;
JiQi=decode_JiQi;
code=new_code.code;
shop=new_code.factory;
for i=1:count_gongxu%遍历所有的工序
    k=code(i,1);%工件，从第一个点开始,也表示k工件所在GJ行的位置
    aa=row_code(k,1)+GongJian(k,2);
    jiqi=data1(aa,5);%所在的加工机器，也表示JQ所在的行
    time=data1(aa,6);%该工序的加工时长
    fac=shop(k,1);%该工件在哪个工厂加工
    data1(aa,7)=max(GongJian(k,1),JiQi(jiqi,fac));
    data1(aa,8)=data1(aa,7)+time;
    JiQi(jiqi,fac)=data1(aa,8);
    GongJian(k,1)=data1(aa,8);
    GongJian(k,2)=GongJian(k,2)+1;
end
end