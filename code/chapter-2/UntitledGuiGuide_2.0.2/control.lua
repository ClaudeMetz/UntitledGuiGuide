-- Make sure the intro cinematic of freeplay doesn't play every time we restart
-- This is just for convenience, don't worry if you don't understand how this works
script.on_init(function()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then  -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    storage.players = {}
end)


script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    storage.players[player.index] = { controls_active = true }

    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="ugg_main_frame", caption={"ugg.hello_world"}}
    main_frame.style.size = {385, 165}
    main_frame.auto_center = true

    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="ugg_content_frame"}
    local controls_flow = content_frame.add{type="flow", name="controls_flow", direction="horizontal", style="ugg_controls_flow"}

    controls_flow.add{type="button", name="ugg_controls_toggle", caption={"ugg.deactivate"}}
end)


script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "ugg_controls_toggle" then
        local player_storage = storage.players[event.player_index]
        player_storage.controls_active = not player_storage.controls_active

        local control_toggle = event.element
        control_toggle.caption = (player_storage.controls_active) and {"ugg.deactivate"} or {"ugg.activate"}
    end
end)