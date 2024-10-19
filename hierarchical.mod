#############################################################################
# Operations Research for Health Care
# Lesson 4/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Primary care facilities (hospitals, clinics, off-site public access devices)
# Primary care is usually performed by a general practitioner and has great 
# potential for referral to specialty services, which are secondary, tertiary, 
# or quaternary care; or non-medical services. Primary care, which is also 
# referred to as primary medical care, differs from a broader concept of primary 
# health care that includes primary care services, health promotion and disease 
# prevention, and population-level public health functions. It should be mentioned 
# that hospitals and most clinics provide, beside primary care, specialty services, 
# which are secondary, or tertiary care. They can be classified into different levels, 
# therefore, they are hierarchical location problems.

# The model is a p-median single-flow hierarchical problem[1] for locating a set of PCFs 
# with two levels, in which the total travel distance (or time) for patients is minimized.
# ref: 
# [1] Ahmadi-Javid, A., Seyedi, P., & Syam, S. S. (2017). 
# A survey of healthcare facility location. Computers & Operations Research, 
# 79, 223-263.
#############################################################################
# glpsol -m hierarchical.mod

set I:= 1..10; # The set of demand points.
set K:= 1..5; # The set of candidate locations for a level-1 PCF (e.g., clinics).
set J:= 1..3; # The set of candidate locations for a level-2 PCF (e.g., hospitals).

# The travel distance (or time) between demand point i ∈ I and a level-1 PCF in 
# candidate location k ∈ K .
param d1{I,K}:= Uniform(30,100); 
# The travel distance (or time) between a level-1 PCF in candidate location k ∈ K 
# and a level-2 PCF in candidate location j ∈ J.
param d2{K,J}:= Uniform(30,100); 
# The population size at demand point i ∈ I (The demand point at i ∈ I).
param w{I}:= Normal(50,10); 
param p:=4; # The number of alevel-1 PCFs to be established.
param q:=2; # The number of alevel-2 PCFs to be established.
# Uniform(100,220); # The capacity of a level-1 PCF in candidate location k ∈ K.
param C1{K}:= (Normal(50,10)*1.2*card(I))/p;
# Uniform(1600,2000); # The capacity of a level-2 PCF in candidate location j ∈ J. 
param C2{J}:= (Normal(50,10)*1.2*card(K))/q;
display C1;
display C2;
# The proportion of patients in a level-1 PCF at candidate location k ∈ K referred 
# to a level-2 PCF.
param O{K}:= 0.7; 
check{k in K}: O[k] >=0;
check{k in K}: O[k] <=1; 

# 1, if a level-1 PCF is established at candidate location k ∈ K ; 0 otherwise.
var x1{k in K}, >=0, binary; 
# 1, if a level-2 PCF is established at candidate location j ∈ J ; 0 otherwise.
var x2{j in J}, >=0, binary; 
# The flow of patients between demand point i ∈ I and a level-1 PCF at candidate 
# location k ∈ K
var u{i in I, k in K}, >=0;  
# The flow of patients referred form a level-1 PCF at candidate location k ∈ K 
# to a level-2 PCF at candidate location j ∈ J.
var v{k in K, j in J}, >=0;  

# The objective (28) minimizes the total demand-weighted travel distance (or time).
minimize OF28: sum{i in I, k in K}d1[i,k]*u[i,k] + sum{k in K, j in J}d2[k,j]*v[k,j];

# Constraints (29) show that the entire population of patients at each demand 
# point must be assigned to level-1 PCFs
s.t. R29{i in I}: sum{k in K}u[i,k] = w[i];

#  Constraints (30) stipulate that θ[k] proportion of patients in a level-1 PCF 
# are referred to open level-2 PCFs.
s.t. R30{k in K}: sum{j in J}v[k,j] = O[k]*sum{i in I}u[i,k];

# Constraints (31) and (32) control the capacities of open level-1 and level-2 PCFs. 
s.t. R31{k in K}: sum{i in I}u[i,k] <= C1[k]*x1[k];
s.t. R32{j in J}: sum{k in K}v[k,j] <= C2[j]*x2[j];

# Constraints (33) and (34) specify the total number of level-1 and level-2 PCFs 
# to be established.
s.t. R33: sum{k in K}x1[k] = p;
s.t. R34: sum{j in J}x2[j] = q;


solve;

printf:"\n=============================================\n";
printf:"Total demand-weighted distance: %.2f\n", OF28; 
printf:"=============================================\n";
printf:"Selected Level-1 Locations: %d\n", sum{k in K}x1[k];
printf:"Selected Level-2 Locations: %d\n", sum{j in J}x2[j];
printf:"=============================================\n";
printf{k in K: x1[k]>0}:"Capacity L1 [%s]: %6.2f <-- Total Dem: %6.2f;\n", 
k, C1[k]*x1[k], sum{i in I}u[i,k]; 
printf:"=============================================\n";
printf{k in K, i in I: x1[k]>0 and u[i,k]>0}:"[%s] <-- [%s]:\t%d km\t(Dem: %.2f);\n", 
k, i, d1[i,k]*x1[k], u[i,k]; 
printf:"=============================================\n";
printf{j in J: x2[j]>0}:"Capacity L2 [%s]: %6.2f <-- Total Dem: %6.2f;\n", 
j, C2[j]*x2[j], sum{k in K}v[k,j]; 
printf:"=============================================\n";
printf{j in J,k in K: x2[j]>0 and v[k,j]>0}:"[%s] <-- [%s]:\t%d km\t(Dem: %.2f);\n", 
j, k, d2[k,j]*x2[j], v[k,j]; 
printf:"=============================================\n";
