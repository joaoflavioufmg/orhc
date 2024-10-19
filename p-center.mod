#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# P-center[1]: Minimize the maximum travel distance (or time) among all demand 
# points and the allocated facilities, considering that every demand point is covered. 
# When the facilities are uncapacitated, the demand points are assigned to the 
# closet open facilities. Also referred to as location-allocation problems since 
# they require simultaneous facility location and allocation of the demand points 
# to the open facilities.
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m p-center.mod

set I:= 1..10;  # The set of demand points
set J:= 1..5;  # The set of candidate locations.

param d{I,J}:= Uniform(30,100); # The travel distance (or time) from demand point i ∈ I to candidate location j ∈ J.
param D{I}:= Uniform(75,80); # The maximum acceptable travel distance or time from demand point i ∈ I (the cover distance or time).
set N{i in I} := setof{j in J: d[i,j] <= D[i]} j; # The set of all candidate locations which can cover demand point i ∈ I, N[i] = {j ∈ J| d[ij] ≤ D[i]}.

##################
param w{I}:= Normal(50,10); # The demand point at i ∈ I.
param p:= 2; # The number of candidate locations to be established.
##################
check: p <= card(J);

display N;

var x{j in J}, >=0, binary; # 1, if a facility is established (located or opened) at candidate location j ∈ J; 0 otherwise. Also, integrality constraints.
##################
var y{i in I, j in N[i]}, >=0, binary; # 1,if demand point i is assigned to a facility at candidate location j ∈ Ni; 0 otherwise
##################
var L, >= 0; # L is an auxiliary variable (not a decision variable) that is used to compute the maximum distance.

# The objective (OF9) minimizes the maximum demand-weighted distance (or time) between a demand point and the (nearest) facility allocated to it.
minimize OF9: L;

# Constraints (10) guarantee that each demand point is covered by only one facility.
s.t. R10{i in I}: sum{j in N[i]}y[i,j] = 1;

# Constraint (11) states that p facilities are to be located.
s.t. R11: sum{j in J}x[j] = p;

# Constraints (12) determine the maximum demand-weighted distance (or time). Note that L is an auxiliary variable (not a decision variable) that is used to compute the maximum distance.
s.t. R12{i in I}: sum{j in N[i]}w[i]*d[i,j]*y[i,j] <= L;

# Constraints (13) show that demand points are only covered by open facilities.
s.t. R13{i in I, j in N[i]}: y[i,j] <= x[j]; 

solve;

printf:"\n===========================================\n";
printf:"Maximum demand-weighted distance: %.2f\n", OF9;
printf:"Selected Locations: %d", sum{j in J}x[j];
printf:"\n===========================================\n";
printf{j in J, i in I: j in N[i] and y[i,j]>0}:"[%s] <-- [%s]:\t%d km\t(Dem: %.2f);\n", j, i, d[i,j]*y[i,j], w[i]*y[i,j]; 
printf:"===========================================\n";

