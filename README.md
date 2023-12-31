## This is really another project that happens to use what's done of Mellow so far (forked). I figured the Mellow readme might be useful though, so I've left it below.


# Mellow Engine
Mellow Engine is a game engine that I'm working on. While not the 
first I've ever made, it will definitely be the most organized and 
cohesive.

# Platforms
Mellow Engine currently only supports Windows, but its design will 
allow me to more easily implement support for other platforms later on.

It uses OpenGL and I plan on adding support for DirectX and Vulkan 
in the future.

# Installation with git and Premake

Installation is not a difficult process, but keep in mind that Windows 
is currently the only supported platform.

## Downloading with git

Downloading the files is pretty simple. Essentially, all you 
need to do is run this command:

```
git clone --recursive https://github.com/MiniFalafel/Mellow.git [YOUR_DIRECTORY]
```
NOTE: The part in brackets is instructions, not part of the command!

The ```--recursive``` flag is necessary because it downloads all 
submodules as well. Without these, the engine will not work.

## Premake
After that, you need to generate a project with the 
```premake5.lua``` file.

If you're using Windows, you can run the ```Win_GenProjects-vs2019.bat``` 
file (in the ```scripts``` folder) to generate a Visual Studio solution accodringly.
