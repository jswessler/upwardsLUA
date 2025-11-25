--!file: startup.lua
--Loading routines for menu, level, etc

local json = require "lib.dkjson"

function InitialLoad()
    --Set up window & display
    WindowWidth = 1280
    WindowHeight = 800
    love.window.setMode(WindowWidth,WindowHeight, {resizable=true,vsync=1,minwidth=1280,minheight=720,msaa=4,highdpi=true,usedpiscale=true,fullscreen=false})
    love.window.setTitle("Upwards "..BuildId)

    --Lists
    Buttons = {}
    
    --Scaling
    GameScale = 1
    love.graphics.setDefaultFilter("linear","linear",8)
    XPadding = 0
    YPadding = 0

    MouseWheelY = 0
    LoadingGame = false
    LevelId = nil

    --Images
    LogoImg = love.graphics.newImage("image/FMV/logo.png")
    TitleImgBg = love.graphics.newImage("image/FMV/titlebg.png")
    TitleImgAr = love.graphics.newImage("image/FMV/titlear.png")

    --Canvas
    ScreenCanvas = love.graphics.newCanvas(WindowWidth,WindowHeight,{msaa=4})
    HDMACanvas = love.graphics.newCanvas(WindowWidth/4,WindowHeight/4)
    HDMATempCanvas = love.graphics.newCanvas(WindowWidth/4,WindowHeight/4)
    
    --Keyboard Constants
    KeyBinds = {
        ['Jump'] = love.keyboard.getScancodeFromKey('space'),
        ['Left'] = love.keyboard.getScancodeFromKey('a'),
        ['Right'] = love.keyboard.getScancodeFromKey('d'),
        ['Up'] = love.keyboard.getScancodeFromKey('w'),
        ['Slide'] = love.keyboard.getScancodeFromKey('s'),
        ['Dive'] = love.keyboard.getScancodeFromKey('lctrl'),
        ['Pause'] = love.keyboard.getScancodeFromKey('escape'),
        ['Spin'] = love.keyboard.getScancodeFromKey('lshift'),
        ['Throw'] = love.keyboard.getScancodeFromKey('e'),
        ['Skip'] = love.keyboard.getScancodeFromKey('return'),
        ['Fast'] = love.keyboard.getScancodeFromKey('l'),
    }

    --Variables
    StepSize = 4 --Quarterstep size for entities, isn't reset when going to title screen
    AutoStep = true --automatically set step size
    DebugInfo = false --If the F3 menu is displayed
    CreativeMode = false --If the player is in creative mode
    HudEnabled = true --If the HUD is enabled
    KunaiReticle = false --If the kunai reticle is displayed
    NewRenderer = true --If the canvas renderer is used (instead of screen)
    HighGraphics = true --If the "fancy" graphics are selected
    FpsLimit = 0 --0 = Vsync FPS
    Next_Time = 0 --Helper to keep track of frametime
    GlAni = 0.01 --general purpose timer for global animation. This counts down by dt
    StateVar = {genstate = 'initialload', state = 'initialload', substate = 'N/A', ani = 'N/A', physics = 'off'}
    GameCounter = -1 --Tracks real time
    SecondsCounter = 0 --Floor of frametime
    UpdateCounter = 0 --Ticks for each update
    TileUpdateTime = 0 --Tracks tile updating
    DrawCounter = 0 --Ticks for each frame
    FadingText = {-1,''} --Opacity of screenshot text


end

function LoadLevel(level)
    StateVar.state = 'loadlevel'
    StateVar.genstate = 'none'
    LoadThread = love.thread.newThread("lib/loadARL.lua")

    --set filter for pixel art
    love.graphics.setDefaultFilter("linear","nearest",4)

    --Load Images
    HexImg = love.graphics.newImage("image/UI/hex.png")
    KunaiImg = love.graphics.newImage("image/UI/kunai.png")
    DefaultPhoneImg = love.graphics.newImage("image/Phone/normal1.png")
    PausePhoneImg = love.graphics.newImage("image/Phone/pause.png")

    HpImages = {
        ['red0'] = love.graphics.newImage("/image/Hearts/red0.png"),
        ['red1'] = love.graphics.newImage("/image/Hearts/red1.png"),
        ['red2'] = love.graphics.newImage("/image/Hearts/red2.png"),
        ['red3'] = love.graphics.newImage("/image/Hearts/red3.png"),
        ['red4'] = love.graphics.newImage("/image/Hearts/red4.png"),
        ['blue1'] = love.graphics.newImage("/image/Hearts/blue1.png"),
        ['blue2'] = love.graphics.newImage("/image/Hearts/blue2.png"),
        ['blue3'] = love.graphics.newImage("/image/Hearts/blue3.png"),
        ['blue4'] = love.graphics.newImage("/image/Hearts/blue4.png"),
        ['silver1'] = love.graphics.newImage("/image/Hearts/silver1.png"),
        ['silver2'] = love.graphics.newImage("/image/Hearts/silver2.png"),
        ['blood1'] = love.graphics.newImage("/image/Hearts/blood1.png"),
        ['gold1'] = love.graphics.newImage("/image/Hearts/gold1.png"),
        ['crit'] = love.graphics.newImage("/image/Hearts/red_crit.png")
    }

    --setup HDMA
    HDMAInit(1)

    --Setup Lists
    ThrownKunai = {}
    Entities = {}
    Particles = {}
    Buttons = {}
    Enemies = {}
    HudMov = {}
    Health = {Heart(1,4),Heart(1,4)}

    --Initial Variable Values
    Kunais = 5 --Number of kunais
    DKunais = 5 --Displayed number of kunais
    Coins = 0 --Number of coins
    DiffCX = 0 --Camera diff X
    DiffCY = 0 --Camera diff Y
    DebugPressed = false --If you're pressing any debug keys
    TileUpdates = 0 --Number of tile updates
    DrawDT = 0 --IDK
    HeartFlashCounter = -10000 --Timer for low HP flashing
    HeartFlashAmt = 0 --Opacity of heart flashing
    HeartJumpCounter = -10000 --Timer for heart jumping (randomly)
    TotalHealth = 8 --Total health of the player (placeholder, updated immediately)
    GlobalGravity = 7.625 --global gravity multiplier. this is the default, this can change per level!
    AutoSave = GameCounter + 10 --autosave timer
    LevelId = level --Set level id

    --a1.3
    EditorRem = {0,0} --Copy/paste in editor memory

    --a1.3.3
    PhoneText = {}
    

    --Camera parameters
    Zoom = 1
    ZoomBase = 1
    ZoomScroll = 0

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
    LoadThread:start(level..".arl") --start level loading thread
    StateVar.ani = 'none'
end

function SaveGame()
    local state = {
        xpos = Pl.xpos, 
        ypos = Pl.ypos, 
        xv = Pl.xv, 
        yv = Pl.yv, 
        health = Health, 
        energy = Pl.energy, 
        ab = Pl.abilities,
        level = LevelId,
    }
    love.filesystem.write("savegame.ars", json.encode(state, {indent=true}))
    FadingText = {150, "Game Saved"}
end

function LoadGame()
    if love.filesystem.getInfo("savegame.ars") then
        local contents = love.filesystem.read("savegame.ars")
        LoadState = json.decode(contents)
        if LoadState then
            LevelTrans(LoadState['level'])
            LoadingGame = true
        end
    end
end

function LevelTrans(level)
    StateVar.ani = 'levelloadtrans' 
    StateVar.substate = level
    GlAni = 0.6
end