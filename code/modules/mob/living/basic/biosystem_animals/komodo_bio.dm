/mob/living/basic/biosystem_animals/komodo_bio
	name = "\improper komodo dragon"
	desc = "A big strong lizard that has a taste for flesh."
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_REPTILE
	health = 50
	maxHealth = 50
	speed = 1.25
	icon = 'icons/mob/biosystem/biosystem_animals.dmi'
	icon_state = "komodo"
	icon_living = "komodo"
	icon_dead = "komodo_dead"
	speak_emote = list("hisses","lays still")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	can_be_held = TRUE
	density = FALSE
	response_help_simple = "pet"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_CARNIVORE)
	attack_verb_continuous = "bites"
	attack_verb_simple = "bites"
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/komodo_bio
	melee_damage = 3

/mob/living/basic/biosystem_animals/komodo_bio/Initialize()
    . = ..()
    apply_status_effect(/datum/status_effect/bio_life)

/datum/ai_controller/basic_controller/komodo_bio
	blackboard = list()

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(/datum/ai_planning_subtree/find_and_hunt_target/carnivore,)
