#############################################################################
# Operations Research for Health Care
# Lesson 11/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Health Care Facility Location Under Uncertainty
# Robust Optimization
# Ref: Correia, I., & Saldanha-da-Gama, F. (2019). 
# Facility location under uncertainty. Location science, 185-213.
# Minmax Cost
#############################################################################
# glpsol -m ro.mod -d ro.dat --cuts

# ################################################ 
# # P-median
# ################################################
# set I; # The set of all origin.
# set J; # The set of all (possible) destination points.

# param D{I}; # Demand at oring i in I
# param A{I,J}; # Distance or travel time from i in J, to j in J
# param P; # New facilities to be located

# var x{I,J}, binary; # If origin i in J, is allocated to destination j in J

# minimize FO81: sum{i in I, j in J}D[i]*A[i,j]*x[i,j];

# # Each origin has a single destination
# s.t. R82{i in I}: sum{j in J}x[i,j] = 1;

# # Priority on locating locally fisrt
# s.t. R83{i in I, j in J}: x[i,j] <= x[j,j];

# s.t. R84: sum{j in J} x[j,j] = P;

# solve;

# display{i in I, j in J: x[i,j] > 0} x[i,j];
# ################################################


################################################
# The Minmax Cost P-median
################################################

set W; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

set I; # The set of all origin.
set J; # The set of all (possible) destination points.

param D{I,W}; # Demand at oring i in I and scenario w in W
param A{I,J,W}; # Distance from i in J, to j in J and scenario w in W
param P; # New facilities to be located

# Not used in this model
param Vopt{W} default 0; 

# If origin i in J, is allocated to destj in J and scen w in W
var x{I,J,W}, binary; 

# ex ante: decision location
var y{J}, binary; 

var v; # 

# Minmax objective is a combination of FO86 and R87
minimize FO86: v;

s.t. R87{w in W}: sum{i in I, j in J}D[i,w]*A[i,j,w]*x[i,j,w] <= v;

# Each origin has a single destination
s.t. R88{i in I, w in W}: sum{j in J}x[i,j,w] = 1;

# Priority on locating locally fisrt
s.t. R89{i in I, j in J, w in W}: x[i,j,w] <= y[j];

s.t. R810: sum{j in J} y[j] = P;

solve;

printf: "\n\nDecision: Locate ";
printf{j in J: y[j] > 0}: "[%d] ",j;
printf"\n\n";
for{w in W}{
    printf"Dest  Ori [%d]\n", w;
    for{j in J, i in I: x[i,j,w] > 0}{
        printf"[%d] <- %d\n",j,i;
    }
    printf: "\n";
}
printf"\n";

printf: "Minmax Cost = %.2f\n\n", FO86;

end;
################################################
