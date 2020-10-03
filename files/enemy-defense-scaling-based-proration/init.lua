--------------------------------------------------------------------------------
-- a module that will reduce the amount of damage each projectile that hits each
-- given enemy based on the amount of time that enemy has received damage of the
-- same type recently.  it creates incentive for a more damage dense style of
-- wand building as well as leveraging a diverse suite of spells for damage.
--
-- does not currently work.  there we several different strategies tried here.
-- the current code is a half implementation of a strategy where we will detect
-- a collision with a projectile before damage is dealt and adjust accordingly.
-- this was also tried using collision detection on the projectile itself.
--
-- alternatively it could have zero'd out the damage of all projectiles and save
-- the value somewhere, and when an enemy is actually dealt damage it could
-- adjust and deal damage again accordingly.  but this requires finding the
-- projectile entity id from the hurt callback which i didn't figure out how to
-- do.  there may be something here where the damage value is used to hold some
-- metadata that can later be used to look up damage amounts but this is super
-- hacky and not guaranteed to work due to float rounding.
--
-- the only option not explored was directly adjusting enemy defenses after
-- damage but that seems unlikely to work given we don't have a way to isolate
-- changes to defenses from this mod vs changes from other sources.  for example
-- if we changed an enemy's explosion resistance from 1 to 1.5 and then later
-- they got a buff from 1.5 to 3 we wouldn't know what to reduce the resistance
-- to later.  it could be 2.5 or 2 depending on if the buff was additive or
-- multiplicative.
--
-- this uses a per-update loop check to make sure all the enemies are set up.
-- this is because there isn't a mod level API hook for spawning enemies like
-- there is for bullets.  this will need to be fixed, since it hurts performance
-- pretty badly.
--------------------------------------------------------------------------------

local enemy_defense_scaling_based_proration = { _version = "0.1.0" }

dofile_once("mods/noita-damage-proration-poc/files/util/shortcuts.lua")

function enemy_defense_scaling_based_proration.OnWorldPreUpdate()
    local enemies = EntityGetWithTag("enemy")
    if enemies == nil then return end

	for _,enemy in ipairs(enemies) do
		if not does_entity_have_variable(enemy, "enemy_defense_scaling_based_proration_initialized") then
            print("initializing enemy")
			local hitbox = EntityGetFirstComponent(enemy, "HitboxComponent")

            EntityAddComponent(enemy, "LuaComponent", {
				script_collision_trigger_hit = gen_modpath("enemy-defense-scaling-based-proration/enemy-defense-scaling-based-prorator.lua"),
				script_damage_received = gen_modpath("enemy-defense-scaling-based-proration/debug-log-damage-received.lua")
			})

            EntityAddComponent(enemy, "CollisionTriggerComponent", {
				width = tonumber(ComponentGetValue(hitbox, "aabb_max_x")) - tonumber(ComponentGetValue(hitbox, "aabb_min_x")),
				height = tonumber(ComponentGetValue(hitbox, "aabb_max_y")) - tonumber(ComponentGetValue(hitbox, "aabb_min_y")),
				radius = "1",
				required_tag = "projectile",
				destroy_this_entity_when_triggered = "false"
			})

            EntityAddComponent(enemy, "VariableStorageComponent", { name = "enemy_defense_scaling_based_proration_initialized", value_string = "ignored" })
		end

	end
end

return enemy_defense_scaling_based_proration
