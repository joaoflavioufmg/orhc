#############################################################################
# Operations Research for Health Care
# Lesson 7/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Intermediate Facility Location Problem [1]: Considering fixed facilities, 
# choose intermediate facilities accorting a criteria that improve service
# quality.
# 
# ref: [1] Kuehn, Alfred A.; Hamburger, Michael J. . (1963). A Heuristic Program 
# for Locating Warehouses. # Management Science, 9(4), 643–666. 
# doi:10.1287/mnsc.9.4.643 
#############################################################################
# glpsol -m intermediate.mod

param p:= 2; # Types of Patients (cronic or acute) (Good)
set H:= 1..p; 

param q:= 10; # FIXED Primary health care units (factory)
set I:= 1..q;

param r:= 30; # Intermediate facility candidates location (Warehouse)
set J:= 1..r;

param s:= 5; # FIXED Hospital units (customer)
set K:= 1..s;

################################################

param A{H,I,J}:= 1; # Travel cost/ patients h, from PHC i to IHC j

param B{H,J,K}:= 2; # Travel cost/ patients h, from IHC j to Hospital k

param S{H,J}:= 10; # Variable cost of IHC j / patient h

param F{J}:= 500; # Fixed cost per period for operating IHC j

param Q{H,K}:= 100; # Patients h requiring service at Hospital k (demand)

param W{J}:= 50; # Service operating capacity at IHC j

param Y{H,I}:= 100; # PHC i capacity for patients h

#################################################

var x{H,I,J,K}, >= 0; # Patients h flow from PHC > SHC > Hospital

var z{J}, >= 0, binary; # If SHC is used (1) or not (0)

#################################################

minimize Total_Costs:
    sum{h in H, i in I, j in J, k in K} (A[h,i,j]+B[h,j,k])*x[h,i,j,k] +
    sum{j in J}F[j]*z[j] + 
    sum{h in H, i in I, j in J, k in K}S[h,j]*x[h,i,j,k]
;

# Patients h demand for service at hospital k must be supplied
s.t. R1{h in H, k in K}: sum{i in I, j in J}x[h,i,j,k] = Q[h,k];

# PHC i capacity for patients h cannot be exceeded
s.t. R2{h in H, i in I}: sum{j in J, k in K}x[h,i,j,k] <= Y[h,i];

# IHC j capacity for patients h cannot be exceeded
s.t. R3{j in J}: sum{h in H, i in I, k in K}x[h,i,j,k] <= W[j]*z[j];

# If IHC j is activated, it must pay fixed costs
# s.t. R4{j in J}: sum{h in H, i in I, k in K}x[h,i,j,k] <= W[j];

solve;

printf: "\n========================================\n";
printf: "Intermediate Health Care Units\n";
printf: "========================================\n";
printf: "Logist   Cost: $%6.2f\n", sum{h in H, i in I, j in J, k in K} (A[h,i,j]+B[h,j,k])*x[h,i,j,k];
printf: "Fixed    Cost: $%6.2f\n", sum{j in J}F[j]*z[j];
printf: "Variable Cost: $%6.2f\n", sum{h in H, i in I, j in J, k in K}S[h,j]*x[h,i,j,k];
printf: "========================================\n";
printf: "Total    Cost: $%6.2f\n", Total_Costs;
printf: "========================================\n";
printf: "Hospital: Requirement\t Met\n";
printf: "========================================\n";
printf{k in K}: "Hospital [%2d]: %.2f\t%.2f\n", k, 
sum{h in H}Q[h,k], sum{h in H, i in I, j in J} x[h,i,j,k];
printf: "========================================\n";
printf: "PHC     : Capacity\t Met\tUse(%%)\n";
printf: "========================================\n";
printf{i in I}: "PHC      [%2d]: %.2f\t%.2f\t%.2f%%\n", i, 
sum{h in H}Y[h,i], sum{h in H, j in J, k in K} x[h,i,j,k],
((sum{h in H, j in J, k in K} x[h,i,j,k])/(sum{h in H}Y[h,i]))*100;
printf: "========================================\n";
printf: "IHC     :\tFlow\tUse(%%)\n";
printf: "========================================\n";
printf{j in J}: "IHC     [%2d]:\t%.2f\t%.2f%%\n", 
j, sum{h in H, i in I, k in K} x[h,i,j,k],
sum{h in H, i in I, k in K} x[h,i,j,k]/(W[j]*z[j]+1e-5)*100;
printf: "========================================\n";
printf: "Detailed Flow\n";
printf: "========================================\n";
printf: "Pac\tPHC\tIHC\tHosp.\tFlow\n";
printf: "========================================\n";
printf{h in H, i in I, j in J, k in K: x[h,i,j,k] > 0}: 
"[%d]\t[%d]\t[%d]\t[%d]:\t%.2f\n", h,i,j,k,x[h,i,j,k];
printf: "========================================\n";

# display{h in H, i in I, j in J, k in K: x[h,i,j,k] > 0}: x[h,i,j,k];
# display{j in J: z[j] > 0}: z[j];


end;

