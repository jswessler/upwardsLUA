--!file: startup.lua
--Loading routines for menu, level, etc

function InitialLoad()
    --Set up window & display
    WindowWidth = 1280
    WindowHeight = 800
    love.window.setMode(WindowWidth,WindowHeight, {resizable=true,vsync=1,minwidth=1280,minheight=720,msaa=2,highdpi=true,usedpiscale=true,fullscreen=false})
    love.window.setTitle("Upwards "..BuildId)

    --Counters
    FrameCounter = 0
    SecondsCounter = 0
    UpdateCounter = 0
    DrawCounter = 0

    FrameTime = {}
    GlobalDt = 0

    --Lists
    Buttons = {}
    
    --Scaling
    GameScale = 1
    Zoom = 1
    ZoomBase = 1
    love.graphics.setDefaultFilter("linear","linear",4)
    ScreenshotText = 0
    XPadding = 0
    YPadding = 0

    --Images
    LogoImg = love.graphics.newImage("Images/FMV/logo.png")
    TitleImg = love.graphics.newImage("Images/FMV/title.png")
    FrameCounter = -1
    State = 'initialload'
    Physics = 'off'


    --Variables
    FpsLimit = 0 --71 = 60FPS, 0 = Uncapped FPS
    Next_Time = 0
    
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
        ['Skip'] = love.keyboard.getScancodeFromKey('return'),
        ['Fast'] = love.keyboard.getScancodeFromKey('lshift'),
    }

end

function MenuLoad()
    State = 'title'
    Physics = 'off'
    MenuMenu()
end

function LoadLevel(level)

    LoadThread = love.thread.newThread("lib/loadARL.lua")
    LoadStatusCH = love.thread.getChannel("status")
    LoadAmtCH = love.thread.getChannel("amt")
    love.graphics.setDefaultFilter("linear","nearest",4)
    --LoadThread:start('lvl1.arl')

    --Load Images
    HexImg = love.graphics.newImage("Images/UI/hex.png")
    KunaiImg = love.graphics.newImage("Images/UI/kunai.png")
    DefaultPhoneImg = love.graphics.newImage("Images/Phone/normal1.png")
    PausePhoneImg = love.graphics.newImage("Images/Phone/pause.png")

    Physics = 'on'

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
        ['blood'] = love.graphics.newImage("/Images/Hearts/blood.png"),
        ['crit'] = love.graphics.newImage("/Images/Hearts/red_crit.png")
    }

    State = 'game'

    --Setup Lists
    ThrownKunai = {}
    Entities = {}
    Particles = {}
    Buttons = {}
    Enemies = {}
    HudPremov = {}
    Health = {Heart(1,4),Heart(1,4)}
--Initial Variable Values
    Kunais = 5 --Number of kunais
    DKunais = 5 --Displayed number of kunais
    Coins = 0 --Number of coins
    DiffCX = 0 --Camera diff X
    DiffCY = 0 --Camera diff Y
    DebugPressed = false --If you're pressing any debug keys
    DebugInfo = false --If the F3 menu is displayed
    TileUpdates = 0 --Number of tile updates
    ScreenshotText = -1 --Opacity of screenshot text
    HudEnabled = true --If the HUD is enabled
    KunaiReticle = false --If the kunai reticle is displayed
    NewRenderer = true --If the canvas renderer is used (instead of screen)
    HighGraphics = true --If the "fancy" graphics are selected
    CreativeMode = false --If the player is in creative mode
    DrawDT = 0 --IDK
    StepSize = 4 --Quarterstep size for entities
    HeartFlashCounter = -10000 --Timer for low HP flashing
    HeartFlashAmt = 0 --Opacity of heart flashing
    HeartJumpCounter = -10000 --Timer for heart jumping (randomly)
    TotalHealth = 8 --Total health of the player (placeholder, updated immediately)
    GlobalGravity = 7.75 --global gravity multiplier

    --Turn on debug with lshift
    if love.keyboard.isDown('lshift') then
        DebugInfo = true
    end

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
    Pl = Player(SpawnPoint[1],SpawnPoint[2]+1)
    CameraX = Pl.xpos
    CameraY = Pl.ypos

    --Initialize BG Objects
    love.resize()

end