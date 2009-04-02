
Q/A :

	Q: Those dynamic lights lag my PC, how do i remove it?
	A: Open up your console and type in "WTiberium_NoDynamicLights 1" (Without the quotation marks).

	Q: The tiberium grows to fast/slow!
	A: you can use the commands "WTiberium_MaxProductionRate" and "WTiberium_MinProductionRate" to set the spawn rate of the tiberium,
		you can also limit the amount of tiberium entities spawned per entity with the command "WTiberium_MaxProduction".

Credits :
	Lynix : For the original tiberium models.
	kevkev : For the rest of the stuff.


Changelog :

	1.13 :
	Tiberium will no longer spawn so close to another tiberium entity,
	Tiberium will no longer attempt to grow upon another piece of tiberium or a player,
	The gas effect of the tiberium sprayer now starts closer,
	Fixed the missile launcher,
	Added balloon tooltips to the tiberium tank and Refined tiberium tank,
	Tiberium now emits gas when removed,
	Tiberium now emits gas when spawned,
	Added a tiberium seeder warhead,
	The tiberium entities will no longer collide with the player,
	The missile now gives more arguments to the warhead,
	Added a sonic grenade (No effect yet),
	Changed the range of the harvester from 200 units to 300 units,
	Added a spark effect for the harvester,
	Added a tiberium chemical plant,
	Fixed the refinery not draining resources,
	Moved all the variables for using the tiberium base to the shared file,
	Added more variables to the tiberium base,
	Added a tiberium prop (Only spawnable with Lua),
	Added the thermonium warhead,
	Added a small, medium and large storage tank of every resource in the tiberium addon,

	1.12 :
	Better spawn heights for the entities,
	Added RD3 support (Untested!),

	1.11 :
	Different sizes and colors of gas are now possible,
	Fixed the gas having the wrong color on the blue tiberium,
	Fixed a typo in the gas code,
	Added a way to set the damage of the gas,
	Made the tiberium sprayer use the new functions,

	1.1 :
	Added a power plant that runs on refined tiberium,
	Fixed the tiberium sprayer,
	I now use env_smoketrail for a better looking effect,
	Blue and green tiberium will no longer spawn close to eachother,
	Added a docs folder with some info,
	
	1.0 :
	Initial Release.
