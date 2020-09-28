//Prueba de control de riesgos frente a load e instrucción de tipo R (ori)

//Cargo en R1 un 10
ADDI R1,R1,10
//Cargo en posicion M0 de memoria el contenido de R1 (10)
SW R1,0{R0}
//Cargo en R3 el contenido de la posicion M0 de memoria (10)
LWU R3,0{R0}
//Cargo en R4 el resultado de (R3 | 8) = (10 | 8)
ORI R4,R3,8
HLT
