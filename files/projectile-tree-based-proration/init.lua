--------------------------------------------------------------------------------
-- a module that will reduce the amount of damage each projectile fired by the
-- player does based on the amount of projectiles fired by that one fire event.
-- creates incentive for wands that are more damaging per projectile.  it also
-- creates a cost for using trigger mechanics as a payload delivery system for
-- powerful but dangerous spells.
--
-- every time a projectile is fired we will do two things: construct a tree of
-- all the projectiles fired in that action and attach a variable with the id
-- of the projectile tree to each bullet that will be spawned.  this is done by
-- cycling through a pretermined set of entity xml files based on the id.  this
-- will break if the player fired a wand n times before the first projectile
-- tree has finished spawning all its projectiles, where n is the number of
-- entity files.  currently this as 10 entity files, but we will likely need
-- more in practice to avoid errors.
--------------------------------------------------------------------------------

local projectile_tree_based_proration = { _version = "0.1.0" }

dofile_once("mods/noita-damage-proration-poc/files/util/shortcuts.lua")

function projectile_tree_based_proration.OnWorldInitialized()
	GlobalsSetValue("current_projectile_id", 0)
end

function projectile_tree_based_proration.OnPlayerSpawned(player)
    if not does_entity_have_variable(player, "projectile_tree_based_proration_initialized") then
        EntityAddComponent(player, "LuaComponent",
            { script_wand_fired = gen_modpath("projectile-tree-based-proration/projectile-tree-id-counter.lua") })

        EntityAddComponent(player, "LuaComponent",
            { script_shot = gen_modpath("projectile-tree-based-proration/projectile-tree-based-prorator.lua") })

		EntityAddComponent(player, "VariableStorageComponent",
            { name = "projectile_tree_based_proration_initialized", value_string = "ignored" })
    end
end

function projectile_tree_based_proration.CoreFileAppend()
    ModLuaFileAppend("data/scripts/gun/gun.lua", gen_modpath("projectile-tree-based-proration/gun-append.lua"))
end

return projectile_tree_based_proration
