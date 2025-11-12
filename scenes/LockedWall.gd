extends StaticBody2D

# This creates a dropdown in the Inspector
enum UnlockCondition {
	MACTAN_BOSS_DEAD,
	ANCESTRAL_KEY
}

# We export the enum to choose what this path checks for
@export var unlock_condition: UnlockCondition

# We add a flag to stop this from running every frame after it's unlocked
var is_unlocked := false

# We use _process so it checks for the key *every frame*
func _process(_delta):
	# If we're already unlocked, don't do anything
	if is_unlocked:
		return

	# Check which flag we're supposed to look at
	match unlock_condition:
		
		UnlockCondition.MACTAN_BOSS_DEAD:
			if PortalManager.is_mactan_boss_dead:
				is_unlocked = true
				
		UnlockCondition.ANCESTRAL_KEY:
			if PortalManager.has_ancestral_key:
				is_unlocked = true

	# If the correct flag is true, destroy this path
	if is_unlocked:
		print("Path unlocked!")
		queue_free()
