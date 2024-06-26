Cave Tools [cavetools]
======================
Some useful tools for exploring caves.

By David G (kestral246@gmail.com)

![Cave Tools](screenshot.png "Cave Tools")

A compilation of some of my other mods focused on making cave exploration easier.

A set of flash lamps that momentarily light up the direction the player is pointed. (**Note:** Pressing shift while left-clicking will activate extended-range flashes.)

- Flash Lamp
- Flash Wand
- Super Flash Lamp

A set of depth finders that probe depth in the direction the player is pointed.

- Flint Depth Finder
- Diamond Depth Finder

An override to the default ladders to allow them to be easily extended down by just right clicking a ladder with another ladder.

- This can create freestanding ladders. If the lack of ladder thickness bothers you, you can use Linuxdirks **redef** mod, which provides 3-d ladders.
- The **ropes** mod by FaceDeer has a similar option for ladders, but extends them upward. Cave Tools' ladder override will conflict with this, but can be disabled (see configuration below).

Updates
-------
**2024-03-13**

- Adjustments to flash lamp ranges and light cones, and duration of flashes.
- Significantly increased number of uses for flash lamps and depth finders.

Configuration
-------------

Each separate feature can be selectively enabled or disabled in the minetest.conf file.

- cavetool_flashlamps = **true**/false
- cavetool_depthfinders = **true**/false
- cavetool_ladders = **true**/false


Dependencies
------------

- Ladder overrides only enabled if **default** exists.
- Craft recipes optionally depend on **default** and **tnt**.
- Wand also optionally depends on **mana**.


Craft Recipes
-------------

![Flash Lamp](images/craft_lamp1.png "Flash Lamp (copper)")
![Flash Lamp](images/craft_lamp2.png "Flash Lamp (tin)")

![Flash Wand](images/craft_wand.png "Flash Wand")
![Super Flash Lamp](images/craft_super.png "Super Flash Lamp")

![Flint Depth Finder](images/craft_flint.png "Flint Depth Finder")
![Diamond Depth Finder](images/craft_diamond.png "Diamond Depth Finder")


Licenses
--------

Source code

> The MIT License (MIT)

Media (textures)

> Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

- Flint texture copied from default\_flint.png by Gambit.
- Diamond texture copied from default\_diamond.png by BlockMen.
- Stick texture copied from default\_stick.png by BlockMen.
