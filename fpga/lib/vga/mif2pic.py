from PIL import Image
import re

f = open("image.mif", "r")
s = f.read()

res = re.findall('\w+: (\w+)', s)
h = int(res[0])
w = int(res[1])
res = res[2:]

print(len(res))

img = Image.new('RGB', (640, 512))
for x in range(640):
    for y in range(512):
        R = int(res[x*512+y][0], 16)
        G = int(res[x*512+y][1], 16)
        B = int(res[x*512+y][2], 16)
        img.putpixel((x, y), (R*17, G*17, B*17))

img.show()