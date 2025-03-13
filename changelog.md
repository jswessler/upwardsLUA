Release Log:

l.3
- Changed dive & sprint physics
- Added camera zooming & zoom control blocks
- 

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
