--------------------------------------------------------------------------------
-- every n frames (as determined by the LuaComponent) we decrement a global
-- counter representing how many projectiles have been fired recently.
-- alternatively this counter could be hard reset to zero after a non-zero frame
-- reload or after n frames without firing.
--------------------------------------------------------------------------------
local recent_projectile_count = tonumber(GlobalsGetValue("recent_projectile_count"))
GlobalsSetValue("recent_projectile_count", math.max(recent_projectile_count-1, 0))
