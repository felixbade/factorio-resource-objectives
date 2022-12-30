script.on_init(function()
    game.print('initialized')
end)

function check_inventory(event)
    local player = game.players[event.player_index]
    game.print("Checking inventory of "..player.name)
end

script.on_event(defines.events.on_player_main_inventory_changed, check_inventory)

