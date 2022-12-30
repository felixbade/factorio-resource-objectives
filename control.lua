script.on_init(function()
    game.print("Initialized")
end)

function check_inventory(event)
    local player = game.players[event.player_index]
    local inventory = player.get_main_inventory()

    local item_name = "iron-plate"
    local item_count = inventory.get_item_count(item_name)
    game.print(player.name .. " has " .. item_count .. " of " .. item_name)
end

script.on_event(defines.events.on_player_main_inventory_changed, check_inventory)

