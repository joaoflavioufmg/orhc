@echo off

rem if exist previous output file, just kill it
del tmp.dat
del EVPI.txt
rem a loop with k% going from 1 to 10, with step 1
rem The echo statement is used to displayed information to the screen.

for /l %%k in (1,1,3) do (

	rem just chit-chating:
	echo .
	echo ------------------------   Solving SC: %%k...   ------------------------
	echo .

	rem creating a temporary dat file with HFunc parameter
	echo data; param SC:=%%k; end; > tmp.dat	

	rem now running glpk!
	glpsol -m .\sp-cflp.mod -d .\sp-cflp-1.dat --cuts -d tmp.dat
)

rem remove temporary files and variables
del tmp.dat