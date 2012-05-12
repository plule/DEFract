DEFract - A 3D fractal visualisator
===================================

The goal of this is to generate real-time 3D pics from distance estimator functions.

It uses [LÖVE](https://love2d.org/) and GLSL.

What can DEFract do?
--------------------

Currently you can :
 * Explore 3D fractals (yay!)
 * Edit in real-time the code of the fractals (you save, the fractal is refreshed)
 * Switch between pre-defined views
 * Save screenshot, with the position of the view associated

How can I do this?
------------------

First, launch the program (you can either run the .exe, the app, or you can install [LÖVE](https://love2d.org/) and run the .love.

Then, you might see a black screen, try to move your mouse to find something.

### Keybinding :
 * Arrows to move
 * pageup/pagedown to change speed
 * Mouse to look around
 * left control to zoom
 * Click to get/lose focus
 * Return to switch between predefined views (if any)
 * Tab to switch between fractals
 * scroll to change the number of iterations of the renderer (try this if everything is too dark, or too blobby or whatever)
 * F2 to take a screenshot. It will be store in the LÖVE saving directory. You can find this directory by pressing...
 * Space to display informations
 * Escape to exit

What ressources have been used?
-------------------------------

Mainly, LÖVE is used. The vector class from [hump library](vrld.github.com/hump/) has been partially adaptated for 3D operations.

For the knowledge, the main source is [an awesome serie of blog entries](http://blog.hvidtfeldts.net/index.php/2011/06/distance-estimated-3d-fractals-part-i/) that everyone should read.

The fractals' definitions are from this blog and [fractal forums](www.fractalforums.com/).

What is missing?
----------------

 * Better render for screenshots
 * Faster render for real-time
 * Better control
 * Automatic save of the views in the file
 * Alot of bugs/crashes are still present
 * MOAR FRACTALS
 * 2D support (why not?)
