proc export 
  data=Raw.Adverse_Raw 
  dbms=xlsx 
  outfile="C:\PROJECT\QPS3\Advsere_Effect" 
  replace;
run;
