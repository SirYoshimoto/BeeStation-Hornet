/datum/ai_planning_subtree/find_and_hunt_target/carnivore
	hunt_range = 3
	hunt_targets = list(/mob/living/basic/eco_animals/hare_eco,)
	hunting_behavior = /datum/ai_behavior/hunt_target/carnivore

/datum/ai_behavior/hunt_target/carnivore
	hunt_cooldown = 25 SECONDS
	hunt_emote = "crunches"
