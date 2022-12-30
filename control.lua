local item_name = "iron-plate"
local needs_amount = 100

script.on_init(function()
    game.print("Initialized")
end)

function update_goal_text(player, silent)
    local inventory = player.get_main_inventory()
    local has_amount = inventory.get_item_count(item_name)
    local localized_name = game.get_localised_item_name(item_name)

    local goal = "Have resources in your inventory:\n"
    goal = goal .. "[item=" .. item_name .. "] " .. localized_name .. ": "
    goal = goal .. has_amount .. "/" .. needs_amount

    game.player.set_goal_description(goal, silent)
end

function check_inventory(event)
    local player = game.players[event.player_index]
    update_goal_text(player, true)
end

function on_joined(event)
    local player = game.players[event.player_index]
    update_goal_text(player, false)
end

script.on_event(defines.events.on_player_main_inventory_changed, check_inventory)
script.on_event(defines.events.on_player_joined_game, on_joined)
