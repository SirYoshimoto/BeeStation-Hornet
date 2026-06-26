//Chain link fences
//Sprites ported from /VG/
#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/smooth_structures/fences/fence_wood.dmi'
	icon_state = "sandbags_0"
	base_icon_state = "sandbags"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FENCES)
	canSmoothWith = list(SMOOTH_GROUP_FENCES)
	armor_type = /datum/armor/structure_fence
	density = TRUE
	max_integrity = 50
	integrity_failure = 0.4
	//"#663300" wood color
	var/cuttable = FALSE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE

/datum/armor/structure_fence
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10

/obj/structure/fence/wood
	name = "Wooden fence"
	desc = "A wooden fence. Provides basic protection."
	icon_state = "sandbags-0"
	base_icon_state = "sandbags"
//	icon_state = "wood_fence-0"


/obj/structure/fence/electric
	name = "Steel fence"
	desc = "A steel fence. Could conduct electricity if powered, but occasionally shorts to the ground."
	icon_state = "wood_fence-0"
	base_icon_state = "wood_fence"
//	icon_state = "steel_fence-0"
	obj_flags = CONDUCTS_ELECTRICITY

/obj/structure/fence/electric/plasteel
	name = "Plasteel fence"
	desc = "A strong fence made of plasteel, this fence has been setup to reliably electrocute intruders."
	icon_state = "wood_fence-0"
	base_icon_state = "wood_fence"
//	icon_state = "plasteel_fence-0"
	armor_type = /datum/armor/structure_plasteel_fence

/datum/armor/structure_plasteel_fence
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
/*
/obj/structure/fence/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, 1)

/obj/structure/fence/electric/Bumped(atom/movable/AM)
	if(!ismob(AM))
		return
	var/mob/M = AM
	shock(M, 70)
	if(prob(50))
		take_damage(1, BRUTE, MELEE, FALSE)

/obj/structure/fence/electric/attack_animal(mob/user)
	. = ..()
	if(!.)
		return
	if(!shock(user, 70) && !QDELETED(src)) //Last hit still shocks but shouldn't deal damage to the fence
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/fence/electric/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/fence/electric/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_warning("[user] hits [src]."), null, null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "hit", important = FALSE)
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/fence/electric/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] mangles [src]."), null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(20, BRUTE, MELEE, 1)

/obj/structure/fence/electric/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!shock(user, 100 * W.siemens_coefficient))
			W.play_tool_sound(src, 100)
			do_after(user,20, target = src)
				deconstruct()
	else if((W.tool_behaviour == TOOL_SCREWDRIVER) && (isturf(loc) || anchored))
		if(!shock(user, 90 * W.siemens_coefficient))
			W.play_tool_sound(src, 100)
			set_anchored(!anchored)
			user.visible_message(span_notice("[user] [anchored ? "fastens" : "unfastens"] [src]."), \
								span_notice("You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor."))
			return
	else if(istype(W, /obj/item/shard) || !shock(user, 70 * W.siemens_coefficient))
		return ..()

/obj/structure/fence/electric/proc/shock(mob/user, prb)
	if(!broken)		// broken fences are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return TRUE
		else
			return FALSE
	return FALSE
*/
/obj/structure/fence/electric/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
					tesla_zap(src, 3, C.newavail() * 0.01, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_delayedload(C.newavail() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/corner
	icon_state = "fence_corner"
	cuttable = FALSE

//HOLE STUFF//
/obj/structure/fence/examine(mob/user)
	. = ..()

	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."



/*
#define CUT_TIME 100
#define CLIMB_TIME 150

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE

	icon = 'icons/obj/fence.dmi'
	icon_state = "fence_straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE

/obj/structure/fence/Initialize(mapload)
	. = ..()

	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()

	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/end
	icon_state = "fence_end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "fence_corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "fence_post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!cuttable)
			to_chat(user, span_notice("This section of the fence can't be cut."))
			return
		if(invulnerable)
			to_chat(user, span_notice("This fence is too strong to cut through."))
			return
		var/current_stage = hole_size
		if(current_stage >= MAX_HOLE_SIZE)
			to_chat(user, span_notice("This fence has too much cut out of it already."))
			return

		user.visible_message(span_danger("\The [user] starts cutting through \the [src] with \the [W]."),\
		span_danger("You start cutting through \the [src] with \the [W]."))

		if(do_after(user, CUT_TIME*W.toolspeed, target = src))
			if(current_stage == hole_size)
				switch(++hole_size)
					if(MEDIUM_HOLE)
						visible_message(span_notice("\The [user] cuts into \the [src] some more."))
						to_chat(user, span_info("You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger."))
						AddElement(/datum/element/climbable)
					if(LARGE_HOLE)
						visible_message(span_notice("\The [user] completely cuts through \the [src]."))
						to_chat(user, span_info("The hole in \the [src] is now big enough to walk through."))
						RemoveElement(/datum/element/climbable)

				update_cut_status()

	return TRUE

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	var/new_density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			new_density = FALSE
	set_density(new_density)

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "fence_door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize(mapload)
	. = ..()

	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "fence_door_opened"
	open = TRUE
	density = FALSE

/obj/structure/fence/door/attack_hand(mob/user, list/modifiers)
	if(can_open(user))
		toggle(user)

	return TRUE

/obj/structure/fence/door/proc/toggle(mob/user)
	open = !open
	visible_message(span_notice("\The [user] [open ? "opens" : "closes"] \the [src]."))
	set_density(!density)
	update_door_status()
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)

/obj/structure/fence/door/proc/update_door_status()
	icon_state = density ? "fence_door_closed" : "fence_door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE
*/

//WOODEN FENCE
/*
/obj/structure/fence/wood
	name = "wooden fence"
	desc = "A wooden fence. Still won't stop your neighbor from looking in."
	icon = 'icons/obj/fence.dmi'
	icon_state = "woodfence_straight"
	cuttable = FALSE

/obj/structure/fence/wood/cut/medium
	icon_state = "woodstraight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/wood/cut/large
	icon_state = "woodstraight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/wood/proc/update_cut_status()
	if(!cuttable)
		return
	var/new_density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(MEDIUM_HOLE)
			icon_state = "woodstraight_cut2"
		if(LARGE_HOLE)
			icon_state = "woodstraight_cut3"
			new_density = FALSE
	set_density(new_density)

/obj/structure/fence/wood/corner
	icon_state = "woodfence_corner"
	cuttable = FALSE

/obj/structure/fence/door/wood
	name = "wooden fence door"
	desc = "Complete with a decorative slide lock, reachable from the otherside!."
	icon_state = "woodfence_door_closed"

/obj/structure/fence/door/wood/Initialize(mapload)
	. = ..()

	update_door_status()

/obj/structure/fence/door/opened/wood
	icon_state = "woodfence_door_opened"


#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE
*/
