#############################################################################
# Operations Research for Health Care
# Lesson 8/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Effective coverage metrics on health care [1].
# 
# ref: [1] Shengelia, B., Tandon, A., Adams, O. B., and Murray, C. J. (2005).
# Access, utilization, quality, and effective coverage: an integrated 
# conceptual framework and measurement strategy. 
# Social science & medicine, 61(1):97–109. 
#############################################################################
# glpsol -m coverage.mod -d cover.dat

set I; # Individual
set J; # Intervention
set K; # Provider

# (utilization) The probability that individual $i$ will receive 
# intervention $j$.  Distance impacts. Utilization appears to 
# drop-off exponentially with distance from a provider.
param Ui{I,J,K}; 
param U{i in I, j in J}:= min{k in K}Ui[i,j,k]; 

# display U;

check{i in I, j in J}: U[i,j] >=0;
check{i in I, j in J}: U[i,j] <= 1;

# Health Gain (HG) of $i$ from intervention $j$ from provider k.
param HGi{I,J,K}; 
param HGimax{i in I, j in J} := max{k in K} HGi[i,j,k]; 
param HGij{i in I, j in J}:= sum{k in K}Ui[i,j,k]*HGi[i,j,k];
# Performance of provider $k$ (max = optimal perfomance)
param HGmax{j in J}:= max{i in I}HGij[i,j];

# display HGi;
# display HGimax;
# display HGij;
# display HGmax;

# (Quality) The expected quality of intervention $j$ to be received 
# by person $i$. 
# param Q{i in I, j in J} := sum{k in K} (HGi[i,j,k]*Ui[i,j,k] / HGimax[i,j]);
param Q{i in I, j in J} := HGij[i,j] / HGimax[i,j];

# display Q;

# (need) The individual i’s need for intervention j.
param N{I,J}, binary; 

# Effective coverage for individual $i$  with intervention $j$. 
param ECi{i in I, j in J} := Q[i,j]*U[i,j]*N[i,j]; 

# display ECi;

check{i in I, j in J}: ECi[i,j] >=0;
check{i in I, j in J}: ECi[i,j] <= 1;

# Effective coverage for POPULATION for SPECIFIC intervention $j$. 
param ECjn{j in J}:= sum{i in I} ECi[i,j]*HGij[i,j]*N[i,j]; # Numerator ECj
param ECjd{j in J}:= sum{i in I} HGij[i,j]*N[i,j];          # Denominator ECj
param ECj{j in J}:= if ECjd[j] == 0 then 0 else ECjn[j] / ECjd[j]; 

# display ECj;

# Effective coverage for ALL POPULATION. 
param ECn:= sum{j in J} ECj[j]*HGmax[j]; 
param ECd:= sum{j in J} HGmax[j]; 
param EC:= ECn/ECd; 

# display EC;

solve;

printf "\n========= Utilization ========\n\t";
printf{j in J} "[%d]\t",j;
printf "\n";
for{i in I}{
printf "[%d]", i;
printf{j in J} "\t%.2f", U[i,j];
printf "\n";
}
printf "==============================\n\n";

printf "\n========= Health Gain ========\n\t";
printf{j in J} "[%d]\t",j;
printf "\n";
for{i in I}{
printf "[%d]", i;
printf{j in J} "\t%.2f", HGij[i,j];
printf "\n";
}
printf "==============================\n\n";

printf "\n=========== Quality ==========\n\t";
printf{j in J} "[%d]\t",j;
printf "\n";
for{i in I}{
printf "[%d]", i;
printf{j in J} "\t%.2f", Q[i,j];
printf "\n";
}
printf "==============================\n\n";

printf "\n===== Effective Coverage [i]==\n\t";
printf{j in J} "[%d]\t",j;
printf "\n";
for{i in I}{
printf "[%d]", i;
printf{j in J} "\t%.2f", ECi[i,j];
printf "\n";
}
printf "==============================\n\n";

printf "\n= POP Effective Coverage [j] =\n\t";
printf{j in J} "[%d]\t",j;
printf "\n";
printf "    ";
printf{j in J} "\t%.2f", ECj[j];
printf "\n";
printf "==============================\n\n";

printf "=======================================\n";
printf "POPULATION EFFECTIVE COVERAGE: %.2f %%\n", EC*100;
printf "=======================================\n\n";

data;


set I:= 1   2   3   4   5;  # Individual
set J:= 1   2   3;          # Intervention
set K:= 1   2;              # Provider

# (utilization) The probability that individual $i$ will receive 
# intervention $j$.  Distance impacts. Utilization appears to 
# drop-off exponentially with distance from a provider.
param Ui
[*,*,1]:	1	2	3	:=
1	0.23	0.43	0.99	
2	0.24	0.63	0.39	
3	0.29	0.39	0.82	
4	0.96	0.45	0.55	
5	0.89	0.39	0.23	
				
[*,*,2]:	1	2	3	:=
1	0.77	0.57	0.01	
2	0.76	0.37	0.61	
3	0.71	0.61	0.18	
4	0.04	0.55	0.45	
5	0.11	0.61	0.77	
;

# Health Gain (HG) of $i$ from intervention $j$ from provider k.
param HGi
[*,*,1]:	
    1	    2	    3	:=
1	3.47	4.87	4.69	
2	3.42	0.36	2.26	
3	1.44	3.81	2.19	
4	1.79	0.79	4.67	
5	0.51	0.99	1.48	
				
[*,*,2]:	
    1	    2	    3	:=
1	3.59	0.24	4.07	
2	2.17	2.41	2.23	
3	4.25	4.65	3.4	
4	2.15	4.77	1.94	
5	1.98	4.8	    3.36	
;
 

# (need) The individual i’s need for intervention j.
param N:
	1	2	3	:=
1	0	1	1	
2	1	1	0	
3	1	0	0	
4	1	1	1	
5	0	1	1	
;

end;

