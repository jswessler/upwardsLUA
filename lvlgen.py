import pygame as pg
import os

path = os.getcwd()

#Game build associated with level generator
buildId = "a1.2.3"

def saveARL(ls,ls2,dest):
    bitO = []
    bitO.append(0x41) #A
    bitO.append(0x52) #R
    bitO.append(0x4C) #L
    bitO.append(0x6A) #j
    bitO.append(int(lvlWid/256)) #High&Low byte of Width
    bitO.append(lvlWid%256)
    bitO.append(int(lvlHei/256)) #High&Low byte of Height
    bitO.append(lvlHei%256)
    bitO.append(lvlNum) #Level Number
    for i in buildId:
        bitO.append(ord(i)) #build ID 
    while len(bitO) < 64:
        bitO.append(0x00)
    counter = 0
    temp = 0b00000000
    run = 0
    l = len(ls)
    while True:
        if counter>=l:
            break
        cur = ls[counter]
        cur2 = ls2[counter]
        if cur==0: #Run length of empty space
            run+=1
        if run>0 and (run>254 or cur!=0): #Finalizing run length of length 0-255
            bitO.append(0x00)
            bitO.append(run)
            run = 0
        if cur!=0 and run==0: #For all other cases
            bitO.append(cur)
            bitO.append(cur2)
        counter+=1
    bitO.append(0x00) #Ending 4 bytes of 00
    bitO.append(0x00)
    bitO.append(0x00)
    bitO.append(0x00)
    #Checksum
    c = 0
    for i in range(0,len(ls)):
        c+=ls[i]
        c+=ls2[i]
        c+=1
    bitO.append(int(c/256)%256) #Adding Checksum
    bitO.append(c%256) #2 byte checksum (65536)
    o = os.getcwd()
    f = open(os.path.join(path,"Levels",str(dest)),'wb')
    for byte in bitO:
        f.write(bytes([byte]))
    f.close()


loadedTiles = ['']*65536
def loadARL(filename):
    global level,levelSub,loadedTiles
    loadedTiles = ['']*65536
    f = open(os.path.join(path,"Levels",str(filename)),'rb')
    bites = f.read()
    f.close()
    counter = 0
    cou = 0
    width = 10
    height = 10
    while cou<(len(bites))-6:
        byte = bites[cou]
        if counter==4: #Headers
            width+=byte*256
        if counter==5:
            width+=byte
        if counter==6:
            height+=byte*256
        if counter==7:
            height+=byte
        if counter==8:
            width-=10
            height-=10
            lv = [0] * (width*height)
            lv2 = [0] * (width*height)
        if counter>63: #Data
            #print(counter,byte)
            if byte==0:
                cou+=1
                byte = bites[cou]
                counter+=byte-1
            else:
                lv.insert(counter-64,byte)
                cou+=1
                byte = bites[cou]
                lv2.insert(counter-64,byte)
                
        counter+=1
        cou+=1
    level = lv
    levelSub = lv2
    bCounter = 0
    blocks = []
    loadedTiles = ['']*65536
    for bl in level:
        if bl!=0:
            blocks.append((bl*256)+levelSub[bCounter])
        bCounter+=1
    setBlock = set(blocks)
    for i in setBlock:
        try:
            loadedTiles[i] = pg.image.load(os.path.join(path,"Images", "Tiles", str(int(i/256)) + "-" + str(int(i%256)) + ".png"))
        except:
            pass

#Setup
pg.init()
WID = 1920
HEI = 1017
scrollDir = 0
screen = pg.display.set_mode((WID,HEI),pg.RESIZABLE)
running = True
fps = pg.time.Clock()
font = pg.font.SysFont('Comic Sans MS',16)

#Initial stuff

#IMPORTANT----------------------------------
lvlWid = 180
lvlHei = 50
lvlNum = 2
saveTo = 'lvl2.arl'

camerax = 0
cameray = 0
cpBuff = [0,0]

#Loading description file
f = open(os.path.join(path,"Levels",'lvldesc.txt'),'r')
des = f.readlines()
f.close()
#Parsing this info
desc = {}
for line in des:
    l = line.split('\\')
    desc.update({l[0]:l[1]})


level = [0] * (lvlWid*lvlHei)
levelSub = [0] * (lvlWid*lvlHei)


#Main Loop
while running:
    mx,my = pg.mouse.get_pos()
    WID,HEI = pg.display.get_surface().get_size()
    for event in pg.event.get():
        if event.type == pg.QUIT:
            running = False
        if event.type == pg.MOUSEWHEEL:
            scrollDir = event.y
    screen.fill((10,5,5))

    ke = pg.key.get_pressed()
    if ke[pg.K_LSHIFT] or ke[pg.K_RSHIFT]: #2x Speed Scroll
        if ke[pg.K_RIGHT]:
            camerax+=32
        if ke[pg.K_LEFT]:
            camerax-=32
        if ke[pg.K_UP]:
            cameray-=32
        if ke[pg.K_DOWN]:
            cameray+=32
    else:
        if ke[pg.K_RIGHT]:
            camerax+=16
        if ke[pg.K_LEFT]:
            camerax-=16
        if ke[pg.K_UP]:
            cameray-=16
        if ke[pg.K_DOWN]:
            cameray+=16
    if ke[pg.K_s]:
        saveARL(level,levelSub,saveTo)
        screen.fill((0,50,0))
    if ke[pg.K_l]:
        loadARL(saveTo)
        screen.fill((50,0,0))

    mx+=camerax
    my+=cameray

    x = 0
    y = 0
    sx = -1
    sy = -1
    c = 0
    sc = 0
    for row in range(0,lvlHei):
        x=0
        for block in range(0,lvlWid):
            if x<mx<x+32 and y<my<y+32:
                sx = x/32
                sy = y/32
                sc = c
            if level[c]!=0:
                try:
                    screen.blit(loadedTiles[level[c]*256+levelSub[c]],(x-camerax,y-cameray))
                except:
                    pg.draw.rect(screen,(64,64,64),pg.Rect(x-camerax,y-cameray,32,32))
            tsurface = font.render(str(level[c]),True,(180,180,180) if level[c]!=0 else (40,40,40))
            screen.blit(tsurface,(x-camerax+1,y-cameray+0))
            tsurface = font.render(str(levelSub[c]),True,(180,180,180) if levelSub[c]!=0 and level[c]!=0 else (40,40,40))
            screen.blit(tsurface,(x-camerax+1,y-cameray+12))

            c+=1
            x+=32
        y+=32
        
#SX and SY are the x and y positions of the selected block, SC is its position in the list
#Holding control allows you to change the subtype instead of normal type
#Clamps at 255 and 0
    if not ke[pg.K_LCTRL]:
        level[sc]+=scrollDir
        if level[sc]==-1:
            level[sc] = 255
        if level[sc]==256:
            level[sc] = 0
    else:
        levelSub[sc]+=scrollDir
        if levelSub[sc]==-1:
            levelSub[sc] = 255
        if levelSub[sc]==256:
            levelSub[sc] = 0
    scrollDir = 0
    copied = False
    pasted = False
    softPaste = False
    if ke[pg.K_c]: #Copy
        cpBuff[0] = level[sc]
        cpBuff[1] = levelSub[sc]
        copied = True
    if ke[pg.K_v]: #Paste
        level[sc] = cpBuff[0]
        levelSub[sc] = cpBuff[1]
        pasted = True
    if ke[pg.K_b]: #Soft Paste
        level[sc] = cpBuff[0]
        softPaste = True
    if ke[pg.K_ESCAPE]: #Soft Paste
        level[sc] = 0
        levelSub[sc] = 0
        copied = True

#Draw details of the block you're hovering over
    pg.draw.rect(screen,(255,0,0) if copied else (0,255,0) if pasted else (0,0,255) if softPaste else (255,255,255),pg.Rect(sx*32-camerax,sy*32-cameray,32,32))
    tsurface = font.render(str(level[sc]),True,(0,0,0))
    screen.blit(tsurface,((sx*32)-camerax+1,(sy*32)-cameray+0))
    tsurface = font.render(str(levelSub[sc]),True,(0,0,0))
    screen.blit(tsurface,((sx*32)-camerax+1,(sy*32)-cameray+12))

    #Get descriptions (format request first)
    ts = str(level[sc]) + '-' + str(levelSub[sc])
    tsurface = font.render(str(desc.get(ts)),True,(200,0,0))
    screen.blit(tsurface,((sx*32+80)-camerax+1,(sy*32-16)-cameray+12))

    #draw buildId
    tsurface = font.render(str(buildId),True,(230,230,230))
    screen.blit(tsurface,(5,5))

    f = fps.tick(60)
    pg.display.flip()



    
        