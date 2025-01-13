#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Set covering[1]: Minimizing the number of established facilities or the total 
# location cost, given a specified level of demand coverage that must be achieved. 
# Find the number and location of facilities such that all demand points are 
# within a specified travel distance (or time) of the facilities that serve them.
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m set-covering.mod

set I:= 1..10;  # The set of demand points
set J:= 1..5;  # The set of candidate locations.

# The travel distance (or time) from demand point i ∈ I to candidate location j ∈ J.
param d{I,J}:= Uniform(30,100); 
# The maximum acceptable travel distance or time from demand point i ∈ I 
# (the cover distance or time).
param D{I}:= Uniform(75,80); 
# The set of all candidate locations which can cover demand point i ∈ I, 
# N[i] = {j ∈ J| d[ij] ≤ D[i]}.
set N{i in I} := setof{j in J: d[i,j] <= D[i]} j; 

##################
param f{J}:= Normal(100,10); # The fixed cost of locating at candidate location j ∈ J.
##################

display N;

# 1, if a facility is established (located or opened) at candidate location j ∈ J; 
# 0 otherwise. Also, integrality constraints.
var x{j in J}, >=0, binary; 

# the objective function (OF1) minimizes the location cost of the facilities 
# which are needed to cover all demand points.
minimize OF1: sum{j in J}f[j]*x[j];

# Constraints (R2) ensure that each demand point must be covered.
s.t. R2{i in I}: sum{j in N[i]}x[j] >= 1;

solve;

printf:"\n===========================================\n";
printf:"Total Cost: %.2f\n", OF1;
printf:"Selected Locations: %d", sum{j in J}x[j];
printf:"\n===========================================\n";
printf{j in J, i in I: x[j]>0}:"[%s] <-- [%s]:\t%d km\t($ %.2f);\n", 
j, i, d[i,j]*x[j], f[j]*x[j]; 
printf:"===========================================\n";

