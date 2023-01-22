objectives = require('objectives')

function get_current_objective()
    return objectives[global.current_objective]
end

function next_objective()
    global.current_objective = (global.current_objective or 0) + 1
    if global.current_objective > #objectives then
        for _, player in pairs(game.players) do
            player.set_goal_description("") -- Hide objective pop-up
        end
    else
        for _, player in pairs(game.players) do
            update_goal_text(player, false)
        end
    end
end

commands.add_command("next_objective", nil, function(command)
    next_objective()
end)

commands.add_command("previous_objective", nil, function(command)
    if global.current_objective > 1 then
        global.current_objective = global.current_objective - 1
    end
    for _, player in pairs(game.players) do
        update_goal_text(player, false)
    end
end)

function log_analytics(line)
    global.analytics_output = (
        (global.analytics_output or "") ..
        "[0.6.0] " .. -- mod version
        "[" .. game.ticks_played .. "] " ..
        line ..
        "\n"
    )
end

commands.add_command("ro_save_analytics", nil, function(command)
    log_analytics("Saving analytics file.")
    local data = global.analytics_output
    
    local filename = "resource_objectives_analytics.txt"
    game.write_file(filename, data, false, command.player_index)
    game.print("Saved analytics to factorio/script-output/" .. filename)
end)

function is_goal_met(player)
    local objective = get_current_objective()
    local inventory = player.get_main_inventory()

    if inventory == nil then
        return false
    end

    for _, resource in pairs(objective.items) do
        local has_amount = inventory.get_item_count(resource.item)

        if has_amount < resource.quantity then
            return false
        end
    end

    log_analytics("Objective met: #" .. global.current_objective)
    return true
end

function reward(player)
    local objective = get_current_objective()
    for _, resource in pairs(objective.items) do
        game.print({
            "",
            player.name .. " earned " .. resource.quantity .. " x ",
            game.item_prototypes[resource.item].localised_name
        })
        player.insert{name=resource.item, count=resource.quantity}
    end
end

script.on_init(function()
    global.current_objective = 1
end)

function update_goal_text(player, silent)
    if global.current_objective > #objectives then
        return
    end
    local objective = get_current_objective()

    local inventory = player.get_main_inventory()

    local goal_description = {
        "", -- A special key for concatenating
    }

    local goal_append = "Have resources in your inventory:\n"

    for _, resource in pairs(objective.items) do
        local has_amount = 0
        if inventory ~= nil then
            -- Bug: the player doesn't have an inventory during the spaceship
            -- crash cut scene, so the has_amount will be 0 in the beginning of
            -- the game even if there is something. The amount will be updated
            -- once the player's inventory is changed in some way.
            has_amount = inventory.get_item_count(resource.item)
        end

        goal_append = goal_append .. "\n[item=" .. resource.item .. "] "
        table.insert(goal_description, goal_append)
        goal_append = ""

        table.insert(goal_description, game.item_prototypes[resource.item].localised_name)

        goal_append = goal_append .. ": " .. has_amount .. "/" .. resource.quantity
    end

    if objective.note then
        
        goal_append = goal_append .. "\n\n" .. objective.note
    end
    table.insert(goal_description, goal_append)

    player.set_goal_description(goal_description, silent)

    if is_goal_met(player) then
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
