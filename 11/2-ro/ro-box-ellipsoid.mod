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
# Box Uncertainty Sets
#############################################################################
# > glpsol -m .\ro-box.mod -d .\ro-box.dat --seed ?

# #################################################
# # Uncapacitated Facility Location Problem - UFLP 
# #################################################
# set I; # The set of all origin.
# set J; # The set of all (possible) destination points.

# param Dbar{I}; # Demand at oring i in I
# param F{J}; # Setup cost for facility j in J                
# param C{I,J}; # Unit cost for meeting demand (not full demand) from i to j

# # Continuous variable: The FRACTION of demand of i supplied from facility j
# var x{I,J}, >=0; 

# var y{J}, binary; # If a facility is located at j in J


# minimize FO815: sum{j in J}F[j]*y[j] + sum{i in I, j in J}C[i,j]*Dbar[i]*x[i,j];

# # Each origin has a single destination
# s.t. R816{i in I}: sum{j in J}x[i,j] = 1;

# # Priority on locating locally fisrt
# s.t. R817{i in I, j in J}: x[i,j] <= y[j];

# solve;
# #################################################


##########################################################
# Robust: Uncapacitated Facility Location Problem - UFLP 
# > glpsol -m .\ro-box.mod -d .\ro-box.dat --seed ?
##########################################################
set I; # The set of all origin.
set J; # The set of all (possible) destination points.

param Dbar{I}; # Demand at oring i in I

param E; #:= 0.5; # "Epsilon": Uncertainty magnitude
param Mu{i in I}:= Dbar[i];
param Sigma{i in I}:= (Dbar[i]/10);
# Nominal value of the unknown parameter
param Dmin{i in I}:= max(0,round(Dbar[i]*(1-E)));
param Dmax{i in I}:= round(Dbar[i]*(1+E));

# The vector of Demand(s)
# =====================================================
# param D{i in I}:= round(Uniform(Dmin[i],Dmax[i])); 
# =====================================================
# or ...
# =====================================================
param DS{i in I}:= round(Normal(Mu[i],Sigma[i]));
param D{i in I}:= if DS[i] <= Dmin[i] then Dmin[i]+1 else
                  if DS[i] >= Dmax[i] then Dmax[i]-1 else DS[i]; 
# =====================================================

# display E;
# display DS;
# display D;
# display{i in I}: abs((D[i]-Dbar[i])/(E*Dbar[i]));
# check{i in I}: abs((D[i]-Dbar[i])/(E*Dbar[i])) <= 1;
#===============================
# Uncertainty set (Box)
set UB:= setof{i in I: abs((D[i]-Dbar[i])/(E*Dbar[i])) <= 1} D[i];
#===============================


#===============================
# Uncertainty set (Ellipsoidal)
# L = 1 : Largest ellipsiod within (subset) UE
# L = sqrt(card(I)) : Smallest ellipsiod containg (superset) UE
param L:= max(1, round(Uniform(1,sqrt(card(I))))); # Ellipsiod size

# Diagonal matrix
# param SIGMA{i in I,j in I} := if (i=j) then 1/(E*Dbar[i]) else 0;
# set UE:= setof{k in I: sum{i in I, j in J}(D[i]-Dbar[i])*SIGMA[i,j]*(D[i]-Dbar[i]) <= L^2} D[k];
# display{i in I}: ((D[i]-Dbar[i])/(E*Dbar[i]))^2;
check{i in I}: ((D[i]-Dbar[i])/(E*Dbar[i]))^2 <= L^2;
set UE:= setof{i in I: (abs((D[i]-Dbar[i])/(E*Dbar[i])))^2 <= L^2} D[i];
#===============================
# display L;
# display L^2;
# display{i in I}: (abs((D[i]-Dbar[i])/(E*Dbar[i])))^2;
# display D;
# display UB;
# check{i in I: D[i] in UB}: D[i] in UB;
# display D;
# display UE;
# check{i in I: D[i] in UE}: D[i] in UE;


param F{J}; # Setup cost for facility j in J                
param C{I,J}; # Unit cost for meeting demand (not full demand) from i to j

# Continuous variable: The FRACTION of demand of i supplied from facility j
var x{I,J}, >=0; 

var y{J}, binary; # If a facility is located at j in J

var v;

minimize FO820: v; 

# Uncertainty set (Box)
# =====================================================
# s.t. R823: sum{j in J}F[j]*y[j] + sum{i in I, j in J: D[i] in UB}C[i,j]*(D[i]*(1+E))*x[i,j] <= v;
# =====================================================
# or ... Uncertainty set (Ellipsoidal)
# =====================================================
s.t. R823: sum{j in J}F[j]*y[j] + sum{i in I, j in J: D[i] in UE}C[i,j]*(D[i]*(1+E))*x[i,j] <= v;
# =====================================================

# Each origin has a single destination
s.t. R816{i in I}: sum{j in J}x[i,j] = 1;

# Priority on locating locally fisrt
s.t. R817{i in I, j in J}: x[i,j] <= y[j];

solve;

printf:"\n\nOrigin\tDmin\tDbar\tDmax\tD\n";
printf{i in I}:"%d\t%.2f\t%d\t%.2f\t%.2f\n",
i,Dmin[i],Dbar[i],Dmax[i],D[i];
printf:"\n\n";


printf: "\n\nDecision: Locate ";
printf{j in J: y[j] > 0}: "[%d] ",j;
printf"\n\n";
printf"Dest  Ori\n";
for{j in J, i in I: x[i,j] > 0}{
    printf"[%d] <- %d\n",j,i;
}
printf"\n";
printf: "Total Cost = %.2f\n\n", FO820;


end;
##########################################################
