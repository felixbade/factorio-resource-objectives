script.on_init(function()
    game.print('initialized')
end)

function check_inventory(event)
    game.print("Checking inventory on tick"..event.tick)
end

script.on_event(defines.events.on_player_main_inventory_changed, check_inventory)

