Prueba general de instrucciones de salto.

//Cargo en R0 un 10
ADDI R0,R0,10
//Cargo en R1 un 2
ADDI R1,R1,2
//Cargo en R2 un 1
ADDI R2,R2,1
//Cargo en R3 un 21
ADDI R3,R3,21
//Decremento contador
SUBU R1,R1,R2
//Salta 2 instrucciones si R1=R5
BEQ R1,R5,2
//Salta -2 instrucciones (salta hacia atras) si R1!=R5
BNE R1,R5,-3
XOR R1,R1,R0
//Salta a la direccion del valor R0 (Valor = 10)
JR R0
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
//Salta a la direccion del valor R3 (Valor = 21) y guarda en R6 el valor del PC+1
JALR R6,R3
//Salta a la direccion 27 y guarda en rd[31] = PC+2
JAL 4
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1

AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
AND R1,R1,R1
//Salta a la direccion del valor R6 y guarda en R4 el valor del PC+1
JALR R4,R6
AND R1,R1,R1
HALT

