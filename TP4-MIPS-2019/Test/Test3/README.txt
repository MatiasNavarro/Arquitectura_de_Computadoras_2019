// Load, store, addu y addi

//Cargo en R1 un 10
ADDI R1,R2,10
//Cargo en R2 un 5
ADDI R2,R2,5
//Cargo en posicion M0 de memoria un 10
SW R1,0{R3}
//Cargo en posicion M4 de memoria un 5
SW R2,4{R3}
//Cargo en registro R3 el valor=10 de la posicion M0 de memoria
LWU R3,0{R3}
//Cargo en registro R4 el valor=5 de la posicion M8 de memoria
LWU R4,4(R4)
// R4 + R1 = 15 (lo guardo en R5)
ADDU R5,R3,R1
//Cargo en posicion dos de memoria el valor de R5 (valor = 15)
SW R5,8{R7}
HALT
