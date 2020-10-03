--------------------------------------------------------------------------------
-- this noita mod attempts to demonstrate three different types of damage
-- proration mechanics in noita.  each is extracted into an isolated set of
-- functionality contained within a dedicated subfolder.
--
-- fire rate based proration: will reduce damage the more frequently projectiles
-- are fired.  damage recovers passively over time.
--
-- projectile tree based proration: will reduce damage based on the size of each
-- individual projectile tree.
--
-- enemy defense scaling based proration: will reduce damage taken by enemies
-- based on scaling defenses per damage type.  does not currently work.
--------------------------------------------------------------------------------

dofile_once("mods/noita-damage-proration-poc/files/util/shortcuts.lua")

fire_rate_based_proration = dofile_once(gen_modpath("fire-rate-based-proration/init.lua"))
projectile_tree_based_proration = dofile_once(gen_modpath("projectile-tree-based-proration/init.lua"))
enemy_defense_scaling_based_proration = dofile_once(gen_modpath("enemy-defense-scaling-based-proration/init.lua"))

function OnModPreInit() end
function OnModInit() end
function OnModPostInit() end

function OnPlayerSpawned(player_entity)
	fire_rate_based_proration.OnPlayerSpawned(player_entity)
	projectile_tree_based_proration.OnPlayerSpawned(player_entity)
end

function OnWorldInitialized()
	fire_rate_based_proration.OnWorldInitialized()
	projectile_tree_based_proration.OnWorldInitialized()
end

function OnWorldPreUpdate()
	enemy_defense_scaling_based_proration.OnWorldPreUpdate()
end

function OnWorldPostUpdate() end
function OnMagicNumbersAndWorldSeedInitialized() end

------------------
-- Core Data Edits
------------------

projectile_tree_based_proration.CoreFileAppend()
