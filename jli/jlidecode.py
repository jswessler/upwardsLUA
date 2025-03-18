import os, copy, sys
from PIL import Image

def ind(rgb):
    return (rgb[0]*5+rgb[1]*7+rgb[2]*11)%31

def getInd(indx, rgb):
    indx.pop(ind(rgb[0:3]))
    indx.insert(ind(rgb[0:3]),rgb[0:3])

def qolDecode(filepath):
    im = open(filepath,'rb')
    bites = im.read()

    bitR = []
    width = 10
    height = 10
    byteCounter = 0
    totalPix = 1000

    cPix = (0,0,0)
    index2 = [(0,0,0)] * 64
    cmdRem = [(-1,-1)] * 31

    while True:
        byte = bites[byteCounter]
        by = hex(byte)
        if byteCounter == 0 and by != '0x51': #Q
            raise Exception
        if byteCounter == 1 and by != '0x4f': #O
            raise Exception
        if byteCounter == 2 and by != '0x4c': #L
            raise Exception
        if byteCounter == 3 and by != '0x66': #f
            raise Exception
        if byteCounter == 4:
            width += byte*65536
        if byteCounter == 5:
            width += byte*256
        if byteCounter == 6:
            width += byte
        if byteCounter == 7:
            height += byte*65536
        if byteCounter == 8:
            height += byte*256
        if byteCounter == 9:
            height += byte
            width -= 10
            height -= 10
            totalPix = width*height
        if byteCounter == 10 and by != '0x0':
            raise Exception
        if byteCounter == 11:
            cPix = (bites[byteCounter],bites[byteCounter+1],bites[byteCounter+2])
            bitR.append(cPix)
            break
        byteCounter += 1


    run = 0
    byteCounter = 13
    for pixel in range(-1,totalPix+1):
        bitR.append(cPix)

    #Debug

        #actual decoder
        if run > 0:
            run -= 1
            continue

        #read a byte
        byteCounter += 1
        try:
            byte = bites[byteCounter]
        except:
            continue

        #Long Code
        if byte < 64:
            if byte >= 32: #Hi Mode
                if byte >= 48:
                    mult = (2 * ((byte-32)>>1)) - 8
                else:
                    mult = (2 * ((byte-32)>>1)) - 24
            else: #Lo Mode
                mult = (byte >> 1) - 8
            
            dr = (byte%2)*4
            byteCounter += 1
            byte = bites[byteCounter]
            dr += byte >> 6
            dr -= 1
            dg = ((byte >> 3)%8)-1
            db = (byte%8)-1
            cPix = (max(0,min(255,cPix[0]+(mult*dr))),max(0,min(255,cPix[1]+(mult*dg))),max(0,min(255,cPix[2]+(mult*db))))
            getInd(index2,cPix)
            cmdRem.insert(0,(bites[byteCounter-1],bites[byteCounter]))
            cmdRem.pop(-1)
            continue

        #Index
        if byte < 96:
            cPix = copy.copy(index2[byte-64])
            if cPix == '':
                cPix = (255,255,0)
            continue

        #CMD remember 96-127 (31 options)
        if byte < 127:
            b1 = cmdRem[byte-96][0]
            b2 = cmdRem[byte-96][1]
            if b1 >= 32: #Hi Mode
                if b1 >= 48:
                    mult = (2 * ((b1-32)>>1)) - 8
                else:
                    mult = (2 * ((b1-32)>>1)) - 24
            else: #Lo Mode
                mult = (b1 >> 1) - 8
            
            dr = (b1%2)*4
            dr += b2 >> 6
            dr -= 1
            dg = ((b2 >> 3)%8)-1
            db = (b2%8)-1
            cPix = (max(0,min(255,cPix[0]+(mult*dr))),max(0,min(255,cPix[1]+(mult*dg))),max(0,min(255,cPix[2]+(mult*db))))
            getInd(index2,cPix)
            continue

        #direct color
        if byte == 127:
            t = [0,0,0]
            for x in range(0,3):
                byteCounter += 1
                byte = bites[byteCounter]
                t[x] = byte
            cPix = (t[0],t[1],t[2])
            getInd(index2,cPix)
            continue

        #Small Diff
        if byte < 192: #small diff
            dr = ((byte >> 4)%4)
            dg = ((byte >> 2)%4)
            db = ((byte >> 0)%4)
            cPix = (cPix[0]+dr-2,cPix[1]+dg-2,cPix[2]+db-2)
            getInd(index2,cPix)
            continue

        #Run Length
        if byte < 255:
            run = byte-192
            continue

        #Long Run
        if byte == 255:
            byteCounter += 1
            byte = bites[byteCounter]
            run = 62 + (byte*256)
            byteCounter += 1
            byte = bites[byteCounter]
            run += byte
            continue


    if True:
        #unreverse odd rows
        i = 0
        for row in range(0,height):
            i = row*width
            if row%2 == 1: # if row is odd, flip it
                bitR[i+2:i+width+2] = bitR[i+2:i+width+2][::-1]

    s = 2
    img = Image.new("RGBA", (width,height))
    pixels = img.load()
    for y in range(height):
        for x in range(width):
            try:
                pixels[x,y] = bitR[s]
            except:
                pixels[x,y] = (255,0,255) #debug color
            s += 1
    sp = filepath.split("/")
    f = sp[-1].split('.')
    img.save('Images\\' + str(sp[-2]) + '\\' + str(f[0]) + '.png')

if __name__ == "__main__":
    #qolDecode("I:\\love\\upwards\\Images\\FMV\\logo.jli")
    qolDecode(sys.argv[1])