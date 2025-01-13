#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Fixed charge[1]: Closely related to P-median. However, it attempt to minimize 
# the total cost of facility opening and traveling.
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m fixed-charge.mod

set I:= 1..10;  # The set of demand points
set J:= 1..5;  # The set of candidate locations.

# The travel distance (or time) from demand point i ∈ I to candidate location
#  j ∈ J.
param d{I,J}:= Uniform(30,100); 
# The demand point at i ∈ I.
param w{I}:= Normal(50,10); 
##################
# The fixed charge of establishing a facility at candidate location j ∈ J.
param f{J}:= Normal(100,10); 
# The transportation cost per item per distance unit (the variable 
# transportation cost).
param v:= 5; 
##################
# facility Capacity (In a capacitated Fixed-charge Location Problem)
param U{J}:= Uniform(80,120); 
##################
# 1, if a facility is established (located or opened) at candidate location 
# j ∈ J; 0 otherwise. Also, integrality constraints.
var x{j in J}, >=0, binary; 
# 1,if demand point i is assigned to a facility at candidate location 
# j ∈ Ni; 0 otherwise
var y{i in I, j in J}, >=0, binary; 
##################

# The objective (23) minimizes the total cost which includes the 
# facility-opening and transportation costs.
minimize OF23: sum{j in J}f[j]*x[j] + v*sum{i in I, j in J}w[i]*d[i,j]*y[i,j];

# Constraints (24) ensure that each demand node is assigned to an open 
# facility,
s.t. R24{i in I}: sum{j in J}y[i,j] = 1;

# Constraints (25) restrict assignments to open facilities.
s.t. R25{i in I, j in J}: y[i,j] <= x[j]; 

# In a capacitated Fixed-charge Location Problem (FCLP), a new parameter 
# Uj is defined as the maximum capacity of each facility j
s.t. R26{j in J}: sum{i in I} w[i]*y[i,j] <= U[j]; 

solve;

printf:"\n===========================================\n";
printf:"Total fixed and variable costs: %.2f\n", OF23; 
printf:"Selected Locations: %d", sum{j in J}x[j];
printf:"\n===========================================\n";
printf{j in J: x[j]>0}:"Capacity [%s]: %6.2f <-- Total Dem: %6.2f;\n", 
j, U[j], sum{i in I} w[i]*y[i,j]; 
printf:"\n===========================================\n";
printf{j in J, i in I: y[i,j]>0}:"[%s] <-- [%s]:\t%d km\t(Dem: %.2f);\n",
j, i, d[i,j]*y[i,j], w[i]*y[i,j]; 
printf:"===========================================\n";

