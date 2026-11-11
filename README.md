# Movement System Test

This is NOT a released game. This is a Roblox place dedicated for experimentation and testing. This was my attempt of implementing a single-script architecture and OOP with two phase initialization (first each module is constructed, and then after all other modules are constructed, I initialized/started each module). For each system I had in my game, I had a module specifically dedicated to it. I tried creating several systems in this project: sprinting system, stamina system, and a camera system.
> **NOTE**: I created this project after about a year into coding on Roblox. Prior to that, I  had experience coding in Scratch and basic programming in Python. While learning Luau, I was also doing basic Java programming. I would consider my process of learning to script on Roblox a bit weird because I mostly focused on coding systems rather than coding small models, which is probably not common considering most people would have started with the latter first.

The remaining information in this README will detail what I've created in this project.

## Architecture
For each system, for example the Camera system, I created a dedicated module. Each system is an object, so modules are class definitions of the system. There are two types of systems in my project:
- server systems, can be found in a folder through this path: `ServerScriptService`>`Modules`
- client systems, can be found in a folder through this path: `ReplicatedStorage`>`Modules`>`Client`

I was focused on only creating client systems though so I don't have server systems in this project. I also have a `Shared` within the `Modules` folder of the `ReplicatedStorage` which would contain modules and scripts that are shared between the server and client, however just like with server systems, I did not create shared modules for this project. 

I had a "two-phase initialization" system for both my server and client systems:
- When a server is created, the [Server](src/server/Server.server.luau) script, located in `ServerScriptService`, will first run. It will construct the object. After each system has been constructed, the `.start()` method of each system will be called.
- When a player joins the game, the [client_init_load](src/client/client_init_load.client.luau) script, located in `StarterPlayerScripts` will first run. It requires [ClientModules](src/client/ClientModules.luau) which just like the [Server](src/server/Server.server.luau) script, will construct objects of systems specific to the client. After each system has been constructed, the `.start()` method of each system will be called.

## Systems
- [Movement system w/ sprinting + double-jump](src/Modules/Client/MovementController.luau)
- [Stamina that depletes when sprinting](src/Modules/Client/StaminaSystem.luau)
- [Camera w/ sprinting fov change](src/Modules/Client/CameraController.luau)
