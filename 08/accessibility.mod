#############################################################################
# Operations Research for Health Care
# Lesson 8/15
# Author: João Flávio de Freitas Almeida <joao.flavio@dep.ufmg.br>
# LEPOINT: Laboratório de Estudos em Planejamento de Operações Integradas
# Departmento de Engenharia de Produção
# Universidade Federal de Minas Gerais - Escola de Engenharia
#############################################################################
# Spatial Accessibility on health care [1].
# 
# ref: [1] Guagliardo, M. F. (2004). Spatial accessibility of primary care: 
# concepts, methods and challenges. International journal of health 
# geographics, 3, 1-13.
#############################################################################
# glpsol -m accessibility.mod -d access.dat

set I; # Origin (demand) point, from where Accessibility is measured
set J; # Destination (offer) location
set K; # Origin, points k that currently demand service at destination j

# Distance decay, travel friction coefficient. Require empirical investigation
param Beta;

# Travel impedance, e.g. distance or travel time, between points i and j.
param Di{I,J}, >= 0;

# Travel impedance, e.g. distance or travel time, between points i and j.
param Dibeta{i in I, j in J}:= Di[i,j]^(Beta);

# Service capacity at provider (destination) location j.
param S{J};

# Spatial accessibility from (origin) population point i (demand area).
param A{i in I}:= sum{j in J}S[j]/Dibeta[i,j];

############## Improvement ##########
# Population size at (demand, origin) point k
param P{K};

# Travel distance or travel time, between population (demand, origin) 
# point k and (destination) j.
param Dk{K,J};

# Travel distance or travel time, between population (demand, origin) 
# point k and (destination) j.
param Dkbeta{k in K, j in J}:= Dk[k,j]^(Beta);	

# Demand on provider (destination) location j
param V{j in J}:= sum{k in K}P[k]/Dkbeta[k,j];

# Improved gravity model for Accessibility of population i
param Ai{i in I}:= sum{j in J}S[j]/(Dibeta[i,j]*V[j]);	

solve;

printf "\n========= Accessibility Report ========\n";
printf "Beta: %.2f\n", Beta;
printf "=======================================\n";
printf "Dest\tSupply\tDemand\n";
for{j in J}{
printf "[%d]\t%4d\t%4d\n", j, S[j], V[j];
}
printf "=======================================\n";
printf "Orig\tAccessibility\n";
for{i in I}{
printf "[%d]\t%.2f\n", i, Ai[i];
}
printf "=======================================\n\n";


data;

# Origin (demand) point, from where Accessibility is measured
set I:= 1   2   3   4   5;

# Destination (offer) location
set J:= 1   2   3; 

# Origin, points k that currently demand service at destination j
set K:= 1   2   3   4   5   6   7; 

# Distance decay, travel friction coefficient. Require empirical investigation
param Beta:= 0.8;

# Travel impedance, e.g. distance or travel time, between points i and j.
param Di
:	1	2	3	:=
1	183	85	159	
2	81	66	82	
3	89	177	35	
4	148	55	46	
5	77	37	99	
;

# Service capacity at provider (destination) location j.
param S:=
1	68
2	61
3	88
;	

############## Improvement ##########
# Population size at (demand, origin) point k
param P:=
1	424
2	119
3	457
4	473
5	439
6	291
7	271
;

# Travel distance or travel time, between population (demand, origin) 
# point k and (destination) j.
param Dk
:	1	2	3	:=
1	46	31	54	
2	57	87	44	
3	60	69	80	
4	80	56	98	
5	46	65	41	
6	51	63	45	
7	33	46	55	
;				

end;






