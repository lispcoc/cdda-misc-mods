local MOD = {
  id = "hadaka_mod",
  debug_enable = true
}

mods[MOD.id] = MOD

--[[
  各種関数
]]
function MOD.debug(msg)
  if MOD.debug_enable then
    game.add_msg(tostring(msg))
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

function MOD.layer_str(it)
  local layers = {
    "UNDERWEAR",
    "REGULAR_LAYER",
    "WAIST_LAYER",
    "OUTER_LAYER",
    "BELTED_LAYER",
    "MAX_CLOTHING_LAYER"
  }
  local i = it:get_layer()
  if layers[i + 1] then
    return layers[i + 1]
  end
  return "REGULAR_LAYER"
end

--[[
  特質：露出狂の処理
]]
function MOD.exibitionism_effect()
  local bp_rate = {
    bp_torso = 1,
    bp_leg_l = 0.5,
    bp_leg_r = 0.5
  }
  local layer_rate = {
    UNDERWEAR = 1,
    REGULAR_LAYER = 1,
    WAIST_LAYER = 0.5,
    OUTER_LAYER = 1,
    BELTED_LAYER = 0.5,
    MAX_CLOTHING_LAYER = 0
  }
  local rate_per_bp = {}
  local rate = 0
  local n = -2
  local it = player:i_at(n)
  while not it:is_null() do
    for k, v in pairs(bp_rate) do
      if not it:has_flag("SUGGESTIVE") then
        if it:covers(k) then
          if not rate_per_bp[k] then
            rate_per_bp[k] = 0
          end
          local c = it:get_coverage()
          local lr = layer_rate[MOD.layer_str(it)]
          rate_per_bp[k] = math.max(rate_per_bp[k], v * lr * c)
        end
      end
    end
    n = n - 1
    it = player:i_at(n)
  end
  for _, v in pairs(rate_per_bp) do
    rate = rate + v
  end
  local penalty = math.floor(rate / 30)
  MOD.debug(penalty)
  player:remove_effect(efftype_id("exhibitionism"))
  player:add_effect(efftype_id("exhibitionism"), TURNS(500 + 1000 * penalty))
end

function MOD.expert_fit(it)
  if it:has_flag("HADAKA_EXPERT_FIT") then
    return true
  end
  return false
end

--[[
  特質：持たざる者の処理
]]
function MOD.expert_effect()
  local n = -2
  local it = player:i_at(n)
  local bonus = 10
  local bp_rate = {
    bp_torso = 6,
    bp_head = 1,
    bp_eyes = 0,
    bp_mouth = 0,
    bp_arm_l = 1,
    bp_arm_r = 1,
    bp_hand_l = 1,
    bp_hand_r = 1,
    bp_leg_l = 3,
    bp_leg_r = 3,
    bp_foot_l = 1,
    bp_foot_r = 1
  }
  local bp_chk = {}
  while not it:is_null() do
    if not MOD.expert_fit(it) then
      for k, v in pairs(bp_rate) do
        if not bp_chk[k] then
          bp_chk[k] = 0
        end
        if it:covers(k) then
          bp_chk[k] = math.max(bp_chk[k], it:get_coverage())
        end
      end
    end
    n = n - 1
    it = player:i_at(n)
  end
  for k, v in pairs(bp_rate) do
    bonus = bonus - v * bp_chk[k] / 100
  end
  MOD.debug(bonus)
  if bonus > 0 then
    player:mod_dodge_bonus(bonus)
    player:mod_hit_bonus(bonus / 4)
  end
end

--[[
  特質：裸体主義者の処理
]]
function MOD.nudist_effect_on_minute()
  local bp_rate = {
    bp_torso = 1,
    bp_head = 0.1,
    bp_eyes = 0,
    bp_mouth = 0,
    bp_arm_l = 1,
    bp_arm_r = 1,
    bp_hand_l = 0.1,
    bp_hand_r = 0.1,
    bp_leg_l = 1,
    bp_leg_r = 1,
    bp_foot_l = 0.01,
    bp_foot_r = 0.01
  }
  local layer_rate = {
    UNDERWEAR = 0.5,
    REGULAR_LAYER = 1,
    WAIST_LAYER = 0,
    OUTER_LAYER = 1,
    BELTED_LAYER = 0,
    MAX_CLOTHING_LAYER = 0
  }
  local n = -2
  local it = player:i_at(n)
  local target = {}
  while not it:is_null() do
    if not MOD.expert_fit(it) then
      local rate = 0
      for k, v in pairs(bp_rate) do
        local lr = layer_rate[MOD.layer_str(it)]
        if it:covers(k) then
          rate = math.min(rate + lr * v, 1)
        end
      end
      if rate > 0 then
        local r = math.random(100000)
        local chance = math.pow(it:get_coverage(), 2) * rate
        MOD.debug(r .. "/" .. chance)
        if r <= chance then
          table.insert(target, it)
        end
      end
    end
    n = n - 1
    it = player:i_at(n)
  end
  for _, it in pairs(target) do
    game.add_msg("あなたは" .. it:display_name() .. "を勝手に脱ぎ捨てた！")
    map:add_item(player:pos(), player:i_rem(it))
  end
end

--[[
  メイン処理
]]
MOD.traits_on_turn = {
  HADAKA_EXHIBITIONISM = MOD.exibitionism_effect,
  HADAKA_EXPERT = MOD.expert_effect
}

MOD.traits_on_minute = {
  HADAKA_NUDIST = MOD.nudist_effect_on_minute
}

function MOD.on_turn_passed()
  for trait_name, trait_function_name in pairs(MOD.traits_on_turn) do
    if (player:has_base_trait(trait_id(trait_name))) then
      trait_function_name()
    end
  end
end

function MOD.on_minute_passed()
  for trait_name, trait_function_name in pairs(MOD.traits_on_minute) do
    if (player:has_base_trait(trait_id(trait_name))) then
      trait_function_name()
    end
  end
end

function MOD.on_day_passed()
end

function MOD.on_game_loaded()
end

function MOD.on_new_player_created()
end

function MOD.on_skill_increased()
end

MOD.on_game_loaded()
