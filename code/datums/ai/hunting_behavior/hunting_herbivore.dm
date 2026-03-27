/datum/ai_planning_subtree/find_and_hunt_target/herbivore
	hunt_range = 8
	hunt_targets = list(/obj/structure/spacevine,)
	hunting_behavior = /datum/ai_behavior/hunt_target/herbivore

/datum/ai_behavior/hunt_target/herbivore
	hunt_cooldown = 10 SECONDS
	hunt_emote = "nibbles"
