#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# P-median[1]: These problems aim to locate p facilities in a network
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m p-median.mod

set I:= 1..10;  # The set of demand points
set J:= 1..5;  # The set of candidate locations.

# The travel distance (or time) from demand point i ∈ I to candidate 
# location j ∈ J.
param d{I,J}:= Uniform(30,100); 
param w{I}:= Normal(50,10); # The demand point at i ∈ I.
param p:= 3; # The number of candidate locations to be established.
check: p <= card(J);

##################
# 1, if a facility is established (located or opened) at candidate location j ∈ J; 
# 0 otherwise. Also, integrality constraints.
var x{j in J}, >=0, binary; 
# 1,if demand point i is assigned to a facility at candidate location j ∈ Ni; 
# 0 otherwise
var y{i in I, j in J}, >=0, binary; 
##################

# the objective (OF17) minimizes the total demand-weighted travel distance (or time). 
minimize OF17: sum{i in I, j in J}w[i]*d[i,j]*y[i,j];

# Constraints (18) show that each demand point is assigned to only one facility.
s.t. R18{i in I}: sum{j in J}y[i,j] = 1;

# Constraint (19) specifies the total number of facilities to be established. 
s.t. R19: sum{j in J}x[j] = p;

# Constraints (20) limit assignments to open facilities.
s.t. R20{i in I, j in J}: y[i,j] <= x[j]; 

solve;

printf:"\n===========================================\n";
printf:"Total demand-weighted distance: %.2f\n", OF17; 
printf:"Selected Locations: %d", sum{j in J}x[j];
printf:"\n===========================================\n";
printf{j in J, i in I: y[i,j]>0}:"[%s] <-- [%s]:\t%d km\t(Dem: %.2f);\n", 
j, i, d[i,j]*y[i,j], w[i]*y[i,j]; 
printf:"===========================================\n";

