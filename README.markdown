DEFract - A 3D fractal visualisator - v0.4
==========================================

The goal of this soft is to generate real-time 3D pics from distance estimator functions.

It uses [LÖVE](https://love2d.org/) and GLSL.

Do not think this is stable. Use at your own risk. I can't be held responsible if your gpu burns.

Get latest update on [github](https://github.com/PierreLu/DEFract).

What can DEFract do?
--------------------

THIS :

![Mechanical madness](https://github.com/PierreLu/DEFract/blob/master/renders/DEFract_12.jpg?raw=true)

Currently you can :
 * Explore 3D fractals (yay!) (even animated one)
 * Edit in real-time the code of the fractals (you save, the fractal is refreshed)
 * Switch between pre-defined views
 * Save screenshots and all the infos someone need to reproduce your screenshot
 * Record animations

![Animated menger sponge](https://github.com/PierreLu/DEFract/blob/master/renders/psyche2.gif?raw=true)

How can I do this?
------------------

First, launch the program. To do this, you can either run the .exe, the .app, the linux exec or you can install [LÖVE](https://love2d.org/) and run the .love. Note that it has been tested only on a 32b linux and a 32b windows. If you have any trouble, install LÖVE and run the .love.

Under Linux, you will probably need LÖVE dependencies : devil, luajit, openal, physfs, sdl, libvorbis, mpg123.

Then, you might see a black screen, try to move your mouse to find something.

### Keybindings :
 * Arrows to move
 * pageup/pagedown to change speed
 * Mouse to look around
 * left control to zoom
 * Click to get/lose focus
 * Return to switch between predefined views (if any)
 * Tab to switch between fractals
 * scroll to change the number of iterations of the renderer (try this if everything is too dark, or too blobby or whatever)
 * F2 to take a screenshot. It will be store in the LÖVE saving directory. You can find this directory by pressing "space"
 * F3 to start recording. It will be stored as a lot of jpgs. Be careful of your disk space.
 * F4 to slow down time. Useful for recording.
 * Space to display informations
 * Escape to exit

Go to the LÖVE saving directory (displayed with "space" key) and play with the code of the fractal you are seeing. You can see your modification just when you save. Really, you should do this on the rotated menger. You can use the variable "time" if you want animated things.

What ressources have been used?
-------------------------------

Mainly, LÖVE is used. The vector class from [hump library](http://vrld.github.com/hump/) has been partially adaptated for 3D operations.

I (Pierre Lulé) made the navigation and the rendering.

For the science behind this, the main source is [an awesome serie of blog entries](http://blog.hvidtfeldts.net/index.php/2011/06/distance-estimated-3d-fractals-part-i/) that everyone should read.

The fractals' definitions are from this blog and [fractal forums](http://www.fractalforums.com/).

What is missing?
----------------

 * Better render for screenshots
 * Faster render for real-time
 * Better control
 * Automatic save of the views in the file
 * Alot of bugs/crashes are still present
 * MOAR FRACTALS
 * 2D support (why not?)

Hey. Last one :
![Mandelbox](https://github.com/PierreLu/DEFract/blob/master/renders/DEFract_3.jpg?raw=true)
