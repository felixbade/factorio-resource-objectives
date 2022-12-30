local objectives = {
    {
        item = "stone",
        quantity = 1,
        note = "Tip: find some big rocks."
    },
    {
        item = "coal",
        quantity = 1
    },
    {
        item = "iron-plate",
        quantity = 100
    }
}

function next_objective()
    global.current_objective = (global.current_objective or 0) + 1
    if global.current_objective > #objectives then
        player.set_goal_description("") -- Hide objective pop-up
    else
        for _, player in pairs(game.players) do
            update_goal_text(player, false)
        end
    end
end

function reward(player)
    local objective = objectives[global.current_objective]
    game.print({
        "",
        player.name .. " earned " .. objective.quantity .. " x ",
        {"item-name." .. objective.item}
    })
    player.insert{name=objective.item, count=objective.quantity}
end

script.on_init(function()
    global.current_objective = 1
end)

function update_goal_text(player, silent)
    if global.current_objective > #objectives then
        return
    end
    local objective = objectives[global.current_objective]

    local inventory = player.get_main_inventory()

    local has_amount = 0
    if inventory ~= nil then
        -- Bug: the player doesn't have an inventory during the spaceship
        -- crash cut scene, so the has_amount will be 0 in the beginning of
        -- the game even if there is something. The amount will be updated
        -- once the player's inventory is changed in some way.
        has_amount = inventory.get_item_count(objective.item)
    end

    local goal_description = {
        "", -- A special key for concatenating
        "Have resources in your inventory:\n",
        "[item=" .. objective.item .. "] ",
        {"item-name." .. objective.item},
        ": " .. has_amount .. "/" .. objective.quantity
    }

    player.set_goal_description(goal_description, silent)

    if has_amount >= objective.quantity then
        reward(player)
        next_objective()
    end
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
