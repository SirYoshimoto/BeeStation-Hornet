/*ECOSYSTEM ANIMALS FOR PLANETSIDE MAPS!
* These animals are able to find things to eat, wander long distances and then return to a burrow or nest.
* They are also able to reproduce to make and sustain a population.
*/
/mob/living/simple_animal/eco_animals/rabbit_eco
	name = "\improper rabbit"
	desc = "A wild rabbit."
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	health = 20
	maxHealth = 20
	icon = 'icons/mob/rabbit.dmi'
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	can_be_held = TRUE
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	ai_controller = /datum/ai_controller/basic_controller/rabbit_eco

	///lifespan counter, over the animals lifetime the damage creeps up and kills them.
	///The older the animal is, the easier it is to kill. Death is inevitable.
/mob/living/simple_animal/eco_animals/rabbit_eco/process(delta_time)
	if(isturf(loc))
		IS_DEAD_OR_INCAP
			STOP_PROCESSING
		return
	else
		START_PROCESSING(L.adjustFireLoss(20 * delta_time))

/datum/ai_controller/basic_controller/rabbit_eco
	blackboard = list()

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		//datum/ai_planning_subtree//
		/datum/ai_planning_subtree/find_and_hunt_target/herbivore,
	)
