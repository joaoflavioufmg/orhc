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
# > glpsol -m .\sp-cflp.mod -d .\sp-cflp-1.dat --cuts

################################################
# Capacitated Facility Location Problem - CFLP 
################################################
# Not Complete Recourse - May have several infeasibilities on second-stage
# producing undesirable first-stage solution. Alternavite: penalize
# non-satisfied demand.

set W; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

set I; # The set of all origin.
set J; # The set of all (possible) destination points.

param F{J}; # Setup cost for facility j in J                
param K{J}; # Unit Capacity of facility j in J                

# Demand at oring i in I and scenario w in W
param D{I,w in W}; #:= ceil(Normal(150,35)); 
var nd{I,W}, >=0; # R841 Non-Satisfied Demand from oring i in I and scenario w in W
param PC{I}; # Penalty cost for Non-Satisfied Demand from oring i in I 

display D;

# It may not be rewarding to satisfy all the demand; 
# the trade-off between revenues and costs will determine 
# the best service level for each customer.
param G{J}; # Unit cost of installing a facility in j in J
param R{I,W}; # Revenue from patient i in I
param C{I,J,W}; # Assessment cost for patient i at facility j

var z{J}, >=0; # R843 The varible capacity to be installed at location j.


# probability πω can be associated to scenario ω
# When probabilities can be associated with the scenarios, we can measure this
# relevance by using the expected value of perfect information (EVPI).
# The EVPI is the difference between the weighted sum of the optimal values for all
# scenarios (using the probabilities as weights) and the minimum expected cost.
param PI{W}; 
# param PI{W} := 1/card(W); 
check: sum{w in W}PI[w] >=0.999;
check: sum{w in W}PI[w] <= 1.001;

# The fraction of the demand of customer i in J, 
# to destj in J and scen w in W
var x{I,J,W} >= 0; 

# ex ante: decision location
# If a facility is located at j in J
var y{J}, binary; # s.t. R829

# =============================================================================
minimize FO839_42_44: 
# First-stage decisions
sum{j in J}F[j]*y[j] + sum{j in J}G[j]*z[j] + 
# Second-stage decisions
sum{w in W}PI[w]*(
sum{i in I}PC[i]*nd[i,w] +
sum{i in I, j in J}(C[i,j,w]-R[i,w])*D[i,w]*x[i,j,w]);

# Not every patient has a full demand met, for every scenario
s.t. R840{i in I, w in W}: sum{j in J}x[i,j,w] + nd[i,w]/D[i,w] = 1;

# Percentage of demand met
s.t. R845{i in I, w in W}: sum{j in J}x[i,j,w] <= 1;

# Priority on locating locally fisrt, for every scenario
s.t. R836{j in J, w in W}: sum{i in I}D[i,w]*x[i,j,w] <= K[j]*y[j];

s.t. R846{w in W, j in J}: sum{i in I}D[i,w]*x[i,j,w] <= z[j];

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
printf: "Expected COST = %.2f\n\n", FO839_42_44;

for{w in W}{
    printf: "Orig\tDem\tMet\t(\%)\tUnmet [%d]\n", w;
    printf{i in I}: "%d\t%d\t%d\t%d\t%d\n", 
    i,D[i,w], sum{j in J}x[i,j,w]*D[i,w], (sum{j in J}x[i,j,w])*100, nd[i,w];
    printf: "\n";
}
printf: "\n";

for{w in W}{
    printf: "Dest\tsetup\tUcost\tPRev\tCap\tUse [%d]\n", w;
    printf{j in J}: "%d\t%d\t%d\t%d\t%d\t%d\n", 
    j,F[j]*y[j], G[j]*z[j], sum{i in I}(R[i,w]-C[i,j,w])*D[i,w]*x[i,j,w], 
    K[j]*y[j], z[j];
    printf: "\n";
}
printf: "\n";
# =============================================================================


# # =============================================================================
# # For EVPI
# # =============================================================================
# # Selected Scenario: For computing 
# # EVPI: Expected Value of Perfect Information
# param SC, <= card(W), default 0; 
# # check: SC <= card(W);

# minimize FO839_42_44: 
# # First-stage decisions
# sum{j in J}F[j]*y[j] + sum{j in J}G[j]*z[j] + 
# # Second-stage decisions
# sum{w in W: w = SC}PI[w]*(
# sum{i in I}PC[i]*nd[i,w] +
# sum{i in I, j in J}(C[i,j,w]-R[i,w])*D[i,w]*x[i,j,w]);

# # Not every patient has a full demand met, for every scenario
# s.t. R840{i in I, w in W: w = SC}: sum{j in J}x[i,j,w] + nd[i,w]/D[i,w] = 1;

# # Percentage of demand met
# s.t. R845{i in I, w in W: w = SC}: sum{j in J}x[i,j,w] <= 1;

# # Priority on locating locally fisrt, for every scenario
# s.t. R836{j in J, w in W: w = SC}: sum{i in I}D[i,w]*x[i,j,w] <= K[j]*y[j];

# s.t. R846{w in W, j in J: w = SC}: sum{i in I}D[i,w]*x[i,j,w] <= z[j];

# solve;

# printf: "VPI [%s]:= %.2f\n", SC, FO839_42_44 >> "EVPI.txt";
# # # # =============================================================================
# VPI [1]:= 13244.19
# VPI [2]:= 8316.99
# VPI [3]:= -41395.25
# EVPI: -6611.36 (sum{1..3}VPI/3)

# Stochastic Programming Solution: SPS:= 
# VSS:= EVPI - SSP = 
# VSS:= -6611.36 - SSP = 
# # =============================================================================
 
end;

