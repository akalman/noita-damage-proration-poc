--------------------------------------------------------------------------------
-- every time a project is fired from the player, we look up how many
-- projectiles have been fired recently and exponentially scale damage of the
-- new projectile based on that.
--------------------------------------------------------------------------------
function shot(projectile_entity_id)
    local recent_projectile_count = GlobalsGetValue("recent_projectile_count")

    local projectile_component = EntityGetFirstComponent(projectile_entity_id, "ProjectileComponent")
    local damage = ComponentGetValue(projectile_component, "damage")

    local proration =  math.pow(0.95, tonumber(recent_projectile_count))
    local new_damage = damage * proration

    print("fire rate based proration: changed damage from " .. damage .. " to "
        .. new_damage .. " because there were " .. recent_projectile_count
        .. " projectiles fired recently.")

    ComponentSetValue(projectile_component, "damage", new_damage)
end
