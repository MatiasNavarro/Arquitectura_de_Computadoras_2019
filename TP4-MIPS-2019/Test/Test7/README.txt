Prueba general de instrucciones tipo Load y Store.

//Cargo en R1 un 10
ADDI R1,R1,10
//Cargo en R2 un 20024
ADDI R2,R2,20024
//Cargo en R3 un 43981
ADDI R3,R3,43981
//Cargo en R4 un -1
ADDI R4,R4,-1
//Cargo en posicion M0 de memoria un 10
SW R1,0{R0}
//Cargo en posicion M12 de memoria un -1
SW R4,12{R0}
//Cargo en posicion M6 de memoria un 20024
SH R2,6{R0}
//Cargo en posicion M16 de memoria un -1
SH R4,16{R0}
//Cargo en posicion M8 de memoria un 43981
SB R3,8{R0}
//Cargo en posicion M9 de memoria un 10
SB R1,9{R0}
//Cargo en registro R5 el valor de la posicion M8 de memoria (Valor = 43981)
LW R5,8{R0}
//Cargo en registro R6 el valor de la posicion M12 de memoria (Valor = -1)
LWU R6,12{R0}
//Cargo en registro R7 16 bits signed de la posicion M12 de memoria (Valor = -1)
LH R7,12{R0}
//Cargo en registro R8 16 bits unsigned de la posicion M14 de memoria (Valor = 0)
LHU R8,14{R0}
//Cargo en registro R9 8 bits signed de la posicion M0 de memoria (Valor = 10)
LB R9,0{R0}
//Cargo en registro R10 8 bits signed de la posicion M9 de memoria (Valor = 10)
LB R10,9{R0}
//Cargo en registro R11 8 bits signed de la posicion M17 de memoria (Valor = 0)
LB R11,17{R0}
//Cargo en registro R12 8 bits unsigned de la posicion M17 de memoria (Valor = 0)
LBU R12,17{R0}
//Cargo en registro R13 el valor 255 desplazado 16 bits a la izquierda
LUI R13,255
HALT
