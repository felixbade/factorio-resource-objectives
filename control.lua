local item_name = "iron-plate"
local needs_amount = 100

script.on_init(function()
    game.print("Initialized")
end)

function update_goal_text(player, silent)
    local inventory = player.get_main_inventory()

    local has_amount = 0
    if inventory ~= nil then
        -- Bug: the player doesn't have an inventory during the spaceship
        -- crash cut scene, so the has_amount will be 0 in the beginning of
        -- the game even if there is something. The amount will be updated
        -- once the player's inventory is changed in some way.
        has_amount = inventory.get_item_count(item_name)
    end

    local goal = {
        "", -- A special key for concatenating
        "Have resources in your inventory:\n",
        "[item=" .. item_name .. "] ",
        {"item-name." .. item_name},
        ": " .. has_amount .. "/" .. needs_amount
    }

    player.set_goal_description(goal, silent)
end

function check_inventory(event)
    local player = game.players[event.player_index]
    update_goal_text(player, true)
end

function on_new_player(event)
    local player = game.players[event.player_index]
    update_goal_text(player, false)
end

script.on_event(defines.events.on_player_main_inventory_changed, check_inventory)
script.on_event(defines.events.on_player_created, on_new_player)
