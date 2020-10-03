--------------------------------------------------------------------------------
-- every time a project is fired from the player, we increment a global counter
-- representing how many projectiles have been fired recently.
--------------------------------------------------------------------------------
function shot(projectile_entity_id)
    recent_projectile_count = GlobalsGetValue("recent_projectile_count")
    GlobalsSetValue("recent_projectile_count", recent_projectile_count+1)
end
