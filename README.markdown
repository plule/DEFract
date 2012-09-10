DEFract - A 3D fractal visualisator - v0.4
==========================================

The goal of this soft is to generate real-time 3D pics from distance estimator functions.

It uses [LÖVE](https://love2d.org/) and GLSL.

Do not think this is stable. Use at your own risk. I can't be held responsible if your gpu burns.

Get latest update on [github](https://github.com/plule/DEFract).

What can DEFract do?
--------------------

DEFract produces explorable fractals like this :
![Mechanical madness](https://github.com/plule/DEFract/blob/master/renders/DEFract_12.jpg?raw=true)

Currently you can :
 * Explore 3D fractals (yay!) (even animated one)
 * Edit in real-time the code of the fractals (you save, the fractal is refreshed)
 * Play with the parameters of the fractal
 * Save screenshots

![Animated menger sponge](https://github.com/plule/DEFract/blob/master/renders/psyche2.gif?raw=true)

How can I do this?
------------------

First, launch the program. To do this, you can either run the .exe, the .app, the linux exec or you can install [LÖVE](https://love2d.org/) and run the .love. Note that it has been tested only on a 32b linux and a 32b windows. If you have any trouble, install LÖVE and run the .love.

Under Linux, you will probably need LÖVE dependencies : devil, luajit, openal, physfs, sdl, libvorbis, mpg123.

Then, you might see a black screen, try to move your mouse to find something.

### Keybindings :
 * Arrows to move
 * pageup/pagedown to change focal distance
 * Mouse to look around
 * left control to open gui control panel
 * Tab to switch between fractals
 * F2 to take a screenshot. It will be store in the LÖVE saving directory.
 * Escape to exit

Go to the LÖVE saving directory (displayed with "space" key) and play with the code of the fractal you are seeing. You can see your modification just when you save. Really, you should do this on the rotated menger. You can use the variable "time" if you want animated things.

What ressources have been used?
-------------------------------

Mainly, LÖVE is used. The [hump library](http://vrld.github.com/hump/) and [Quickie](https://github.com/vrld/Quickie) library (for the gui. and it's awesome.) has been used.

I (Pierre Lulé) made the navigation and the rendering.

For the science behind this, the main source is [an awesome serie of blog entries](http://blog.hvidtfeldts.net/index.php/2011/06/distance-estimated-3d-fractals-part-i/) that everyone should read.

The fractals' definitions are from this blog and [fractal forums](http://www.fractalforums.com/).

What is missing?
----------------

 * Better render for screenshots
 * Faster render for real-time
 * Automatic save of the views in the file
 * Alot of bugs/crashes are still present
 * More fractals
 * 2D support (why not?)

Some more pics :
![Mandelbox](https://github.com/plule/DEFract/blob/master/renders/DEFract_3.jpg?raw=true)
![Rotated Mandelbox](http://i.imgur.com/Vshm6.jpg)
![Inside the rotated Mandelbox](http://i.imgur.com/Z3SxB.jpg)
