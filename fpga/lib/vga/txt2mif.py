fin = open("vga_font.txt", "r")
fout = open("vga_font.mif", "w")

fout.write("""WIDTH=12;
DEPTH=327680;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT
BEGIN
""")

i = 0
for line in fin:
    fout.write('{:x}:\t{};\n'.format(i, line.strip()))
    i += 1

fout.write("END;\n")
