--!file: startup.lua
--Loading routines for menu, level, etc

function InitialLoad()
    --Set up window & display
    WindowWidth = 1280
    WindowHeight = 720
    love.window.setMode(WindowWidth,WindowHeight, {resizable=true,vsync=1,minwidth=1280,minheight=720,msaa=4,highdpi=true,usedpiscale=true})
    love.window.setTitle("Upwards "..BuildId)

    --Counters
    FrameCounter = 0
    SecondsCounter = 0
    UpdateCounter = 0

    --Images
    LogoImg = decodeJLI("Images/FMV/logo.jli")
    --TitleScreenImg = love.graphics.newImage("Images/FMV/title.png")

    
    --Scaling
    GameScale = 1
    Zoom = 1
    ZoomBase = 1
    love.graphics.setDefaultFilter("linear","nearest",4)


    --Variables
    FpsLimit = 0 --71 = 60FPS, 0 = Uncapped FPS
    
    --Keyboard Constants
    KeyBinds = {
        ['Jump'] = love.keyboard.getScancodeFromKey('space'),
        ['Left'] = love.keyboard.getScancodeFromKey('a'),
        ['Right'] = love.keyboard.getScancodeFromKey('d'),
        ['Up'] = love.keyboard.getScancodeFromKey('w'),
        ['Slide'] = love.keyboard.getScancodeFromKey('s'),
        ['Dive'] = love.keyboard.getScancodeFromKey('lctrl'),
        ['Pause'] = love.keyboard.getScancodeFromKey('escape'),
        ['Call'] = love.keyboard.getScancodeFromKey('q'),
        ['Throw'] = love.keyboard.getScancodeFromKey('e'),
        ['Sprint'] = love.keyboard.getScancodeFromKey('lshift'),
    }
end

function MenuLoad()
    State = 'menu'
    MenuMenu()
end

function LoadLevel(level)

    --Load Images
    HexImg = love.graphics.newImage("Images/UI/hex.png")
    KunaiImg = love.graphics.newImage("Images/UI/kunai.png")
    DefaultPhoneImg = love.graphics.newImage("Images/Phone/normal1.png")
    PausePhoneImg = love.graphics.newImage("Images/Phone/pause.png")

    HpImages = {
        ['red0'] = love.graphics.newImage("/Images/Hearts/red0.png"),
        ['red1'] = love.graphics.newImage("/Images/Hearts/red1.png"),
        ['red2'] = love.graphics.newImage("/Images/Hearts/red2.png"),
        ['red3'] = love.graphics.newImage("/Images/Hearts/red3.png"),
        ['red4'] = love.graphics.newImage("/Images/Hearts/red4.png"),
        ['blue1'] = love.graphics.newImage("/Images/Hearts/blue1.png"),
        ['blue2'] = love.graphics.newImage("/Images/Hearts/blue2.png"),
        ['blue3'] = love.graphics.newImage("/Images/Hearts/blue3.png"),
        ['blue4'] = love.graphics.newImage("/Images/Hearts/blue4.png"),
        ['silver1'] = love.graphics.newImage("/Images/Hearts/silver1.png"),
        ['silver2'] = love.graphics.newImage("/Images/Hearts/silver2.png"),
        ['blood'] = love.graphics.newImage("/Images/Hearts/blood.png")
    }

    State = 'game'

    --Setup Lists
    ThrownKunai = {}
    Particles = {}
    Buttons = {}
    Health = {Heart(1,4),Heart(1,4)}
--Initial Variable Values
    Kunais = 5
    DKunais = 5
    DiffCX = 0
    DiffCY = 0
    DebugPressed = false
    DebugInfo = false
    TileUpdates = 0
    ScreenshotText = -1
    HudEnabled = true
    KunaiReticle = false
    NewRenderer = true
    HighGraphics = true
    CreativeMode = false
    DrawDT = 0

    --Phone Calls
    NextCall = 0
    TBoxWidth = 0
    BoxRect = ''
    NameRect = ''
    TextName = ''
    CurrentText = {'','',''}
    PhoneCounter = 0
    PhoneScale = 4

    --Phone variables
    TriggerPhone = false
    PhoneX = 0
    PhoneY = 0

    --Load Level
    loadARL(level..".arl")
    --Spawn Player
    Pl = Player(SpawnPoint[1]*32,SpawnPoint[2]*32+32)
    CameraX = Pl.xpos
    CameraY = Pl.ypos

    --Initialize BG Objects
    love.resize()

end