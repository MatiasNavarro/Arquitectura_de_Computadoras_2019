ADDI    1,2,10
ADDI    2,2,5
SW      1,0(3)
SW      2,4(3)
LWU     3,0(3)
LWU     4,4(4)
ADDU    5,3,4
SW      5,8(7)
HALT
