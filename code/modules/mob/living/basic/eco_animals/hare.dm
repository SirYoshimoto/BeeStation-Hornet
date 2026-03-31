/mob/living/basic/biosystem_animals/hare_bio
	name = "\improper hare"
	desc = "A wild hare."
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	health = 20
	maxHealth = 20
	speed = 2.50
	icon = 'icons/mob/biosystem/biosystem_animals.dmi'
	icon_state = "hare"
	icon_living = "hare"
	icon_dead = "hare_dead"
	speak_emote = list("sniffles","twitches")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	can_be_held = TRUE
	density = FALSE
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_HERBIVORE)
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ai_controller = /datum/ai_controller/basic_controller/hare_bio

/mob/living/basic/biosystem_animals/hare_bio/Initialize()
    . = ..()
    apply_status_effect(/datum/status_effect/bio_life)

/datum/ai_controller/basic_controller/hare_bio
	blackboard = list()

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(/datum/ai_planning_subtree/find_and_hunt_target/herbivore,)
