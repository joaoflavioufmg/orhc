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
# Uncertainty sets Box Instances (creation)
#############################################################################
# > glpsol -m .\ro-box.mod -d .\ro-box.dat --seed ?

################################################
# Uncapacitated Facility Location Problem - UFLP 
################################################
set I:= 1..100; # The set of all origin.
set J:= 1..10; # The set of all (possible) destination points.

# Demand at oring i in I
param Dbar{I}:= ceil(Normal(150,35)); 

# "Epsilon": Uncertainty magnitude
param E:= Uniform01(); 

# Setup cost for facility j in J  
param F{J}:= ceil(Uniform(50,150));

# Unit cost for meeting demand (not full demand) from i to j
param C{I,J}:= ceil(Uniform(1,13)); 

##############################################################
param instance,symbolic, default  "ro-box-ellipsoid-1.dat";
# Conjuntos
printf: "\nset I:= " > instance;
printf{i in I}:"%d\t", i >> instance;
printf: ";\n\n"  >> instance;
printf: "set J:= " >> instance;
printf{j in J}:"%d\t", j >> instance;
printf: ";\n\n" >> instance; 

# Parametro: 1 valor
printf: "param E:= %.2f;\n\n", E >> instance;

# Parametro: 1 dimensao (vetor)
printf: "param Dbar:=\n" >> instance;
printf{i in I}: "%d\t%d\n", i, Dbar[i] >> instance;
printf: ";\n\n" >> instance;

printf: "param F:=\n" >> instance;
printf{j in J}: "%d\t%d\n", j, F[j] >> instance;
printf: ";\n\n" >> instance;

# Parametro: 2 dimensoes (matriz)
printf: "\nparam C: " >> instance;
printf{j in 1..card(J)-1}: "%d\t", j >> instance;
printf{j in J: j = card(J)}: "%d:=\n", j >> instance;
for{i in I}{
    printf: "%d\t", i >> instance;
    for{j in J}{
        printf: "%d\t", C[i,j] >> instance;       
    }
    printf"\n" >> instance;   
}
printf";\n\nend;\n\n"  >> instance;


end;
##############################################################

