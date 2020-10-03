--------------------------------------------------------------------------------
-- every time a project is fired from the player, we look up the projectile tree
-- that created the projectile and exponentially scale damage based on how many
-- elements the tree has. alternatively this could be done recursively for each
-- bullet.  this would require resolving each bullet to its place in the tree.
--------------------------------------------------------------------------------

json = dofile_once("mods/noita-damage-proration-poc/files/util/json.lua")
base64 = dofile_once("mods/noita-damage-proration-poc/files/util/base64.lua")

function shot(projectile_entity_id)
    local var_components = EntityGetComponent(projectile_entity_id, "VariableStorageComponent")
    local projectile_tree_id = -1
    for _,var in pairs(var_components) do
        if (ComponentGetValue(var, "name") == "projectile_tree_id") then
            projectile_tree_id = ComponentGetValue(var, "value_int")
        end
    end

    local proj_tree_string = GlobalsGetValue("projectile_tree_" .. projectile_tree_id)
    local decoded_tree_string = base64.decode(proj_tree_string)
    projectile_tree = json.decode(decoded_tree_string)

    local projectile_component = EntityGetFirstComponent(projectile_entity_id, "ProjectileComponent")
    local damage = ComponentGetValue(projectile_component, "damage")

    local proration = math.pow(0.7, projectile_tree.projectile_count-1)
    local new_damage = damage * proration

    print("projectile tree based proration: changed damage from " .. damage
        .. " to " .. new_damage .. " because there were "
        .. projectile_tree.projectile_count .. " projectiles in the projectile tree.")

    ComponentSetValue(projectile_component, "damage", new_damage)
end
