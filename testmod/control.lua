-- Make sure the intro cinematic of freeplay doesn't play every time we restart
-- This is just for convenience, don't worry if you don't understand how this works
script.on_init(function()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then  -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    global.players = {}
end)

local item_sprites = {"inserter", "transport-belt", "stone-furnace", "assembling-machine-3",
  "logistic-chest-storage", "sulfur", "utility-science-pack", "laser-turret"}

local function build_sprite_buttons(player)
    local button_table = player.gui.screen.ugg_main_frame.content_frame.button_frame.button_table
    button_table.clear()

    local player_global = global.players[player.index]

    for index, sprite_name in ipairs(item_sprites) do
        if index > player_global.button_count then break end

        local button_style = (sprite_name == player_global.selected_item) and "yellow_slot_button" or "recipe_slot_button"
        button_table.add{type="sprite-button", sprite=("item/" .. sprite_name),
          tags={action="ugg_select_button", item_name=sprite_name}, style=button_style}
    end
end

script.on_event(defines.events.on_player_created, function(event)
    global.players[event.player_index] = { controls_active = true, button_count = 0, selected_item = nil }

    local player = game.get_player(event.player_index)
    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="ugg_main_frame", caption={"ugg.hello_world"}}
    main_frame.style.size = {385, 165}
    main_frame.auto_center = true

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical",
      style="ugg_content_frame"}
    local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal",
      style="ugg_controls_flow"}

    controls_flow.add{type="button", name="ugg_controls_toggle", caption={"ugg.deactivate"}}

    controls_flow.add{type="slider", name="ugg_controls_slider", minimum_value=0, maximum_value=#item_sprites,
      style="notched_slider"}
    controls_flow.add{type="textfield", name="ugg_controls_textfield", text="0", numeric=true,
      allow_decimal=false, allow_negative=false, style="ugg_controls_textfield"}

    local button_frame = content_frame.add{type="frame", name="button_frame", direction="horizontal",
      style="ugg_deep_frame"}
    button_frame.add{type="table", name="button_table", column_count=#item_sprites, style="filter_slot_table"}

    build_sprite_buttons(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "ugg_controls_toggle" then
        local player_table = global.players[event.player_index]
        player_table.controls_active = not player_table.controls_active

        local control_toggle = event.element
        control_toggle.caption = (player_table.controls_active) and {"ugg.deactivate"} or {"ugg.activate"}

        local player = game.get_player(event.player_index)
        local controls_flow = player.gui.screen.ugg_main_frame.content_frame.controls_flow
        controls_flow.ugg_controls_slider.enabled = player_table.controls_active
        controls_flow.ugg_controls_textfield.enabled = player_table.controls_active
    elseif event.element.tags.action == "ugg_select_button" then
        local clicked_item_name = event.element.tags.item_name
        global.players[event.player_index].selected_item = clicked_item_name

        local player = game.get_player(event.player_index)
        build_sprite_buttons(player)
    end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
    if event.element.name == "ugg_controls_slider" then
        local player = game.get_player(event.player_index)
        local controls_flow = player.gui.screen.ugg_main_frame.content_frame.controls_flow

        local new_button_count = event.element.slider_value
        global.players[event.player_index].button_count = new_button_count

        controls_flow.ugg_controls_textfield.text = tostring(new_button_count)

        build_sprite_buttons(player)
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name == "ugg_controls_textfield" then
        local player = game.get_player(event.player_index)
        local controls_flow = player.gui.screen.ugg_main_frame.content_frame.controls_flow

        local new_button_count = tonumber(event.element.text) or 0
        local capped_button_count = math.min(new_button_count, #item_sprites)
        global.players[event.player_index].button_count = capped_button_count

        controls_flow.ugg_controls_slider.slider_value = capped_button_count

        build_sprite_buttons(player)
    end
end)