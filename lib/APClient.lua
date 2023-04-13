-- This is intended to be a general purpose lua client, so keeping dependencies slim.
local JSON = dofile((_G["AP_LIB_PATH"] or "lib") .. "/external/json.lua")
local Compat = dofile((_G["AP_LIB_PATH"] or "lib") .. "/Compat.lua")

----------------------------------------------------------------------------------------------------
-- LOCAL CONSTANTS
----------------------------------------------------------------------------------------------------
-- local MESSAGE_TIMEOUT = 10 * 60 -- 10s in frames
-- local NUM_RETRIES = 3

----------------------------------------------------------------------------------------------------
-- APCLIENT TABLE
----------------------------------------------------------------------------------------------------
local APClient = {
	STATE = {
		DISCONNECTED = 0,
		CONNECTING = 1,
		CONNECTED = 2,
	},

	CLIENT_STATUS = {
		CLIENT_UNKNOWN = 0,
		CLIENT_CONNECTED = 5,
		CLIENT_READY = 10,
		CLIENT_PLAYING = 20,
		CLIENT_GOAL = 30,
	},

	-- Tables containing Recv and Send functions defined below
	RECV = {},
	SEND = {},
}

----------------------------------------------------------------------------------------------------
-- LOCAL DEFS
----------------------------------------------------------------------------------------------------
local socket = nil

local connection_state = APClient.STATE.DISCONNECTED
local current_player_slot = -1
local player_slot_to_name = {}
local deathlink_time_sent = nil
local missing_locations_set = {}
local death_link_enabled = false
local received_items = {}		-- TODO save this state

local game_name = ""
local game_password = ""
local game_tags = {"AP"}

-- Packets being waited on. In some cases we expect the server to respond. We must handle cases where it does not.
-- So we track packets sent and fulfilled here.
--
--	{
--		type: string,					-- packet type
--		sent: table,					-- data that was sent for this packet
--		responseType: string,	-- expected response type
--		retries: int, 				-- number of attempts made
--		timeout: int,					-- frame number to time out on
--	}
--
--local packets_waiting = {} -- TODO

local gameimpl = dofile((_G["AP_LIB_PATH"] or "lib") .. "/APGameInterface.lua")

----------------------------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------------------------------------------
function JSON:onDecodeError(message, text, location, etc)
	gameimpl.error_fn(message)
end


-- Sets the connection state and notifies that it has changed w/ an optional message
function APClient.SetConnectionState(state, msg)
	if connection_state ~= state then
		connection_state = state
		gameimpl.notify_state_change_fn(state, msg)
	end
end


-- Logs an error message and notifies that the client has disconnected.
local function ConnError(msg)
	gameimpl.error_fn(msg)
	APClient.SetConnectionState(APClient.STATE.DISCONNECTED, msg)
end


-- Encodes and sends a command over the socket
local function SendCmd(cmd, data)
	data = data or {}
	data["cmd"] = cmd

	local cmd_str = JSON:encode({data})
	gameimpl.log_fn("SENT: " .. cmd_str)
	socket:send(cmd_str)
end


local function HasError()
	local err_msg = socket:error_msg()
	if err_msg then
		ConnError(err_msg)
		return true
	end
	return false
end


local function contains_element(tbl, elem)
	for _, v in ipairs(tbl) do
		if v == elem then return true end
	end
	return false
end


function APClient.RegisterGameInterface(impl)
	for name, fn in pairs(impl) do
		gameimpl[name] = fn
	end
end


function APClient.RegisterConnectionInterface(connect_interface)
	if socket then return true end

	socket = connect_interface
	APClient.SetConnectionState(APClient.STATE.CONNECTING)
	return not HasError()
end


function APClient.SetConnectionInfo(name, password, tags)
	game_name = name
	game_password = password or ""
	game_tags = tags or {"AP"}
end


----------------------------------------------------------------------------------------------------
-- CLIENT TO SERVER
----------------------------------------------------------------------------------------------------

-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#Connect
function APClient.SEND.Connect()
	APClient.SetConnectionState(APClient.STATE.CONNECTING)

	SendCmd("Connect", {
		password = game_password or "",
		game = gameimpl.game,
		name = game_name,
		uuid = gameimpl.game .. "_" .. game_name,	-- TODO: Generate UUID?
		tags = game_tags,
		version = { major = 0, minor = 4, build = 0, class = "Version" },
		items_handling = gameimpl.items_handling or 7
	})
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#connectupdate
function APClient.SEND.ConnectUpdate(opts)
	SendCmd("ConnectUpdate", opts)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#Sync
function APClient.SEND.Sync()
	SendCmd("Sync")
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#locationchecks
function APClient.SEND.LocationChecks(locations)
	if #locations > 0 then
		SendCmd("LocationChecks", { locations = locations })
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#locationscouts
function APClient.SEND.LocationScouts(locations, create_as_hint)
	if type(create_as_hint) == "boolean" and create_as_hint == true then create_as_hint = 1 end
	if #locations > 0 then
		SendCmd("LocationScouts", { locations = locations, create_as_hint = create_as_hint or 0 })
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#statusupdate
function APClient.SEND.StatusUpdate(status)
	SendCmd("StatusUpdate", { status = status })
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#say
function APClient.SEND.Say(text)
	if text ~= nil and text ~= "" then
		SendCmd("Say", { text = text })
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#getdatapackage
function APClient.SEND.GetDataPackage(games)
	if games == nil or #games > 0 then
		SendCmd("GetDataPackage", { games = games })
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#bounce
function APClient.SEND.Bounce(opts)
	SendCmd("Bounce", opts)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#get
function APClient.SEND.Get(keys)
	if #keys > 0 then
		SendCmd("Get", { keys = keys })
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#set
function APClient.SEND.Set(opts)
	SendCmd("Set", opts)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#setnotify
function APClient.SEND.SetNotify(keys)
	if #keys > 0 then
		SendCmd("SetNotify", { keys = keys })
	end
end


----------------------------------------------------------------------------------------------------
-- SERVER TO CLIENT
----------------------------------------------------------------------------------------------------
local function NotImplemented(cmd, msg)
	gameimpl.error_fn("Command '" .. cmd .. "' not implemented. " .. JSON:encode(msg))
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#roominfo
-- Sent on connection
function APClient.RECV.RoomInfo(msg)
	local checksums = msg["datapackage_checksums"]
	local datapackage_games = {}
	for game, checksum in pairs(checksums) do
		-- TODO cache check

		-- else for any games that we don't have a cache for...
		table.insert(datapackage_games, game)
	end

	if #datapackage_games ~= 0 then
		APClient.SEND.GetDataPackage(datapackage_games)
	else
		APClient.SEND.Connect()
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#connectionrefused
function APClient.RECV.ConnectionRefused(msg)
	local msg_str = "No message given"
	if msg["errors"] then
		msg_str = table.concat(msg["errors"], ",")
	end
	ConnError("Connection Refused: " .. msg_str)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#connected
function APClient.RECV.Connected(msg)
	APClient.SEND.Sync()

	current_player_slot = msg["slot"]
	APClient.SetConnectionState(APClient.STATE.CONNECTED)

	for _, plr in pairs(msg["players"]) do
		player_slot_to_name[plr["slot"]] = plr["name"]
	end

	missing_locations_set = {}
	for _, location in ipairs(msg["missing_locations"]) do
		missing_locations_set[location] = true
	end

	gameimpl.on_connected_fn(msg["slot_data"], msg["missing_locations"])
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#receiveditems
-- This is the reply to the LocationScouts request
function APClient.RECV.ReceivedItems(msg)
	local next_item_index = msg["index"]

	-- Attempt resync if the index is invalid
	if next_item_index > #received_items then
		local items_missed = next_item_index - #received_items
		gameimpl.error_fn("Missed " .. tostring(items_missed) .. " item(s) from the server, attempting to resync.")
		APClient.SEND.Sync()
		return
	end

	local last_index = #received_items + 1
	for i, item in ipairs(msg["items"]) do
		received_items[next_item_index + i] = item
	end

	local new_items = { Compat.unpack(received_items, last_index, #received_items) }
	gameimpl.received_items_fn(new_items)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#locationinfo
-- Result of LocationScouts
function APClient.RECV.LocationInfo(msg)
	-- TODO important
	NotImplemented("LocationInfo", msg)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#roomupdate
function APClient.RECV.RoomUpdate(msg)
	-- Cross out checked locations
	for _, loc in ipairs(msg["checked_locations"] or {}) do
		missing_locations_set[loc] = nil
	end

	--Update player names
	for _, plr in pairs(msg["players"] or {}) do
		player_slot_to_name[plr["slot"]] = plr["name"]
	end

	-- TODO hint points?

	if #(msg["checked_locations"] or {}) > 0 then
		gameimpl.locations_checked_fn(msg["checked_locations"])
	end
end


-- TODO fix this
local function ParseJSONPart(part)
	local result
	if part["type"] == "player_id" then
		result = player_slot_to_name[tonumber(part["text"])]
	elseif part["type"] == "item_id" then
		result = Cache.ItemNames:get(tonumber(part["text"]))
	elseif part["type"] == "location_id" then
		result = Cache.LocationNames:get(tonumber(part["text"]))
	elseif part["type"] == "color" then
		gameimpl.log_fn("Found colour in message: " .. part["color"])
		result = ""	-- TODO color not supported
	else
		-- text, player_name, item_name, location_name, entrance_name
		result = part["text"]
	end

	if result == nil then
		gameimpl.error_fn("Failed to retrieve text for " .. part["type"] .. " " .. part["text"])
		return ""
	end
	return result
end


-- Builds the JSON message
local function ParseJSONParts(data)
	local msg_strs = {}
	for _, part in ipairs(data) do
		table.insert(msg_strs, ParseJSONPart(part))
	end
	return table.concat(msg_strs)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#printjson
function APClient.RECV.PrintJSON(msg)
	local msg_fn = gameimpl.message_handlers[msg["type"]]
	if msg_fn then
		msg_fn(msg)
	elseif msg["data"] ~= nil then
		local msg_str = ParseJSONParts(msg["data"])
		gameimpl.game_print_fn(msg_str)
	else
		gameimpl.error_fn("Invalid PrintJSON format: " .. JSON:encode(msg))
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#datapackage
function APClient.RECV.DataPackage(msg)
	-- TODO new DataPackage cache
	NotImplemented("DataPackage", msg)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#bounced
function APClient.RECV.Bounced(msg)
	if contains_element(msg["tags"], "DeathLink") then
		if not death_link_enabled or msg["data"]["time"] == deathlink_time_sent then return end

		gameimpl.deathlink_triggered_fn(msg["data"])
	else
		gameimpl.log_fn("Unsupported Bounced type received: " .. JSON:encode(msg))
	end
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#invalidpacket
function APClient.RECV.InvalidPacket(msg)
	local err_str = string.format("Invalid packet (%s) for %s: %s", msg["type"], msg["original_cmd"] or "N/A", msg["text"])
	gameimpl.error_fn(err_str)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#retrieved
function APClient.RECV.Retrieved(msg)
	NotImplemented("Retrieved", msg)
end


-- https://github.com/ArchipelagoMW/Archipelago/blob/main/docs/network%20protocol.md#setreply
function APClient.RECV.SetReply(msg)
	NotImplemented("SetReply", msg)
end


----------------------------------------------------------------------------------------------------
-- GAME AND OTHER LOGIC
----------------------------------------------------------------------------------------------------

-- Retrieves the last message from the socket and parses it into a Lua-digestible format
local function GetNextMessage()
	local raw_msg = socket:last_message()
	if not raw_msg then
		return nil
	end

	gameimpl.log_fn("RECV: " .. raw_msg)
	return JSON:decode(raw_msg)[1]
end


-- Finds the appropriate function in the lookup table for a message, and calls it
local function ProcessMsg(msg)
	local cmd = msg["cmd"]

	if APClient.RECV[cmd] then
		APClient.RECV[cmd](msg)
	else
		gameimpl.error_fn("Invalid command '" .. cmd .. "' received. " .. JSON:encode(msg))
	end
end


-- Checks for and processes all network messages waiting
function APClient.Update()
	if not socket then return end

	while socket:poll() do
		local msg = GetNextMessage()
		if msg == nil then break end
		ProcessMsg(msg)
	end

	if socket:status() ~= "open" then
		HasError()
	end
end


function APClient.SetDeathLinkEnabled(enabled)
	death_link_enabled = enabled
	if enabled and not contains_element(game_tags, "DeathLink") then
		table.insert(game_tags, "DeathLink")
	end
	APClient.SEND.ConnectUpdate{ tags = game_tags }
end


function APClient.BounceDeathlink(death_msg, death_time)
	if socket == nil or not death_link_enabled then return end

	deathlink_time_sent = death_time

	local slotname = player_slot_to_name[current_player_slot]
	APClient.SEND.Bounce{
		tags = { "DeathLink" },
		data = {
				time = death_time,
				cause = slotname .. " died to " .. death_msg,
				source = slotname
		}
	}
end


----------------------------------------------------------------------------------------------------
return APClient
