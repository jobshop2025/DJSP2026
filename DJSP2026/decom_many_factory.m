function Now_Sch=decom_many_factory(Solution,factory)
global count_machine count_job
now_solution_code=Solution.code;%当前解工序的编码
now_solution_factory=Solution.factory;%当前解的工厂
now_data=DJSP_decode(Solution);
for f=1:factory
    Now_Sch(f).code=now_solution_code;
    Now_Sch(f).data=[];
    Now_Sch(f).job=[];
    Now_Sch(f).jobamount=0;
end
for j=1:count_job
    fac=now_solution_factory(j,1);%表示该工件在哪个工厂
    Now_Sch(fac).data=[Now_Sch(fac).data;now_data((j-1)*count_machine+1:j*count_machine,:)];
    Now_Sch(fac).job=[Now_Sch(fac).job j]; %工件
    Now_Sch(fac).jobamount=Now_Sch(fac).jobamount+1;                %确定工厂工件的数量
end
zai=0;
for m=1:factory
    if Now_Sch(m).jobamount>0
        for j=1:count_job
            for i=1:Now_Sch(m).jobamount
                if Now_Sch(m).job(1,i)==j%说明该工件在该工厂加工
                    zai=1;
                end
            end
            if zai==0%不在
                 Now_Sch(m).code((Now_Sch(m).code(:,1)==j),:)=[];
            end
            zai=0;
        end
        Now_Sch(m).value=max(Now_Sch(m).data(:,8));
    else
        Now_Sch(m).value=0;
        Now_Sch(m).code=[];
    end
end
end