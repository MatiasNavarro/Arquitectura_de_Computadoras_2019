// Prueba de forwarding.

//Cargo en R1 un 10
ADDI R1,R2,10
//Cargo en R2 un 15 (forward en mem)
ADDI R2,R1,5
//Cargo en R3 un 15 (forward en wb)
ADDI R3,R1,5
HLT
