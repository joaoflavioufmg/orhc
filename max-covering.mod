#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Maximal covering[1]: Determine the location of p facilities in order to maximize 
# the demand covered within a pre-specified maximum coverage distance, taking 
# into account the level of demand at each point. 
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m max-covering.mod

set I:= 1..10;  # The set of demand points
set J:= 1..5;  # The set of candidate locations.

# The travel distance (or time) from demand point i ∈ I to candidate location j ∈ J.
param d{I,J}:= Uniform(30,100); 
# The maximum acceptable travel distance or time from demand point i ∈ I (the cover 
# distance or time).
param D{I}:= Uniform(25,80); 
# The set of all candidate locations which can cover demand point i ∈ I, 
# N[i] = {j ∈ J| d[ij] ≤ D[i]}.
set N{i in I} := setof{j in J: d[i,j] <= D[i]} j; 

##################
param w{I}:= Normal(50,10); # The demand point at i ∈ I.
param p:= 2; # The number of candidate locations to be established.
##################
check: p <= card(J);

display N;

# 1, if a facility is established (located or opened) at candidate location j ∈ J; 
# 0 otherwise. Also, integrality constraints.
var x{j in J}, >=0, binary; 
##################
# 1, if demand point ∈ i I is covered; 0 otherwise.
var z{i in I}, >=0, binary; 
##################

# The objective (OF4) maximizes the total covered demand.
maximize OF4: sum{i in I}w[i]*z[i];

# Constraint (5) states that p facilities are to be located.
s.t. R5: sum{j in J}x[j] = p;

# Constraints (6) require that demand points are only covered by open facilities.
s.t. R6{i in I}: z[i] <= sum{j in N[i]}x[j];

solve;

printf:"\n===========================================\n";
printf:"Demand covered: %.2f\n", OF4;
printf:"Selected Locations: %d", sum{j in J}x[j];
printf:"\n===========================================\n";
printf{j in J, i in I: x[j]>0 and z[i]>0}:"[%s] <-- [%s]:\t%d 
km\t(Dem: %.2f);\n", j, i, d[i,j]*z[i], w[i]*z[i]; 
printf:"===========================================\n";

