return {
  game = "",
  items_handling = 7,

  log_fn = function(str) print(str) end,
	error_fn = function(str) print(str) end,
	notify_state_change_fn = function(state, msg) end,
	deathlink_triggered_fn = function(data) end,
	on_connected_fn = function(slot_data, missing_locations) end,
	received_items_fn = function(items) end,
	locations_checked_fn = function(locations) end,

	game_print_fn = function(text) print(text) end,
	message_handlers = {},
}
