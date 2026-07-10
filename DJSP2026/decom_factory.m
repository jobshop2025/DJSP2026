function Now_Sch=decom_factory(Solution)
global count_machine count_job
now_solution_code=Solution.code;%当前解工序的编码
now_solution_factory=Solution.factory;%当前解的工厂
now_data=DJSP_decode(Solution);
%取各工厂的数据
factory_1_code=now_solution_code;
factory_2_code=now_solution_code;
factory_1=[];
factory_2=[];
Num_factory_1=0;
Num_factory_2=0;
for j=1:count_job
    if now_solution_factory(j,1)==1
        %确定工厂1的数据
        factory_1=[factory_1;now_data((j-1)*count_machine+1:j*count_machine,:)];%取出工厂1的数据
        Num_factory_1=Num_factory_1+1;                %确定工厂工件的数量
        Factory_1_name(1,Num_factory_1)=j;            %工件分别是什么
        factory_2_code((factory_2_code(:,1)==j),:)=[];%确定工厂的编码
    else
        %确定工厂2的数据
        factory_2=[factory_2;now_data((j-1)*count_machine+1:j*count_machine,:)];   
        Num_factory_2=Num_factory_2+1;
        Factory_2_name(1,Num_factory_2)=j;
        factory_1_code((factory_1_code(:,1)==j),:)=[];
    end
end
Cmax_1=max(factory_1(:,8));
Cmax_2=max(factory_2(:,8));
Now_Sch(1).code=factory_1_code;%工厂1的编码
Now_Sch(1).data=factory_1;%工厂1的调度数据
Now_Sch(1).value=Cmax_1;%工厂1的调度数据
Now_Sch(1).job=Factory_1_name;%工厂1加工的工件
Now_Sch(1).jobamount=Num_factory_1;%工厂1加工工件的数量
Now_Sch(2).code=factory_2_code;
Now_Sch(2).data=factory_2;
Now_Sch(2).value=Cmax_2;%工厂1的调度数据
Now_Sch(2).job=Factory_2_name;
Now_Sch(2).jobamount=Num_factory_2;