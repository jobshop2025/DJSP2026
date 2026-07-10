function vars=initGlobals()
    global data count_gongxu count_job count_machine decode_JiQi decode_GongJian ...
           Row row_code job_gongxu n7_exchange Single_decode_JiQi
    global bestsofar Bestsofar_Value

    vars = {'data','count_gongxu','count_job','count_machine','decode_JiQi', ...
            'decode_GongJian','Row','row_code','job_gongxu','n7_exchange', ...
            'Single_decode_JiQi','bestsofar','Bestsofar_Value'};

    for i = 1:length(vars)
        assignin('base', vars{i}, []);
    end
end
