---
layout: default
title: Robots
nav: robots
---

## Robot Rumble
I programmed a sumobot in association with another student for the 2015(?) Saskatchewan Robot Rumble. 
We added a third motor to the side of the kit-chassis with a fold-out spatula head to misguide other bots. 

Programming the bot to favour it's other side and take advantage of opponents missing its center of mass was great fun. 
I had to deploy some emergency patches on the competition floor, but things worked out in the end. 
We defeated every other bot with the same kit chassis we were using, finally being taken out by a custom frame heavyweight. 

## Skills Canada
Our team of 4 made 2 robots for the 2017 Skills Canada Robotics competition, where 28 mini sponge footballs needed to be moved through and obstacle course and sent though a raised hole or into a bucket. 

We build two independently controllable robots (mostly out of plywood), one which would position itself centrally, and the other would pass the footballs to the other bot. 
The collecting bot had a grasping arm made out of old VCR components. 
The launching bot had a funnel to catch the balls and guild them to a slide, which would insert a caught ball between two spinning wheels to launch the ball at the hoop, like a full-size football launcher. 

Unfortunately, no programming was done in this project, but we did perform alright, suffering from reliability issues with the slide mechanism. 

## BlueBot
My favourite project so far, a robot controllable by an app on your phone. This was an overhaul of a previous project made by another student, but almost everything was rebuilt from scratch. 

The circuit board was completely remade, reducing it's size, power draw, cost, and adding indicator light and serviceable wire mount points. 
The microcontroller code was originally state-based, leading to very jerky controls; it was overhauled to a control loop, with many more inputs dynamically read constantly rather than by command. A system for smoothly slowing to a standstill if the connection is lost, and quickly recovering from a reboot massively increased reliability. There was also a system for sending specific commands to control other mechanisms, although only a buzzer was implemented.
The app was rebuilt with a more modern component-based design and material styling, and introduced a joystick control to utilize the new smoother control system.
A new housing to fit atop the cassis was also designed, with holes to hold indicator lights.

And the best part is that the new app is backwards compatible with the old robot, and the new robot is backwards compatible with the new app! Any combination of versions work together.

Some of the design files can be seen in this repository, [here](https://github.com/TerronCW/portfolio/tree/main/BlueBot).

---

#### Unfortunately, I'm not the kind of person to take photos, so there aren't any for most of these events