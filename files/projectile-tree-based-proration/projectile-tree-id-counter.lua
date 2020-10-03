--------------------------------------------------------------------------------
-- every time the wand is fired we increase a global counter that represents the
-- current projectile tree id.  we then wrap around at the end of the projectile
-- tree.
--------------------------------------------------------------------------------
function wand_fired(gun_entity_id)
    local current_projectile_id = tonumber(GlobalsGetValue("current_projectile_id"))
    GlobalsSetValue("current_projectile_id", (current_projectile_id+1) % 10)
end
