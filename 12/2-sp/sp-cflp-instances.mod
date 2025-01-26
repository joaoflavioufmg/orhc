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
# Minimax Instances (creation)
#############################################################################
# > glpsol -m .\sp-cflp-instances.mod

################################################
# Capacitated Facility Location Problem - CFLP 
################################################
param instance,symbolic, default  "sp-cflp-1.dat";

set I:=1..10; # The set of all origin.
set J:=1..5; # The set of all (possible) destination points.
set W:=1..3; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

# param PI{w in W}:= 1/card(W);
param P{W}:= Uniform(1,(100/card(W)))/100;
param PI{w in W}:= if w in 1..card(W)-1 then P[w] else 
1-sum{i in 1..card(W)-1}P[i];

check: sum{w in W}PI[w] >=0.999;
check: sum{w in W}PI[w] <= 1.001;


# Setup cost for facility j in J  
param F{J}:= ceil(Uniform(50,150));

# Unit cost of installing a facility in j in J
param G{J}:= ceil(Uniform(5,25));

# Unit Capacity of facility j in J
param K{J}:= ceil(Uniform(50,1000));

# Demand at oring i in I and scenario w in W
param D{I,w in W}:= ceil(Normal(150,35)); 

# Revenue from patient i in I
param R{I,W}:= ceil(Normal(50,10)); 

# Penalty cost for Non-Satisfied Demand from oring i in I 
param PC{I}:= ceil(Uniform(100,800));

# Distance from i in J, to j in J and scenario w in W
param C{I,J,w in W}:= ceil(Uniform(1,30)); 

##############################################################
# Conjuntos
printf: "\nset I:= " > instance;
printf{i in I}:"%d\t", i >> instance;
printf: ";\n\n"  >> instance;
printf: "set J:= " >> instance;
printf{j in J}:"%d\t", j >> instance;
printf: ";\n\n" >> instance; 
printf: "set W:= " >> instance;
printf{w in W}:"%d\t", w >> instance;
printf: ";\n\n" >> instance;

# Parametro: 1 valor
# Parametro: 1 dimensao (vetor)
printf: "param PI:=\n" >> instance;
printf{w in W}: "%d\t%f\n", w, PI[w] >> instance;
printf: ";\n\n" >> instance;

printf: "param F:=\n" >> instance;
printf{j in J}: "%d\t%d\n", j, F[j] >> instance;
printf: ";\n\n" >> instance;

printf: "param G:=\n" >> instance;
printf{j in J}: "%d\t%d\n", j, G[j] >> instance;
printf: ";\n\n" >> instance;

printf: "param K:=\n" >> instance;
printf{j in J}: "%d\t%d\n", j, K[j] >> instance;
printf: ";\n\n" >> instance;

printf: "param PC:=\n" >> instance;
printf{i in I}: "%d\t%d\n", i, PC[i] >> instance;
printf: ";\n\n" >> instance;

# Parametro: 2 dimensoes (matriz)
printf: "\nparam D: " >> instance;
printf{w in 1..card(W)-1}: "%d\t", w >> instance;
printf{w in W: w = card(W)}: "%d:=\n", w >> instance;
for{i in I}{
    printf: "%d\t", i >> instance;
    for{w in W}{
        printf: "%d\t", D[i,w] >> instance;       
    }
    printf"\n" >> instance;   
}
printf";\n\n" >> instance; 


printf: "\nparam R: " >> instance;
printf{w in 1..card(W)-1}: "%d\t", w >> instance;
printf{w in W: w = card(W)}: "%d:=\n", w >> instance;
for{i in I}{
    printf: "%d\t", i >> instance;
    for{w in W}{
        printf: "%d\t", R[i,w] >> instance;       
    }
    printf"\n" >> instance;   
}
printf";\n\n" >> instance; 

# Parametro: 3 dimensoes (matriz)
printf: "\nparam C" >> instance;
for{w in W}{
    printf: "\n[*,*,%d]: ",w >> instance;
    printf{j in 1..card(J)-1}: "%d\t", j   >> instance;
    printf{j in J: j = card(J)}: "%d:=\n", j   >> instance;
    for{i in I}{
        printf: "%d\t", i  >> instance;
        for{j in J}{
            printf: "%d\t", C[i,j,w]   >> instance;     
        }
        printf"\n"    >> instance;
    }
}
printf";\n\nend;\n\n"  >> instance;

end;
##################################################

