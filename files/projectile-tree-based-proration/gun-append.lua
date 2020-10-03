--------------------------------------------------------------------------------
-- intercepts core gun firing APIs to construct a projectile tree every time the
-- wand is fired.  this tree is then published in a global variable for reading
-- later.  also will append a variable component to each projectile created that
-- will state the id of the projectile tree that it came from.
--------------------------------------------------------------------------------

dofile_once("mods/noita-damage-proration-poc/files/util/print.lua")
json = dofile_once("mods/noita-damage-proration-poc/files/util/json.lua")
base64 = dofile_once("mods/noita-damage-proration-poc/files/util/base64.lua")

action_stack = {}
projectile_tree = {}
current_projectile_stack = {}
projectile_count = 0

-----------------------------
-- INITIALIZE PROJECTILE TREE
-----------------------------

function play_action( action )
	table.insert( hand, action )

	set_current_action( action )

	-- if the action stack is empty then this is a new wand fire.  reset
	-- projectile tree variable state.  old trees are still saved in global
	-- variable storage.
	if #action_stack == 0 then
        projectile_tree = {
            id = uuid(),
            type = "event",
            eventtype = "button_press",
            children = {}
        }
        current_projectile_stack = { projectile_tree }
		projectile_count = 0
    end
    action_stack[#action_stack+1] = action

	action.action()

	-- if there are no actions left after removing the current one then we are
	-- done with this wand fire.  save the projectile tree and reset state.
    action_stack[#action_stack] = nil
    if #action_stack == 0 then
		local current_projectile_id = GlobalsGetValue("current_projectile_id")
		projectile_tree.projectile_count = projectile_count
		local treestring = base64.encode(json.encode(projectile_tree))
		GlobalsSetValue("projectile_tree_" .. current_projectile_id, treestring)
        projectile_tree = {
            id = uuid(),
            type = "event",
            eventtype = "button_press",
            children = {}
        }
        current_projectile_stack = { projectile_tree }
		projectile_count = 0
    end

	local is_projectile = false

	if action.type == ACTION_TYPE_PROJECTILE then
		is_projectile = true
		got_projectiles = true
	end

	if  action.type == ACTION_TYPE_STATIC_PROJECTILE then
		is_projectile = true
		got_projectiles = true
	end

	if action.type == ACTION_TYPE_MATERIAL then
		is_projectile = true
		got_projectiles = true
	end

	if is_projectile then
		for i,modifier in ipairs(active_extra_modifiers) do
			extra_modifiers[modifier]()
		end
	end

	OnActionPlayed( action.id )
	current_reload_time = current_reload_time + ACTION_DRAW_RELOAD_TIME_INCREASE
end

------------------------
-- BUILD PROJECTILE TREE
------------------------

old_BeginProjectile = BeginProjectile
function BeginProjectile(entity_filename)
    local current_projectile = current_projectile_stack[#current_projectile_stack]
    if not current_projectile.type == "event" then print("uh oh, current scope is not an event") end
    local new_projectile = {
        id = uuid(),
        type = "projectile",
        file = entity_filename,
        children = {}
    }
    current_projectile.children[#current_projectile.children+1] = new_projectile
    current_projectile_stack[#current_projectile_stack+1] = new_projectile
	projectile_count = projectile_count+1
    old_BeginProjectile(entity_filename)
end

old_EndProjectile = EndProjectile
function EndProjectile()
    current_projectile_stack[#current_projectile_stack] = nil
    old_EndProjectile()
end

old_BeginTriggerHitWorld = BeginTriggerHitWorld
function BeginTriggerHitWorld()
    local current_projectile = current_projectile_stack[#current_projectile_stack]
    if not current_projectile.type == "projectile" then print("uh oh, current scope is not a projectile") end
    local new_event = {
        id = uuid(),
        type = "event",
        eventtype = "collision",
        children = {}
    }
    current_projectile.children[#current_projectile.children+1] = new_event
    current_projectile_stack[#current_projectile_stack+1] = new_event
    old_BeginTriggerHitWorld()
end

old_BeginTriggerTimer = BeginTriggerTimer
function BeginTriggerTimer(timeout_frames)
    local current_projectile = current_projectile_stack[#current_projectile_stack]
    if not current_projectile.type == "projectile" then print("uh oh, current scope is not a projectile") end
    local new_event = {
        id = uuid(),
        type = "event",
        eventtype = "timer",
        children = {}
    }
    current_projectile.children[#current_projectile.children+1] = new_event
    current_projectile_stack[#current_projectile_stack+1] = new_event
    old_BeginTriggerTimer(timeout_frames)
end

old_BeginTriggerDeath = BeginTriggerDeath
function BeginTriggerDeath()
      local current_projectile = current_projectile_stack[#current_projectile_stack]
    if not current_projectile.type == "projectile" then print("uh oh, current scope is not a projectile") end
    local new_event = {
        id = uuid(),
        type = "event",
        eventtype = "death",
        children = {}
    }
    current_projectile.children[#current_projectile.children+1] = new_event
    current_projectile_stack[#current_projectile_stack+1] = new_event
    old_BeginTriggerDeath()
end

old_EndTrigger = EndTrigger
function EndTrigger()
    current_projectile_stack[#current_projectile_stack] = nil
    old_EndTrigger()
end

-------------------------------------
-- APPEND PROJECTILE TREE ID VARIABLE
-------------------------------------

old_ConfigGunActionInfo_PassToGame = ConfigGunActionInfo_PassToGame
function ConfigGunActionInfo_PassToGame(state)
	-- this generates a lot errors, doesn't seem to break anything.  ideally we
	-- would check to see if global state is initialized and the base value has
	-- been added first.
	local current_projectile_id = GlobalsGetValue("current_projectile_id")
    old_entra_entites = c.extra_entities
    c.extra_entities = c.extra_entities .. "mods/noita-damage-proration-poc/files/entities/projectile_tracer_" .. current_projectile_id .. ".xml,"
    old_ConfigGunActionInfo_PassToGame(state)
    c.extra_entities = old_entra_entites
end
