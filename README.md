# SWARM_UI

Used to control and manage multiple Valkyrien Skies 2 "[Tilt-Ships](https://github.com/19PHOBOSS98/TILT-SHIP-LIBRARY-FOR-VALKYRIEN-SKIES-2-AND-COMPUTERCRAFT)"


Drop both folders (DEBUG_CONTROLLER and SWARM_UI) in the `computercraft/computer` directory then rename them to the Computer IDs of your Pocket Computers (with Ender/Wireless peripherals) of your choosing.

## COMPONENTS:

### Swarm UI
My little way of controlling tilt-ship swarms.

Network security needs a bit of work but I think it would be best to leave that to the Hivemancers... have fun hacking eachothers swarms :)

I based it off of this well documented GUI api:
https://github.com/lewark/gui.lua.git

### Debug Controller
Receives transmitted messages from the drone's `debugProbe()` function. 

run `debugger.lua`

Primarily I use it to shut down specific drones while testing (press 'r' while it's running)


## SWARM UI FRAMEWORK
* swarm_controller.lua
  * remoteUI
    * SwarmManager
      * CommandManager
        * DroneProtocolBook
          * DroneProtocolPage


## TO DOs
+ I still need to clean up a few of the libraries
+ Need to make a proper tutorial
+ Documentation
