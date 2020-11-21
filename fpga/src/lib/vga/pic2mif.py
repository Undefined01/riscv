from PIL import Image

f = open("image2.mif", "w")
pos = 0
f.write("""
WIDTH=12;
DEPTH=327680;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT
BEGIN
""")


def write(byte):
    global pos
    if pos % 3 == 0:
        f.write("{:X}: ".format(pos // 3))
    f.write("{:X}".format(byte))
    if pos % 3 == 2:
        f.write(";\n")
    pos += 1


img = Image.open('image.jpg')
img = img.convert('RGB')
img = img.resize((640, 480))
size = img.size

for x in range(size[0]):
    for y in range(512):
        pixel = (0, 0, 0)
        if y < size[1]:
            pixel = img.getpixel((x, y))
        write(pixel[0] // 16)
        write(pixel[1] // 16)
        write(pixel[2] // 16)

f.write("END;")
f.close()
