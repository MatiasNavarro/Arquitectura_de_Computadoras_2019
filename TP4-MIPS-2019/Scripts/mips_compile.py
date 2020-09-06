import sys
import os
import getopt

def get_struct_instr(opcode):
    return {
        # R-Type Instructions
        "SLL":  [("code", 0x00000000), ("rd", 11), ("rt", 16), ("sa", 6)],
        "SRL":  [("code", 0x00000002), ("rd", 11), ("rt", 16), ("sa", 6)],
        "SRA":  [("code", 0x00000003), ("rd", 11), ("rt", 16), ("sa", 6)],
        "SLLV": [("code", 0x00000004), ("rd", 11), ("rt", 16), ("rs", 21)],
        "SRLV": [("code", 0x00000006), ("rd", 11), ("rt", 16), ("rs", 21)],
        "SRAV": [("code", 0x00000007), ("rd", 11), ("rt", 16), ("rs", 21)],
        "ADDU": [("code", 0x00000021), ("rd", 11), ("rs", 21), ("rt", 16)],
        "SUBU": [("code", 0x00000023), ("rd", 11), ("rs", 21), ("rt", 16)],
        "AND":  [("code", 0x00000024), ("rd", 11), ("rs", 21), ("rt", 16)],
        "OR":   [("code", 0x00000025), ("rd", 11), ("rs", 21), ("rt", 16)],
        "XOR":  [("code", 0x00000026), ("rd", 11), ("rs", 21), ("rt", 16)],
        "NOR":  [("code", 0x00000027), ("rd", 11), ("rs", 21), ("rt", 16)],
        "SLT":  [("code", 0x0000002A), ("rd", 11), ("rs", 21), ("rt", 16)],
        # I-Type Instructions
        "LB":   [("code", 0x80000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "LH":   [("code", 0x84000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "LW":   [("code", 0x8C000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "LWU":  [("code", 0x9C000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "LBU":  [("code", 0x90000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "LHU":  [("code", 0x94000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "SB":   [("code", 0xA0000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "SH":   [("code", 0xA4000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "SW":   [("code", 0xAC000000), ("rt", 16), ("offset", 0), ("base", 21)],
        "ADDI":  [("code", 0x20000000), ("rt", 16), ("rs", 21), ("immediate", 0)],
        "ANDI":  [("code", 0x30000000), ("rt", 16), ("rs", 21), ("immediate", 0)],
        "ORI":   [("code", 0x34000000), ("rt", 16), ("rs", 21), ("immediate", 0)],
        "XORI":  [("code", 0x38000000), ("rt", 16), ("rs", 21), ("immediate", 0)],
        "LUI":   [("code", 0x3C000000), ("rt", 16), ("immediate", 0)],
        "SLTI":  [("code", 0x28000000), ("rt", 16), ("rs", 21), ("immediate", 0)],
        "BEQ":   [("code", 0x10000000), ("rs", 21), ("rt", 16), ("offset", 0)],
        "BNE":   [("code", 0x14000000), ("rs", 21), ("rt", 16), ("offset", 0)],
        # J-Type Instructions
        "JR":    [("code", 0x00000008), ("rs", 21)],
        "JALR":  [("code", 0x00000009), ("rd", 11), ("rs", 21)],
        "J":     [("code", 0x08000000), ("instr_index", 0)],
        "JAL":   [("code", 0x0C000000), ("instr_index", 0)],
        # END instruction
        "HALT":   [("code", 0xFFFFFFFF)],
    }.get(opcode)

def get_hex_instr(op, struct_instr, flag):
    operando = []
    if(flag == 0):
        operando = str(op).split(",")
    else:
        aux_op = str(op).split(",")
        operando.append(aux_op[0])
        aux2_op = str(aux_op[1]).split("(")
        operando.append(aux2_op[0])
        aux3_op = str(aux2_op[1]).split(")")
        operando.append(aux3_op[0])

    hex_instr = int(struct_instr[0][1])  # Obtenemos el opcode
    for jj in range(0, len(operando)):
        if (int(struct_instr[jj+1][1]) == 0 and int(operando[jj]) < 0):
            hex_instr = hex_instr + 0xffff & int(operando[jj])
        else:
            hex_instr = hex_instr + \
                int((int(operando[jj]) << int(struct_instr[jj+1][1])))

    return hex(hex_instr)


def main(argv):
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(argv, 'i:o:h', ["ifile=", "ofile=", "help"])
    except getopt.GetoptError as err:
        print(err)
        print(os.path.basename(__file__) + " -i <inputfile> -o <outputfile>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print(os.path.basename(__file__) + " -i <inputfile> -o <outputfile>")
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            outputfile = arg
        else:
            print(os.path.basename(__file__) + " -i <inputfile> -o <outputfile>")
            sys.exit(2)
    
    if inputfile == '' or outputfile == '' or args != []:
        print('Error: Incorrect syntax')
        print(os.path.basename(__file__) + " -i <inputfile> -o <outputfile>")
        sys.exit()

    print('Input file: ', inputfile)
    print('Output file: ', outputfile)

    # Lectura de archivo.
    inputfile_contents = ""
    try:
        file_descriptor = open(inputfile, 'r')
        inputfile_contents = file_descriptor.read()
        file_descriptor.close()
    except:
        print('Error: File input handling')
        exit(1)

    # Parseo del archivo.
    inputfile_contents = [x for x in inputfile_contents.split('\n') if x != ''] # Cada linea en una posicion del arreglo
    hex_instructions = []
    for instruction in inputfile_contents:
        # Dividimos codigo de operacion y parametros
        aux_instr = instruction.split()
        str_instr = get_struct_instr(aux_instr[0].upper())

        if(str(str_instr).find("base") == -1):  # No hay parentesis (no es load ni store)
            if(aux_instr[0].upper() == "HALT"):
                hex_instructions.append(hex(str_instr[0][1]))
            else:
                hex_instructions.append(get_hex_instr(aux_instr[1], str_instr, 0))
        else:  # Si hay parentesis
            hex_instructions.append(get_hex_instr(aux_instr[1], str_instr, 1))

    try:
        file_descriptor = open(outputfile, "w")
        for instruction in hex_instructions:
            # Escribe al archivo en binario
            file_descriptor.write(bin(int(instruction.split("x")[1], 16))[2:].zfill(32))
            file_descriptor.write("\n")
        file_descriptor.close()
    except:
        print('Error: File output handling')
        exit(1)

    print('Programa MIPS compilado exitosamente')
    exit()

if __name__ == "__main__":
    main(sys.argv[1:])
