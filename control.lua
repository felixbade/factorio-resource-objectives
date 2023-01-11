local objectives = {
    {
        item = "stone",
        quantity = 30,
        note = "Tip: try finding some big rocks."
    },
    {
        item = "coal",
        quantity = 30,
        note = "Tip: huge rocks have coal inside."
    },
    {
        item = "iron-plate",
        quantity = 50,
        note = "Tip: when you hold a coal over a machine, you can press Z to insert one. You can also hold Z and drag the coal over multiple machines."
    },
    {
        item = "coal",
        quantity = 200,
        note = "Tip: burner drills can feed directly into each other."
    },
    {
        item = "iron-gear-wheel",
        quantity = 30,
        note = "Tip: having intermediate materials in your inventory significantly speeds up crafting more complex recipes."
    },
    {
        item = "stone-brick",
        quantity = 50,
        note = "Tip: you can build a stone path with them to increase walking speed."
    },
    {
        item = "copper-plate",
        quantity = 20,
        note = "Tip: ctrl+click a furnace to take everything out."
    },
    {
        item = "electronic-circuit",
        quantity = 20
    },
    {
        item = "pipe-to-ground",
        quantity = 10
    },
    {
        item = "lab",
        quantity = 1,
        note = "Tip: you will need electricity for using it."
    },
    {
        item = "automation-science-pack",
        quantity = 5
    },
    {
        item = "assembling-machine-1",
        quantity = 1,
        note = "Tip: assembling machines can really speed you up, even if you hand-feed them."
    },
    {
        item = "gun-turret",
        quantity = 2,
        note = "Tip: you might want a machine gun and armor as well."
    },
    {
        item = "firearm-magazine",
        quantity = 100,
        note = "Tip: you can't have too many assembling machines."
    },
    {
        item = "raw-fish",
        quantity = 50,
        note = "Tip: it heals you in battle."
    },
    {
        item = "small-electric-pole",
        quantity = 50
    },
    {
        item = "transport-belt",
        quantity = 100
    },
    {
        item = "inserter",
        quantity = 100
    },
    {
        item = "iron-gear-wheel",
        quantity = 1000
    },
    {
        item = "electronic-circuit",
        quantity = 500
    },
    {
        item = "fast-inserter",
        quantity = 10
    },
    {
        item = "firearm-magazine",
        quantity = 1000,
        note = "Tip: you might want to use electric miners."
    },
    {
        item = "gun-turret",
        quantity = 50
    },
    {
        item = "logistic-science-pack",
        quantity = 100
    },
    {
        item = "steel-plate",
        quantity = 100
    },
    {
        item = "assembling-machine-2",
        quantity = 50
    },
    {
        item = "fast-transport-belt",
        quantity = 100
    },
    {
        item = "engine-unit",
        quantity = 15
    },
    {
        item = "car",
        quantity = 1
    },
    {
        item = "piercing-rounds-magazine",
        quantity = 500
    },
    {
        item = "military-science-pack",
        quantity = 50
    },
    {
        item = "big-electric-pole",
        quantity = 50
    },
    {
        item = "pumpjack",
        quantity = 5
    },
    {
        item = "flamethrower-turret",
        quantity = 5
    },
    {
        item = "rail",
        quantity = 1000
    },
    {
        item = "rail-chain-signal",
        quantity = 10
    },
    {
        item = "plastic-bar",
        quantity = 1
    },
    {
        item = "sulfur",
        quantity = 1
    },
    {
        item = "advanced-circuit",
        quantity = 500
    },
    {
        item = "stack-inserter",
        quantity = 20
    },
    {
        item = "chemical-science-pack",
        quantity = 50
    },
    {
        item = "cannon-shell",
        quantity = 100
    },
    {
        item = "flamethrower-ammo",
        quantity = 100
    },
    {
        item = "electric-engine-unit",
        quantity = 100
    },
    {
        item = "flying-robot-frame",
        quantity = 100
    },
    {
        item = "roboport",
        quantity = 1
    },
    {
        item = "utility-science-pack",
        quantity = 200
    },
    {
        item = "productivity-module-3",
        quantity = 1
    },
    {
        item = "space-science-pack",
        quantity = 500
    },
    {
        item = "artillery-shell",
        quantity = 200
    },
    {
        item = "atomic-bomb",
        quantity = 1
    },
    {
        item = "spidertron-remote",
        quantity = 1
    }
}

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

function reward(player)
    local objective = objectives[global.current_objective]
    game.print({
        "",
        player.name .. " earned " .. objective.quantity .. " x ",
        game.item_prototypes[objective.item].localised_name
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
        game.item_prototypes[objective.item].localised_name,
        ": " .. has_amount .. "/" .. objective.quantity
    }

    if objective.note then
        table.insert(goal_description, "\n\n" .. objective.note)
    end

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
