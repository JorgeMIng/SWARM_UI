os.loadAPI("lib/quaternions.lua")

modem = peripheral.find("modem")
rednet.open("back")

local remote_control_transmitter_channel = 7
local component_broadcast_channel = 100
local debug_transmitter_channel = 9
local DEBUG_TO_DRONE_CHANNEL = 9
local DRONE_TO_DEBUG_CHANNEL = 10
local remote_control_receiver_channel = 8

local main_controller_id =11
modem.close(8)
modem.open(DRONE_TO_DEBUG_CHANNEL)
--modem.open(2)


	--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "hush")

	--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "d")
	--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "shift+d")
	--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "space")
--modem.transmit(debug_transmitter_channel, remote_control_receiver_channel, "hush")
	--modem.transmit(debug_transmitter_channel, remote_control_receiver_channel, "space")
	--modem.transmit(debug_transmitter_channel, remote_control_receiver_channel, "space+w")
	--modem.transmit(debug_transmitter_channel, remote_control_receiver_channel, "w")
	--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "space+d")


--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "space")
--rednet.send(main_controller_id,"hush","remote_controls")
--rednet.send(main_controller_id,"space+w","remote_controls")


--component_control_msg = {cmd="move",BOW={7,5,3,1},STERN={1,2,3,4},PORT={2,4,6,8},STARBOARD={5,7,9,10}}
--modem.transmit(component_broadcast_channel, remote_control_receiver_channel,component_control_msg)

--modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, "w")
--modem.transmit(1,10000,{ship_id=0,ship_orientation={7,4,1,1}})
--local DRONE_ID = 421
--local DRONE_ID = 420
--local DRONE_ID = 301
--local DRONE_ID = 302
--local DRONE_ID = 701
--local DRONE_ID = 507
--local DRONE_ID = 506
local DRONE_ID = 421
function transmit(cmd,args)
	modem.transmit(remote_control_transmitter_channel, remote_control_receiver_channel, 
	{drone_id=DRONE_ID,msg={cmd=cmd,args=args}})
end

transmit("RISE")
--transmit("hush")

local space_pressed = 0
local shift_pressed = 0

function commands()
	while true do
		local event, key, isHeld = os.pullEvent()
		
		if event =="key" then
			
			if key == keys.w then
				if space_pressed == 1 then
				
					transmit("space+w")
				else
					transmit("w")
				end
			elseif key == keys.s then
				if space_pressed == 1 then
					transmit("space+s")
				else
					transmit("s")
				end
			elseif key == keys.a then
				if space_pressed == 1 then
					transmit("space+a")
				elseif shift_pressed == 1 then
					transmit("shift+a")
				else
					transmit("a")
				end
			elseif key == keys.d then
				if space_pressed == 1 then
					transmit("space+d")
				elseif shift_pressed == 1 then
					transmit("shift+d")
				else
					transmit("d")
				end
			elseif space_pressed == 1 then
				transmit("space")
			elseif shift_pressed == 1 then
				transmit("shift")
			end
			
			if key == keys.up then

				transmit("scroll_aim_target",1)
			end
			if key == keys.down then
				
				transmit("scroll_aim_target",-1)
			end
			
			if key == keys.space then
				space_pressed = 1
			end
			if key == keys.leftShift then
				shift_pressed = 1
			end
			if key == keys.r then
				transmit("hush")
				transmit("HUSH")
				break
			elseif key == keys.q then
				break
			elseif key == keys.f then
				transmit("toggle_AUTO_TARGET")
			end
			
			
			
			
		elseif event == "key_up" then
			if key == keys.space then
				space_pressed = 0
			end
			if key == keys.leftShift then
				shift_pressed = 0
			end
		end

	end
end

function listen()
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		term.clear()
		term.setCursorPos(1,1)
		print(senderChannel)
		if message then
			print(textutils.serialize(message))
		end
		
	end
end

parallel.waitForAny(listen,commands)