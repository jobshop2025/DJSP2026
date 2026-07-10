clc
clear
close;                                  
global  data count_gongxu count_job    count_machine decode_JiQi decode_GongJian Row row_code job_gongxu n7_exchange Single_decode_JiQi
global bestsofar Bestsofar_Value
Init=initGlobals();
Big=[];
for Lar=1:10   %算例循环
    Small=[];
    for Tu=1:10 %求解次数
        data=xlsread('la1.xlsx','A1:F1000');   %文件名
        % data_1=sortrows(data,5);              
        Del_data=data;                          
        count_gongxu=size(data,1);              
        count_job=max(data(:,1));             
        job_gongxu=max(data(:,3));             
        count_machine=max(data(:,5));           
        n7_exchange=count_gongxu/count_machine; 
        for a=1:count_job                       
            decode_GongJian(a,1)=0;
            decode_GongJian(a,2)=1;
            row_code(a,1)=(a-1)*count_machine;
            Row(a,1)=(a-1)*count_machine+1;
            Row(a,2)=a*count_machine; 
            for b=1:count_machine
                if b==1
                    Del_data(row_code(a,1)+b,7)=0;
                    Del_data(row_code(a,1)+b,8)=Del_data(row_code(a,1)+b,6);
                else
                    Del_data(row_code(a,1)+b,7)=Del_data(row_code(a,1)+b-1,8);
                    Del_data(row_code(a,1)+b,8)=Del_data(row_code(a,1)+b,7)+Del_data(row_code(a,1)+b,6);
                end
            end
            Y_axis(a).data=[Del_data((row_code(a,1)+1):(row_code(a,1)+count_machine),:)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%
        factory=3;  %设置工厂数量
        Max_iter=100;    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for s=1:factory
            for b=1:count_machine                       
                decode_JiQi(b,s)=0;                       
            end
            Factory(1,s)=s;
        end
        for b=1:count_machine                        
            Single_decode_JiQi(b,1)=0;                       
            Single_decode_JiQi(b,2)=1;
        end
        for a=1:count_job                             
            decode_GongXu(a,1)=1;
            Jobb(a,1)=a;
        end
        %%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%
        Ns=1;
        Gongxu=data(:,1);                              
        randi_fac=Factory(randperm(factory));
        randi_Jobb=Jobb(randperm(count_job));
        for Si=1:Ns
            Solution(Si).code=Gongxu(randperm(count_gongxu));    
            for i=1:count_job
                Factory_Select(i,1)=randi([1 factory]);
                Factory_Select(i,2)=i;
            end
            
            for f=1:factory
                Factory_Select(randi_Jobb(f,1),1)=randi_fac(1,f);
            end
            Solution(Si).factory=Factory_Select;
        end
        Now_Sch=decom_many_factory(Solution,factory);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 图解法搜索  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        iter=0;
        bestsofar=Now_Sch;
        [a,b]=max([Now_Sch.value]);
        Bestsofar_Value=a;
        while iter<Max_iter
            iter=iter+1;
            [~,key]=max([Now_Sch.value]);
            key_job_amount=Now_Sch(key).jobamount;
            if key_job_amount==1
                break;
            end
            Ob_Neighborhood=[];
            cmax_now=[];
            cn=1; 
            for j=1:key_job_amount
                job_1=Now_Sch(key).job(1,j);    
                Data1=Now_Sch(key).data;        
                new_code=Now_Sch(key).code;     
                new_code((new_code(:,1)==job_1),:)=[];                    
                del_data1=Y_axis(job_1).data;                             
                Data1((Data1(:,1)==job_1),:)=[];                          
                Left_shift=DJSP_Left_shift(new_code,Data1);               
                Mid1_Sch=Now_Sch;
                ObstacleMap1_code=Djsp_Obstacle_Map(Left_shift,del_data1);
                Key_data=DJSP_Left_shift(ObstacleMap1_code,Now_Sch(key).data);
                Ob_Nei(1).code=ObstacleMap1_code;
                Ob_Nei(1).data=Key_data;
                Ob_Nei(1).value=max(Key_data(:,8));
                Ob_Nei(1).job=Now_Sch(key).job;
                Ob_Nei(1).jobamount=Now_Sch(key).jobamount;
                Mid1_Sch(key)=Ob_Nei;
                cmax_now(cn,1)=max([Mid1_Sch.value]);
                cn=cn+1;
                Ob_Neighborhood=[Ob_Neighborhood Mid1_Sch];
                rand_Factory=Factory(randperm(factory));
                nokey=rand_Factory(1,1);
                if rand_Factory(1,1)==key
                    nokey=rand_Factory(1,2);
                end
                Mid2_Sch=Now_Sch;
                
                ObstacleMap2_code=Djsp_Obstacle_Map(Now_Sch(nokey).data,del_data1);
                old_new_data=[Now_Sch(nokey).data;del_data1];
                no_Key_data=DJSP_Left_shift(ObstacleMap2_code,old_new_data);   
                Ob_Neig(1).code=ObstacleMap2_code;                   
                Ob_Neig(1).data=no_Key_data;                       
                Ob_Neig(1).value=max(no_Key_data(:,8));             
                Ob_Neig(1).job=[job_1 Now_Sch(nokey).job];          
                Ob_Neig(1).jobamount=Now_Sch(nokey).jobamount+1;     
                Ob_Neig(2).code=new_code;                            
                Ob_Neig(2).data=Left_shift;                        
                Ob_Neig(2).value=max(Left_shift(:,8));               
                job_sequence=Now_Sch(key).job;
                job_sequence(:,j)=[];                                        
                Ob_Neig(2).job=job_sequence;
                Ob_Neig(2).jobamount=Now_Sch(key).jobamount-1;       
                Mid2_Sch(nokey)=Ob_Neig(1);
                Mid2_Sch(key)=Ob_Neig(2);
                cmax_now(cn,1)=max([Mid2_Sch.value]);
                cn=cn+1;
                Ob_Neighborhood=[Ob_Neighborhood Mid2_Sch];
                rand_Factory=Factory(randperm(factory));
                nokey=rand_Factory(1,1);
                if rand_Factory(1,1)==key
                    nokey=rand_Factory(1,2);
                end
                Mid3_Sch=Now_Sch;
                No_data=Now_Sch(nokey).data;             
                No_code=Now_Sch(nokey).code;
                r=randi([1 Now_Sch(nokey).jobamount]);  
                r_t=Now_Sch(nokey).job(1,r);             
                No_data((No_data(:,1)==r_t),:)=[];       
                No_code((No_code(:,1)==r_t),:)=[];       
                Left_shift_3=DJSP_Left_shift(No_code,No_data); 
                ObstacleMap3_code=Djsp_Obstacle_Map(Left_shift_3,del_data1); 
                old3_new_data=[Left_shift_3;del_data1];
                Left_shift_3_3=DJSP_Left_shift(ObstacleMap3_code,old3_new_data); 
                Ob_Neigh(1).code=ObstacleMap3_code;
                Ob_Neigh(1).data=Left_shift_3_3;
                Ob_Neigh(1).value=max(Left_shift_3_3(:,8));
                job_sit=Now_Sch(nokey).job;
                job_sit(:,r)=[];
                Ob_Neigh(1).job=[job_sit job_1];
                Ob_Neigh(1).jobamount=Now_Sch(nokey).jobamount;
                del_data3=Y_axis(r_t).data;               
                ObstacleMap32_code=Djsp_Obstacle_Map(Left_shift,del_data3); 
                Left_shift3_2=[Left_shift;del_data3];
                Left_shift_3_data=DJSP_Left_shift(ObstacleMap32_code,Left_shift3_2);
                Ob_Neigh(2).code=ObstacleMap32_code;
                Ob_Neigh(2).data=Left_shift_3_data;
                Ob_Neigh(2).value=max(Left_shift_3_data(:,8));
                Ob_Neigh(2).jobamount=Now_Sch(key).jobamount;
                Ob_Neigh(2).job=[r_t job_sequence];
                Mid3_Sch(key)=Ob_Neigh(2);
                Mid3_Sch(nokey)=Ob_Neigh(1);
                cmax_now(cn,1)=max([Mid3_Sch.value]);
                cn=cn+1;
                Ob_Neighborhood=[Ob_Neighborhood Mid3_Sch];
            end
            %%%%  禁忌搜索  %%%%
            [c_v,num]=min(cmax_now(:,1));
            if c_v<Bestsofar_Value
                Bestsofar_Value=c_v;
                bestsofar=Ob_Neighborhood(((num-1)*factory+1):(num*factory));
            end
            Tr=0;
            TS_soul=[];
            TS_Neighborhood=Ob_Neighborhood;
            for s2=1:cn-1 
                key_solution=Ob_Neighborhood(((s2-1)*factory+1):(s2*factory));
                [q1,k1]=max([key_solution.value]);
                key_TS=key_solution(k1);
                YU=size(key_TS.data,1);
                LL=YU/count_machine;
                if  LL~=key_TS.jobamount
                    h=1;
                end
                [n7_ts,True]=tabu_search(key_TS);
                [a,b]=min([n7_ts.value]);
                key_TS.code=n7_ts(b).code;
                key_TS.value=a;
                key_TS.data=n7_ts(b).data;
                key_solution(k1)=key_TS;
                k=(s2-1)*factory+k1;
                TS_Neighborhood(k)=key_TS;
                [q2,k]=max([key_solution.value]);
                camx_value=q2;
                TS_soul(s2,1)=q2;
                TS_soul(s2,2)=s2;
                if camx_value<Bestsofar_Value
                    Bestsofar_Value=camx_value;
                    bestsofar=key_solution;
                    Tr=1;
                end
            end
            if Tr==0
                TS1=1;
                TS_soul=sortrows(TS_soul,1);
                s1=randi([1 3]);
                Now_Sch=TS_Neighborhood(((TS_soul(s1,2)-1)*factory+1):TS_soul(s1,2)*factory);
            else
                Now_Sch=bestsofar;
            end
        end
        Small=[Small bestsofar];
    end
    Big=[Big Small];
end