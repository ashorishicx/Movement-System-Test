# Movement System Test

This is NOT a released game. This is a Roblox place dedicated for experimentation and testing. This was my attempt of implementing a single-script architecture and OOP with two phase initialization (first each module is constructed, and then after all other modules are constructed, I initialized/started each module). For each system I had in my game, I had a module specifically dedicated to it. I tried creating several systems in this project: sprinting system, stamina system, and a camera system.
> **NOTE**: I created this project after about a year into coding on Roblox. Prior to that, I have had experience to coding in Scratch and some basic programming in Python, and while learning Luau, I was also learning basic Java programming. I would consider my process of learning to script on Roblox a bit weird because I mostly focused on coding systems rather than coding small models, which is probably not common considering most people would have started with the latter first.

The remaining information in this README will detail what I've created in this project.

## Architecture
For each system, for example the Camera system, I created a dedicated module. Each system is an object, so modules are class definitions of the system. There are two types of systems in my project
- server systems, which are stored in the `Modules` folder within the `ServerScriptService`
- client systems, which are stored in the `Client` folder which is within the `Modules` folder that is in the `ReplicatedStorage`. I ended up only creating client systems and never actually got to making Server systems though.
- Within the `Modules` folder in my `ReplicatedStorage` I also have a `Shared` folder which would contain modules and scripts that are shared between the server and client, however just like with server systems, I never got to creating those scripts. I was focused on creating client systems for this project. 

I had a "two-phase initialization" system for both my server and client systems:
- When a server is created, the [Server](src/server/Server.server.luau) script, located in `ServerScriptService`, will first run. It will construct the class. After each system has been constructed, the `.start()` method of each system will be called.
- When a player joins the game, the [client_init_load](src/client/client_init_load.client.luau) script, located in `StarterPlayerScripts` will first run. It requires [ClientModules](src/client/ClientModules.luau) which just like the [Server](src/server/Server.server.luau) script, will construct objects of systems specific to the client. After each system has been constructed, the `.start()` method of each system will be called.

## Systems
