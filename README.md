# SWARM_UI

Drop both folders (DEBUG_CONTROLLER and SWARM_UI) in the `computercraft/computer` directory then rename them to the Computer IDs of your Pocket Computers (Ender/Wireless) of your choosing.

## Swarm UI
My little way of controlling tilt-ship swarms.

Network security needs a bit of work but I think it would be best to leave that to the Hivemancers... have fun hacking eachothers swarms :)

I based it off of this well documented GUI api:
https://github.com/lewark/gui.lua.git

## Debug Controller
Receives transmitted messages from the drone's `debugProbe()` function. 
run `debugger.lua`
Primarily I use it to shut down specific drones while testing (press 'r' while it's running)
