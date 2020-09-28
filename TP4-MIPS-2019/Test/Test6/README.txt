// Prueba general de instrucciones tipo R

//Cargo en R1 un 10
ADDI R1,R1,10
//Cargo en R2 un 8
ADDI R2,R2,8
//Cargo en R3 un 5
ADDI R3,R3,5
//Cargo en R4 un 2
ADDI R4,R4,2
//Cargo en R5 un 0
ADDI R5,R5,D
//Cargo en R6 el resultado de R1 & R2 = 10 & 8 = 8
AND R6,R1,R2
//Cargo en R7 el resultado de R1 | R2 = 10 | 8 = 10
OR R7,R1,R2
//Cargo en R8 el resultado de R1 ^ R2 = 10 ^ 8 = 2
XOR R8,R1,R2
//Cargo en R9 el resultado de R1 ~| R2 = 10 ~| 8 = -11
NOR R9,R1,R2
//Cargo en R10 el resultado de R1 & 2 = 10 & 2 = 2
ANDI R10,R1,2
//Cargo en R11 el resultado de R1 ^ 2 = 10 ^ 2 = 8
XORI R11,R1,2
//Cargo en R12 el resultado de R1 - R2 = 10 - 8 = 2
SUBU R12,R1,R2
//Cargo en R13 el resultado de R2 - R1 = 8 - 10 = -2
SUBU R13,R2,R1
//Cargo en R14 el resultado de R2 < R1 = 8 < 10 = 1
SLT R14,R2,R1
//Cargo en R15 el resultado de R1 < R2 = 10 < 8 = 0
SLT R15,R1,R2
//Cargo en R16 el resultado de R1 < R13 = 10 < -2 = 0
SLT R16,R1,R13
//Cargo en R17 el resultado de R2 < 10 = 8 < 10 = 1
SLTI R17,R2,10
//Cargo en R18 el resultado de R1 < 8 = 10 < 8 = 0
SLTI R18,R1,8
//Cargo en R19 el resultado de R1 < -11 = 10 < -11 = 0
SLTI R19,R1,-11
//Cargo en R20 el resultado de R1 >> 3 = 10 >> 3 = 1
SRL R20,R1,3
//Cargo en R21 el resultado de R1 << 2 = 10 << 2 = h28
SLL R21,R1,2
//Cargo en R22 el resultado de R1 >> R4 = 10 >> 2 = 2
SRLV R22,R1,R4
//Cargo en R23 el resultado de R1 << R4 = 10 << 2 = h28
SLLV R23,R1,R4
//Cargo en R24 el resultado de R9 >> 3 = -11 >> 3 = h7ffffffa
SRL R24,R9,3
//Cargo en R25 el resultado de R9 >>> 1 = -11 >>> 1 = hfffffffa = -6
SRA R25,R9,1
//Cargo en R26 el resultado de R13 >>> R4 = -2 >>> 2 = hffffffff = -1
SRAV R26,R13,R4
//Almaceno datos en memoria
SW R1,0{R0}
SW R2,4{R0}
SW R3,8{R0}
SW R4,12{R0}
SW R5,16{R0}
SW R6,20{R0}
SW R7,24{R0}
SW R8,28{R0}
SW R9,32{R0}
SW R10,36{R0}
SW R11,40{R0}
SW R12,44{R0}
SW R13,48{R0}
SW R14,52{R0}
SW R15,56{R0}
SW R16,60{R0}
SW R17,64{R0}
SW R18,68{R0}
SW R19,72{R0}
SW R20,76{R0}
SW R21,80{R0}
SW R22,84{R0}
SW R23,88{R0}
SW R24,92{R0}
SW R25,96{R0}
SW R26,97{R0}
HLT
