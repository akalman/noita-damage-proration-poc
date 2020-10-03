--------------------------------------------------------------------------------
-- a module that will reduce the amount of damage each projectile fired by the
-- player does based on the amount of projectiles that recently fired.  creates
-- incentive for wands that are more damaging per projectile and a burst fire
-- style of attacking.  it also creates a cost associated with random chainsaws
-- and waters thrown into wands because they increase the counter and don't deal
-- any damage.
--
-- every time a projectile is fired we will do two things: increase a global
-- counter representing the number of projectiles fired recently, and then
-- change the damage of the new projectile based on that same global counter.
-- then another script will slowly decrement the global counter by 1 every n
-- frames.
--------------------------------------------------------------------------------

local fire_rate_based_proration = { _version = "0.1.0" }

dofile_once("mods/noita-damage-proration-poc/files/util/shortcuts.lua")

function fire_rate_based_proration.OnWorldInitialized()
	GlobalsSetValue("recent_projectile_count", 0)
end

function fire_rate_based_proration.OnPlayerSpawned(player)
    if not does_entity_have_variable(player, "fire_rate_based_proration_initialized") then
        EntityAddComponent(player, "LuaComponent",
            { script_shot = gen_modpath("fire-rate-based-proration/fire-rate-based-prorator.lua") })

		EntityAddComponent(player, "LuaComponent",
	            { script_shot = gen_modpath("fire-rate-based-proration/fire-rate-counter.lua") })

        EntityAddComponent(player, "LuaComponent", {
			script_source_file = gen_modpath("fire-rate-based-proration/fire-rate-decrementer.lua"),
			execute_every_n_frame = 3
		})

		EntityAddComponent(player, "VariableStorageComponent",
            { name = "fire_rate_based_proration_initialized", value_string = "ignored" })
    end
end

return fire_rate_based_proration
