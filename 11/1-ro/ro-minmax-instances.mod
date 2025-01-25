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
# glpsol -m ro.mod 

################################################
# P-median for each w in W
################################################
set W:=1..10; # Finite set of scenarios w in Omega
# w is a particular scenario that fully specifies all the uncertain parameters.

set I:=1..100; # The set of all origin.
set J:=1..30; # The set of all (possible) destination points.

# Demand at oring i in I and scenario w in W
param D{I,w in W}:= ceil(Normal(150,35)); 

# Distance from i in J, to j in J and scenario w in W
param A{I,J,w in W}:= ceil(Uniform(50,300)); 

##############################################################
param instance,symbolic, default  "ro-minimax-3.dat";
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
printf: "param P:= 5;\n\n" >> instance;
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

# Parametro: 3 dimensoes (matriz)
printf: "\nparam A" >> instance;
for{w in W}{
    printf: "\n[*,*,%d]: ",w >> instance;
    printf{j in 1..card(J)-1}: "%d\t", j   >> instance;
    printf{j in J: j = card(J)}: "%d:=\n", j   >> instance;
    for{i in I}{
        printf: "%d\t", i  >> instance;
        for{j in J}{
            printf: "%d\t", A[i,j,w]   >> instance;     
        }
        printf"\n"    >> instance;
    }
}
printf: ";\n\n" >> instance;

# Parametro: 1 dimensao (vetor)
printf: "# param Vopt:=\n" >> instance;
printf{w in W}: "# %d\t\n", w >> instance;


printf";\n\nend;\n\n"  >> instance;

end;
##################################################

