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
# Alpha Robustness
#############################################################################
# > glpsol -m .\ro-alpha-robustness.mod -d .\ro-minmax-1.dat --cuts

# ################################################
# # P-median for each w in W (run Vopt_W.bat)
# ################################################
# set W; # Finite set of scenarios w in Omega
# # w is a particular scenario that fully specifies all the uncertain parameters.

# set I; # The set of all origin.
# set J; # The set of all (possible) destination points.

# param SC default 0; # Selected Scenario
# check: SC <= card(W);

# # Demand at oring i in I and scenario w in W
# # param D{I,w in W}:= ceil(Normal(50,15)); 
# param D{I,w in W}; 

# # param A{I,J,w in W}:= ceil(Uniform(100,200)); # Distance from i in J, to j in J and scenario w in W
# param A{I,J,w in W};

# param P; # New facilities to be located

#  # Optimal solution of P-median FO81-R84 for each w
# param Vopt{W} default 0;

# # If origin i in J, is allocated to destj in J and scen w in W
# var x{I,J,w in W}, binary; 

# # ex ante: decision location
# var y{J}, binary; 

# var v; # 

# # Minimax objective is a combination of FO86 and R87
# minimize FO86: v;

# s.t. R87{w in W: w = SC}: sum{i in I, j in J}D[i,w]*A[i,j,w]*x[i,j,w] <= v;

# # Each origin has a single destination
# s.t. R88{i in I, w in W: w = SC}: sum{j in J}x[i,j,w] = 1;

# # Priority on locating locally fisrt
# s.t. R89{i in I, j in J,w in W: w = SC}: x[i,j,w] <= y[j];

# s.t. R810: sum{j in J} y[j] = P;

# solve;

# # printf: "\n\nDecision: Locate ";
# # printf{j in J: y[j] > 0}: "[%d] ",j;
# # printf"\n\n";
# # for{w in W: w = SC}{
# #     # printf"\n\nCenario [%d]:\n\n", w;
# #     # printf{j in J: y[j] > 0}: "y[%d]: %d\n",j,  y[j];
# #     # printf"\n";
# #     printf"Destino\tOrigem\n";
# #     for{j in J, i in I: x[i,j,w] > 0}{
# #         printf"[%d]:\t%d\n",j,i;
# #     }
# # }

# # The optimal cost that can be achieved under scenario w
# printf{w in W: w = SC}: "\nVopt[%d] = %.2f\n\n", w, FO86;

# end;
# ##################################################


################################################
# The Alpha Robustness P-median
################################################
# > glpsol -m .\ro-alpha-robustness.mod -d .\ro-minmax-1.dat --cuts

set W; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

set I; # The set of all origin.
set J; # The set of all (possible) destination points.

param D{I,W}; # Demand at oring i in I and scenario w in W
param A{I,J,W}; # Distance from i in J, to j in J and scenario w in W
param P; # New facilities to be located

# probability πω can be associated to scenario ω
# When probabilities can be associated with the scenarios, we can measure this
# relevance by using the expected value of perfect information (EVPI).
# The EVPI is the difference between the weighted sum of the optimal values for all
# scenarios (using the probabilities as weights) and the minimum expected cost.
param PI{W}:= Uniform01(); 
check{w in W}PI[w] >=0;
check{w in W}PI[w] <= 1;

# “ALPHA-robustness”: The idea is to look for a solution minimizing the expected 
# cost, such that the relative regret in each scenario is <= to a parameter ALPHA.
# The purpose is similar to the use of ellipsoid uncertainty: the exclusion of
# low-probability (typically extreme) scenarios.
param ALPHA := 0.2;

param Vopt{W}; # Optimal solution of P-median FO81-R84 for each w

# If origin i in J, is allocated to destj in J and scen w in W
var x{I,J,W}, binary; 

# ex ante: decision location
var y{J}, binary; 

# var v; # 

# Minimax objective is a combination of FO86 and R87
minimize FO825: sum{w in W, i in I, j in J}PI[w]*D[i,w]*A[i,j,w]*x[i,j,w];

s.t. R813{w in W}: sum{i in I, j in J}D[i,w]*A[i,j,w]*x[i,j,w] <= (1+ALPHA)*Vopt[w];

# # If "FO86" differs significantly across scenarios, 
# # the relative regret is a more appropriate robustness measure 
# # (see Kouvelis and Yu 1997).
# s.t. R814{w in W}: (sum{i in I, j in J}D[i,w]*A[i,j,w]*x[i,j,w] - Vopt[w])/Vopt[w] <= v;

# Allocation: Each origin has a single destination
# Obs: This allocation can vary from scenario to scenario
s.t. R88{i in I, w in W}: sum{j in J}x[i,j,w] = 1;

# Facility location: 
# Obs: Such decision (the same j) is applied 
# to ANY (or ALL) scenario w
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
printf: "ALPHA Regret = %.2f\n\n", FO825;

end;
#################################################
