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
# Stochastic Programming Facility Location Problem
#############################################################################
# > glpsol -m .\sp-1.mod -d .\sp-1.dat --cuts

################################################
# Uncapacitated Facility Location Problem - UFLP 
################################################
# Complete Recourse - Always feasible

set W; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

set I; # The set of all origin.
set J; # The set of all (possible) destination points.

param F{J}; # Setup cost for facility j in J                

param D{I,W}; # Demand at oring i in I and scenario w in W
param C{I,J,W}; # Distance from i in J, to j in J and scenario w in W

# probability πω can be associated to scenario ω
# When probabilities can be associated with the scenarios, we can measure this
# relevance by using the expected value of perfect information (EVPI).
# The EVPI is the difference between the weighted sum of the optimal values for all
# scenarios (using the probabilities as weights) and the minimum expected cost.
param PI{W}; 
check: sum{w in W}PI[w] >=0.999;
check: sum{w in W}PI[w] <= 1.001;

# The fraction of the demand of customer i in J, 
# to destj in J and scen w in W
var x{I,J,W} >= 0; 

# ex ante: decision location
# If a facility is located at j in J
var y{J}, binary; # s.t. R829

minimize FO834: sum{j in J}F[j]*y[j] + sum{w in W}PI[w]*(sum{i in I, j in J}C[i,j,w]*D[i,w]*x[i,j,w]);

s.t. R828: sum{j in J} y[j] >= 1;

# Each origin has a single destination, for every scenario
s.t. R835{i in I, w in W}: sum{j in J}x[i,j,w] = 1;

# Priority on locating locally fisrt, for every scenario
s.t. R836{i in I, j in J, w in W}: x[i,j,w] <= y[j];

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
printf: "Expected COST = %.2f\n\n", FO834;

end;

