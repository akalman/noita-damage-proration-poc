## noita-damage-proration-poc

this noita mod attempts to demonstrate three different types of damage
proration mechanics in noita.  each is extracted into an isolated set of
functionality contained within a dedicated subfolder.

fire rate based proration: will reduce damage the more frequently projectiles
are fired.  damage recovers passively over time.

projectile tree based proration: will reduce damage based on the size of each
individual projectile tree.

enemy defense scaling based proration: will reduce damage taken by enemies
based on scaling defenses per damage type.  does not currently work.

### fire rate based proration

a module that will reduce the amount of damage each projectile fired by the
player does based on the amount of projectiles that recently fired.  creates
incentive for wands that are more damaging per projectile and a burst fire
style of attacking.  it also creates a cost associated with random chainsaws
and waters thrown into wands because they increase the counter and don't deal
any damage.

every time a projectile is fired we will do two things: increase a global
counter representing the number of projectiles fired recently, and then
change the damage of the new projectile based on that same global counter.
then another script will slowly decrement the global counter by 1 every n
frames.

#### fire-rate-based-prorator.lua

every time a project is fired from the player, we look up how many
projectiles have been fired recently and exponentially scale damage of the
new projectile based on that.

#### fire-rate-counter.lua

every time a project is fired from the player, we increment a global counter
representing how many projectiles have been fired recently.

#### fire-rate-decrementer.lua

every n frames (as determined by the LuaComponent) we decrement a global
counter representing how many projectiles have been fired recently.
alternatively this counter could be hard reset to zero after a non-zero frame
reload or after n frames without firing.

### projectile tree based proration

a module that will reduce the amount of damage each projectile fired by the
player does based on the amount of projectiles fired by that one fire event.
creates incentive for wands that are more damaging per projectile.  it also
creates a cost for using trigger mechanics as a payload delivery system for
powerful but dangerous spells.

every time a projectile is fired we will do two things: construct a tree of
all the projectiles fired in that action and attach a variable with the id
of the projectile tree to each bullet that will be spawned.  this is done by
cycling through a pretermined set of entity xml files based on the id.  this
will break if the player fired a wand n times before the first projectile
tree has finished spawning all its projectiles, where n is the number of
entity files.  currently this as 10 entity files, but we will likely need
more in practice to avoid errors.

#### gun-append.lua

intercepts core gun firing APIs to construct a projectile tree every time the
wand is fired.  this tree is then published in a global variable for reading
later.  also will append a variable component to each projectile created that
will state the id of the projectile tree that it came from.

#### projectile-tree-based-prorator.lua

every time a project is fired from the player, we look up the projectile tree
that created the projectile and exponentially scale damage based on how many
elements the tree has. alternatively this could be done recursively for each
bullet.  this would require resolving each bullet to its place in the tree.

#### projectile-tree-id-counter

every time the wand is fired we increase a global counter that represents the
current projectile tree id.  we then wrap around at the end of the projectile
tree.

### enemy defense scaling based proration

a module that will reduce the amount of damage each projectile that hits each
given enemy based on the amount of time that enemy has received damage of the
same type recently.  it creates incentive for a more damage dense style of
wand building as well as leveraging a diverse suite of spells for damage.

does not currently work.  there we several different strategies tried here.
the current code is a half implementation of a strategy where we will detect
a collision with a projectile before damage is dealt and adjust accordingly.
this was also tried using collision detection on the projectile itself.

alternatively it could have zero'd out the damage of all projectiles and save
the value somewhere, and when an enemy is actually dealt damage it could
adjust and deal damage again accordingly.  but this requires finding the
projectile entity id from the hurt callback which i didn't figure out how to
do.  there may be something here where the damage value is used to hold some
metadata that can later be used to look up damage amounts but this is super
hacky and not guaranteed to work due to float rounding.

the only option not explored was directly adjusting enemy defenses after
damage but that seems unlikely to work given we don't have a way to isolate
changes to defenses from this mod vs changes from other sources.  for example
if we changed an enemy's explosion resistance from 1 to 1.5 and then later
they got a buff from 1.5 to 3 we wouldn't know what to reduce the resistance
to later.  it could be 2.5 or 2 depending on if the buff was additive or
multiplicative.

this uses a per-update loop check to make sure all the enemies are set up.
this is because there isn't a mod level API hook for spawning enemies like
there is for bullets.  this will need to be fixed, since it hurts performance
pretty badly.

#### debug-log-damage-received.lua

just used to debug how much damage an enemy will actually take to prove that
this proration component works.

#### enemy-defense-scaling-based-prorator.lua

every time a projectile collides with an enemy, but before damage is dealt,
adjust the damage of the projectile based on the number of damage instances
of that damage type this particular enemy has taken recently.
