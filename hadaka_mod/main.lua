local MOD = {
    id = "hadaka_mod",
    debug = true
}

mods[MOD.id] = MOD

function MOD.debug(msg)
    if MOD.debug then
        game.add_msg(msg)
    end
end

function MOD.bp_toi(str)
    for k, v in pairs(enums.body_part) do
        if v == str then
            return k
        end
    end
    return nil
end

function MOD.layer_tostr(i)
    local layers = {
        "UNDERWEAR",
        "REGULAR_LAYER",
        "WAIST_LAYER",
        "OUTER_LAYER",
        "BELTED_LAYER",
        "MAX_CLOTHING_LAYER"
    }
    if layers[i + 1] then
        return layers[i + 1]
    end
    return "REGULAR_LAYER"
end

function MOD.nudist_rate(it)
    local bl_bp = {"bp_torso", "bp_leg_l", "bp_leg_r"}
    local rate = 0
    for _, v in pairs(bl_bp) do
        if it:covers(v) then
            local l = MOD.layer_tostr(it:get_layer())
            if l == "REGULAR_LAYER" then
                -- hogehoge
            end
        end
    end
end

function MOD.on_game_loaded()
end

function MOD.on_new_player_created()
end

function MOD.on_skill_increased()
end

function MOD.on_minute_passed()
end

function MOD.on_day_passed()
end

function MOD.on_turn_passed()
end

MOD.on_game_loaded()
