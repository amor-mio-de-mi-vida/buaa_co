import random

list_R = ["add", "sub", "and", "or", "sltu", "slt"]
list_I = ["andi", "addi", "ori", "lui"]
list_LS = ["lw", "sw", "lh", "sh", "lb", "sb"]
list_B = ["bne", "beq"]
list_MD = ["mult", "multu", "div", "divu"]
list_MTMF = ["mfhi", "mflo", "mthi", "mtlo"]

#length是生成的指令所用到的寄存器个数
length = 8 #为了增大冒险概率，我们将寄存器的范围缩小到0~7

def R_test(file, n):
    for i in range(n):
        k = random.randint(0, 10000000) % len(list_R)
        rs = random.randint(0, 10000000) % length;
        rt = random.randint(0, 10000000) % length;
        rd = random.randint(0, 10000000) % length;
        s = "{} ${}, ${}, ${}\n".format(list_R[k], rd, rs, rt)
        file.write(s)

def I_test(file, n):
    for i in range(n):
        k = random.randint(0, 10000000) % len(list_I)
        rs = random.randint(0, 10000000) % length
        rt = random.randint(0, 10000000) % length
        imm = random.randint(-32768, 32768)
        abs_imm = random.randint(0, 65536)
        if list_I[k] == "lui":
            s = "{} ${},{}\n".format(list_I[k], rt, abs_imm)
        else:
            s = "{} ${}, ${}, {}\n".format(list_I[k], rt, rs, imm)
        file.write(s)

def LS_test(file, n):
    for i in range(n):
        k = random.randint(0,10000000) % len(list_LS)
        ins = list_LS[k]
        num = 0
        if(ins[1] == "w"):
            num = (random.randint(0,10000000) << 2) % 4096
        elif(ins[1] == "h"):
            num = (random.randint(0,10000000) << 1) % 4096
        else:
            num = (random.randint(0,10000000)) % 4096
        
        rt = random.randint(0, 10000000) % length
        s = "{} ${}, {}($0)\n".format(ins, rt, num)
        file.write(s)


def MD_test(file, n):
    for i in range(n):
        k = random.randint(0,10000000) % len(list_MD)
        rs = random.randint(0, 10000000) % length
        rt = random.randint(0, 10000000) % length
        if(list_MD[k] == "mult" or list_MD[k] == "mul"):
            s = "{} ${}, ${}\n".format(list_MD[k], rs, rt)
        else:
            s = "{} ${}, ${}\n".format(list_MD[k], rs, 8)
        file.write(s)

def MTMF_test(file, n):
    for i in range(n):
        k = random.randint(0,10000000) % len(list_MTMF)
        rs = random.randint(0, 10000000) % length
        s = "{} ${}\n".format(list_MTMF[k], rs)
        file.write(s)

def B_test(file, lable):
    k = random.randint(0,10000000) % len(list_B)
    if(k == 0 or k == 1):
        rs = random.randint(0, 10000000) % length
        rt = random.randint(0, 10000000) % length
        s = "{} ${}, ${}, {}\n".format(list_B[k], rs, rt, lable)
        file.write(s)
    else:
        rs = random.randint(0, 10000000) % length
        s = "{} ${}, {}\n".format(list_B[k], rs, str(lable))
        file.write(s)


def b_begin(file, n):
    file.write("\nb_test_{}_one:\n".format(n))
    B_test(file, "b_test_{}_one_then".format(n))
    R_test(file,1)

    file.write("b_test_{}_two:\n".format(n))
    B_test(file, "b_test_{}_two_then".format(n))
    I_test(file,1)

    file.write("jal_test_{}:\n".format(n))
    file.write("jal jal_test_{}_then\n".format(n))
    I_test(file,1)

    file.write("end_{}:\n\n".format(n))

    R_test(file, 1)
    I_test(file, 1)
    LS_test(file, 1)

def b_end(file, n):
    file.write("\nb_test_{}_one_then:\n".format(n))
    R_test(file, 1)
    I_test(file, 1)
    LS_test(file, 1)
    MD_test(file, 1)
    MTMF_test(file, 1)
    file.write("j b_test_{}_two\n".format(n))
    R_test(file, 1)
    
    file.write("\nb_test_{}_two_then:\n".format(n))
    R_test(file, 1)
    I_test(file, 1)
    LS_test(file, 1)
    MD_test(file, 1)
    MTMF_test(file, 1)
    file.write("jal jal_test_{}\n".format(n))
    file.write("addu $1, $ra, $0\n")

    file.write("\njal_test_{}_then:\n".format(n))
    R_test(file, 1)
    I_test(file, 1)
    LS_test(file, 1)
    MD_test(file, 1)
    MTMF_test(file, 1)
    file.write("addiu $ra,$ra, 8\n".format(n))
    B_test(file, "end_{}".format(n))
    R_test(file, 1)
    I_test(file, 1)
    LS_test(file, 1)
    MD_test(file, 1)
    MTMF_test(file, 1)
    file.write("jr $ra\n".format(n))


with open("mips_code.asm", "w") as file:
    for i in range(length):
        temp = random.randint(-2147483648, 2147483648)
        s = "li ${} {}\n".format(i, temp)
        file.write(s)
    file.write("li $8, {}\n".format(random.randint(-2147483648, 2147483648) % 10000 + 1))
    
    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))
    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))
    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))

    for i in range(10):
        R_test(file, 2)
        MD_test(file,1)
        MTMF_test(file, 1)
        I_test(file, 2)
        LS_test(file, 2)
        MTMF_test(file, 1)
        I_test(file, 2)
        file.write("\n")

    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))
    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))
    # index = random.randint(0,10000000) % length
    # file.write("li  ${} 0\n".format(index))

    # for i in range(10):
    #     b_begin(file, i+1)
    # file.write("j   final\n")
    # for i in range(10):
    #     b_end(file, 1+i)
    # file.write("final:\nnop\n")
   