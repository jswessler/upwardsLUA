Release Log:

a1.2.3
- Main menu options screen

a1.2.2
- Scroll to zoom
- Gravity & physics adjustments

a1.2.1
- Physics adjustments & Bug fixes

a1.2_01 (labeled as 1.1.1_01)
- Bug fixes

a1.2 (labeled as a1.1.1)
- New pixel art set
- Changed hex art
- Added a spin attack
- Changed platforming: Dive and spin are mutually exclusive per airtime, dive jump removed, you get your double jump back after diving
- Physics adjustments
- Animation adjustments

a1.1.0_04_01
- Changed energy bar colors

a1.1.0_04
- More sliding/fading animations

a1.1.0_03
- Camera adjustments
- Global tile updating enabled

a1.1.0_02
- Gamestate is now stored more precisely
- Tile updating/ticking is now framerate-independent

a1.1.0_01
- Camera shake is now dependent on FPS
- Emphasized slide to gain velocity on the ground
- Added more customization for platforming stats

a1.1.0
- Changed how energy is added
- Threaded level loading routine
- Added fade in/slide in animations to certain actions
- Animated title screen!
- Level loading progress bar

a1.0.13
- HUD and player no longer animate when paused

a1.0.12
- Added customization for player platforming stats
- Adjusted logo & image scaling
- Split animations into their own file (prep for dialogue portraits)
- Enemies recoil in the correct direction after being knifed

a1.0.11
- Added kunai throwing animation
- Fixed memory leak issues
- Adjusted how the FPS cap works

a1.0.10
- Performance optimizations

a1.0.9
- Removed JLI images

a1.0.8
- Enemies squish over time when you jump on them
- Entity scaling works properly
- Graphics adjustments
- Player draw function moved back into Player class
- Adjusted sensor debug info

a1.0.7
- Added enemies, coins, and entity player detection
- Generalized kunais and coins to an entity superclass
- Adjusted physics

a1.0.6 SC
- Removed weird textures
- Fixed HUD kunai animations
- Fixed debug menu/pause menu behavior
- Added heart flashing when low HP
- Added heart jumping when picking up new health or randomly
- Going below 1 heart works properly

a1.0.5_03
- Movement bug fixes, holding jump & dive together works properly

a1.0.5_02
- Bug Fixes & Optimizations

a1.0.5_01
- Bug Fixes
- Energy drain function
- Changed energy parameters
- Hold shift to open up debug menu immediately upon loading

a1.0.5
- Quarterstep adjustment setting
- Made new Entity class
- Hold shift to go straight into game

a.1.0.4_01
- Hovering over the phone now shows its hitbox
- Phone now shrinks & grows properly

a1.0.3
- Fixed player animations when falling off a block

a1.0.2
- Changed button look

a1.0.1
- Bug fixes
- Preload JLI decoder algorithm

a1.0
- Title screen
- Menu optimizations

l.a R1
- Logo
- Limit FPS option
- Physics adjustments
- JLI Decoder algorithm (python based)

l.5
- Fixed kunai throwing when fullscreen
- Reimplemented fast/fancy graphics

l.5 RC2
- Fixed some rendering issues
- Added panning camera up with W
- Changed how energy bar is drawn

l.5 RC1
- Adjusted block drawing when zoomed out
- Reduced draw calls
- Added Particles

l.4
- Adjusted zooming behavior
- Adjusted dash crystal respawning behavior
- Added shadows to buttons & player

l.4 RC2
- Removed sprinting, added continuous speed increase while running
- Adjusted energy

l.4 RC1
- Customizable Keybinds
- Title screen (sort of)
- Physics fixes

l.3.3
- Player physics & collision fixes

l.3.2
- Bug Fixes

l.3.1
- Code cleanup
- All debug text works again
- Updated tile updating function

l.3
- Changed dive & sprint physics
- Added camera zooming & zoom control blocks
- Added pause menu graphic to phone

l.3 RC1
- Added sprinting
- Changed diving to be continuous and give you lots of momentum

l.2
- Added creative flight mode
- Improved button code
- Cleaned up code

l.2 RC1
- Major rendering changes
- Roughly doubled FPS

l.1.1
- Camera adjustments
- Slide animation fixes

l.1
- Bug Fixes
- Red tile changes
- Ctrl wallsliding & Hover changes

l.1 Gold
- Slide continuation colliders cover your entire top area
- buttons slide in from the left
- quit brings up an "are you sure?" prompt
- phone call text fixes
- fix double jump height

l.1 RC1
- Feature parity with Python
- Added menu options
- Physics fixes
- Camera adjustments, now works properly when resizing
- HighDPI support (for mac)

l.0x_01
- Added button class that can run functions when clicked.
- Added spawn points

l.010
- Adjusted HUD, added background & lines
- Added phone UI
- Added pausing, resuming, and gamestates

l.09_01
- Function file refactor
- Level loading cuts off on the right/bottom edges
- Centered text functions

l.09
- Text is now framerate independent
- Rewrote most text code for global use
- Physics adjustments
- Kunais display properly and are now mostly based from the player class instead of global
- Added kunai innacuracy & targeting reticle

l.08
- Added ground clip prevention on walls
- Implemented phone calls
- Implemented phone UI

l.07
- Completely new debug screen
- Enabled screenshots & HUD hiding
- New font

l.06
- Kunai HUD animation
- Kunai throwing & pickup
- Proper double-sized tiles
- Fixed right edge of level loading routine
- Scaling the game window works properly

l.05_04
- Physics fixes
- l.05_04a - Fix for blue hearts

l.05_03
- Fixes for clipping prevention
- Energy use changes (especially after slide)

l.05_02
- Updated player energy functions
- Implemented silver hearts
- Code adjustments
- l.05_02a - Adjusted floor clip prevention


up-l.05_01
- Added kunai code, throwing not implemented yet
- Added tostring to all objects

up-l.05
- Implemented sliding
- Physics fixes
- Added sliding under obstacles (keeps you in slide animation while you go under)
- Fixed last frame of double jump animation
- Fixes for some dive-related cheese techs

up-l.04
- Implemented health, hearts, damage & healing
- Background color
- Collision detection works properly for subtypes
- Animation fixes
- Further fixes for clipping into the ground

up-l.03
- Fix for clipping into the ground
- Walljump only works when you're against a big wall
- Non-solid collisions, tile updating

up-l.02-1
- Partially implemented resolution scaling
- Partial fix for clipping into the ground

up-l.01-1
- Initial port to Love2d

id-arc2
- New text functions

id-arc
- Changes to HUD sliding

id181.1
* Hud now slides in/out depending on certain conditions
- Fixed kunai HUD animation

id 17x.1
- No major changes

id166.1
- Pause button introduced
- Does nothing at the moment
- Bug Fixes

id163.1
- Pressing S only pans the camera down when in the air
- Slide cancels when going too slowly
- Fixed going into negative kunais
- Fixes for framerates other than 60

id157.2
* Added sliding animation (2 frame loop, 2 frames transition out)
* Particle class (not implemented yet, just coded)
- Fixed a lot of problems with sliding
- Increased time needed to reset max ground speed

id157.1
- Added requirements.txt
- Made kunai HUD animations work again (mostly)
- Kunai collision improvements

id155.1
* Moved player class into its own file (finally)
- Cleaned up kunai spawning and heart code
+ Known Issue - Heart UI doesn't appear until you take damage or heal

id153.1
- Reduced bottom collision detection
- Spawnpoints work properly

id152.2
* Split several functions into seperate files
* Split Kunai into its own file
- Level loading function is now real Python and actually returns stuff
- HUD now shakes in x&y directions when falling quickly
- Hex no longer refreshes every 10sec
- Healing/Damage is now done locally in the heart script

id152.1
* Split Sensor class into its own file
- Reduced sliding airtime

id149.1
- Moved changelog to a new file
- Double jump glitch is gone

id148.3
* Added sliding (no animation yet)
   - Press S on the ground for a speed boost on a cooldown
   - Press S right after landing for a bigger speed boost
   - Jump at the end of the slide for a higher jump
   - Sliding off a ledge gives some extra airtime
   - Sliding can get you under obstacles
* Wallslide animation
- Wallslide is now more like a slide rather than low gravity
- Physics adjustments & fixes

id148.2
- Debug fixes
- Prep for physics overhaul (fork)

id148.1
* Tile updating now only occurs on-screen (about a 10% FPS gain)
- Different collision detection objects now have different debug colors to differentiate them
- Reduced amount of collision detection to reduce lag
- Fixed several animation problems when idealFps is not set to 60
- Diving while having 0 x-velocity now sends you in the direction you're facing (as opposed to always right)
+ Known issue - when collecting multiple dash crystals at once, double jump may be disabled until walljumping/collecting another dash crystal

id147.1
- Jump animations no longer bounce around a ton
- Jump animations when facing left also bounce around less
- Adjusted silver hearts (90% reduced flat energy gain, but each full heart gives you about 3% reduced gravity and slightly better air movement)
- Holding W now improves your platforming very slightly again


id146.2
- Clicking on phone no longer spams pause/unpause
- You can now pause with ESC

id146.1
* Changed hex art
- Slightly adjusted some physics

id145.4p
* Github is now public
- Slightly reduced width of floor collision (to not interfere with the wall collision)
- Cleaned up wall riding physics, extended right-side hitbox to better align with animiations
- Removed extraneous dive behavior
- Half/Quarter Blue hearts now apply properly

id145.3
- Made spawnpoints work no matter where they are in the map

id145.2
- Made floor collision cover more of your body, which should eliminate getting stuck halfway in walls

id145.1
* You now spawn at a designated spawn point (5-0 tile). This currently only works if the spawnpoint is on-screen at the time of spawning naturally.
* Level generator now has descriptions (based on lvldesc.txt)
- Added speed option for level generator
- Cleaned up 'Other' folder
- Camera box is now only visible when pressing R
- Camera box is 50% less sticky (mouse movement has 0.5x impact when in box, rather than 0x)

id144.1 (previously id42424.1)
- Code&Comment adjustments
- Adjusted Kunai behavior & spawn position
- Level creator now tied to specific build

8/11/23 Build 1
* Added throwing knives & HUD

8/9/23 Build 1
- Lowered top speed
- Various Fixes

7/31/23 Build 3
- Added maxSpd, you can now run 3.15u/f instead of 2.05u/f
- Double jump & dive give you more horizontal speed
- Nerfed silver hearts

7/31/23 Build 2
- Adjusted landing physics

7/31/23 Build 1
- Adjusted energy regen, brought back mid-air regen

7/29/23 Build 1
* Show debug text on every block with T
- Adjusted hover physics
- Moved loading tilemap into loadlevel function
- Silver hearts fully implemented
- Standardized & expanded collision detection

7/28/23 Build 1
* New renderer, draws actual tiles instead of pg.rect
* Shows tiles on level editor
- Adjusted physics
- Energy regens slower
- Lag reduction (Hearts, Level Renderer)
- Sensor now detects subtypes
- DoubleBuf mode
- Silver hearts can spawn
