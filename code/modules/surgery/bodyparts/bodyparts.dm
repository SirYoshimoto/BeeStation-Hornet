
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts_greyscale.dmi'
	var/husk_icon = 'icons/mob/human_parts.dmi'
	var/husk_type = "humanoid"
	var/static_icon = 'icons/mob/human_parts.dmi' //Uncolorable sprites
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/datum/weakref/original_owner = null
	var/needs_processing = FALSE
	///If you'd like to know if a bodypart is organic, please use is_organic_limb()
	var/bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC //List of bodytypes flags, important for fitting clothing.
	var/change_exempt_flags //Defines when a bodypart should not be changed. Example: BP_BLOCK_CHANGE_SPECIES prevents the limb from being overwritten on species gain

	var/is_husked = FALSE //Duh
	var/limb_id = SPECIES_HUMAN //This is effectively the icon_state for limbs.
	var/limb_gender = "m" //Defines what sprite the limb should use if it is also sexually dimorphic.
	var/uses_mutcolor = TRUE //Does this limb have a greyscale version?
	var/is_dimorphic = FALSE //Is there a sprite difference between male and female?
	var/draw_color //Greyscale draw color

	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	/// The body zone of this part in english ("chest", "left arm", etc) without the species attached to it
	var/plaintext_zone
	var/aux_zone // used for hands
	var/aux_layer = BODYPARTS_LAYER
	var/body_part = null //bitflag used to check which clothes cover this bodypart

	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	var/disabled = BODYPART_NOT_DISABLED //If disabled, limb is as good as missing
	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.7 //Why is this the default???
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0

	var/stamina_dam = 0
	var/stamina_heal_rate = 1	//Stamina heal multiplier

	var/brute_reduction = 0 //Subtracted to brute damage taken
	var/burn_reduction = 0	//Subtracted to burn damage taken

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/should_draw_greyscale = TRUE //Limbs need this information as a back-up incase they are generated outside of a carbon (limbgrower)
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = 1 //whether it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

/obj/item/bodypart/Initialize(mapload)
	..()
	name = "[limb_id] [parse_zone(body_zone)]"
	if(is_dimorphic)
		limb_gender = pick("m", "f")
	update_icon_dropped()

/obj/item/bodypart/forceMove(atom/destination) //Please. Never forcemove a limb if its's actually in use. This is only for borgs.
	. = ..()
	if(isturf(destination))
		update_icon_dropped()

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam >= DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam >= DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"
	if(limb_id)
		. += "<span class='notice'>It is a [limb_id] [parse_zone(body_zone)].</span>"

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(C)
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(IS_ORGANIC_LIMB(src))
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(IS_ORGANIC_LIMB(src))
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	for(var/obj/item/I in src)
		I.forceMove(T)

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam >= DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else
		. = FALSE
	needs_processing = .

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(stam_regen)
	if(stamina_dam >= DAMAGE_PRECISION && stam_regen)					//DO NOT update health here, it'll be done in the carbon's life.
		heal_damage(0, 0, stam_regen, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode
	if(required_status && !(bodytype & required_status))
		return FALSE

	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	var/can_inflict = (max_damage * 2) - get_damage()
	if(can_inflict <= 0)
		return FALSE

	var/total_damage = brute + burn

	if(total_damage > can_inflict)
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	brute_dam += brute
	burn_dam += burn

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	var/current_damage = get_damage(TRUE)		//This time around, count stamina loss too.
	var/available_damage = max_damage - current_damage
	var/applied_damage = min(max_stamina_damage - stamina_dam, available_damage)
	stamina_dam += round(clamp(stamina, 0, applied_damage), DAMAGE_PRECISION)


	if(owner && updating_health)
		owner.updatehealth()
		if(stamina >= DAMAGE_PRECISION)
			owner.update_stamina(TRUE)
			owner.stam_regen_start_time = max(owner.stam_regen_start_time, world.time + STAMINA_REGEN_BLOCK_TIME)
	consider_processing()
	update_disabled()
	return update_bodypart_damage_state()

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && !(bodytype & required_status)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	if(owner.dna && owner.dna.species && (REVIVESBYHEALING in owner.dna.species.species_traits))
		if(owner.health > 0 && !owner.ishellbound())
			owner.revive(0)
			owner.cure_husk(0) // If it has REVIVESBYHEALING, it probably can't be cloned. No husk cure.
	consider_processing()
	update_disabled()
	return update_bodypart_damage_state()

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	set_disabled(is_disabled())

/obj/item/bodypart/proc/is_disabled()
	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		return BODYPART_DISABLED_PARALYSIS
	if(can_dismember() && !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
		. = disabled //inertia, to avoid limbs healing 0.1 damage and being re-enabled
		if((get_damage(TRUE) >= max_damage) || (HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE) && (get_damage(TRUE) >= (max_damage * 0.6)))) //Easy limb disable disables the limb at 40% health instead of 0%
			return BODYPART_DISABLED_DAMAGE
		if(disabled && (get_damage(TRUE) <= (max_damage * 0.5)))
			return BODYPART_NOT_DISABLED
	else
		return BODYPART_NOT_DISABLED

/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(disabled == new_disabled)
		return
	disabled = new_disabled
	owner.update_health_hud() //update the healthdoll
	owner.update_body()
	owner.update_mobility()
	return TRUE //if there was a change.

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute = round((min(brute_dam, max_damage) / max_damage) * 3, 1)
	var/tburn = round((min(burn_dam, max_damage) / max_damage) * 3, 1)
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//Change limb between
//Note:This proc only exists because I can't be arsed to remove it yet. Theres no real reason this should ever be used.
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default)
	if(!(bodytype & new_limb_status))
		bodytype &= ~(BODYTYPE_ROBOTIC & BODYTYPE_ORGANIC)
		bodytype |= new_limb_status

	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(change_icon_to_default)
		if(IS_ORGANIC_LIMB(src))
			icon = DEFAULT_BODYPART_ICON_ORGANIC
		else
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()


//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
//set is_creating to true if you want to change the appearance of the limb outside of mutation changes or forced changes.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = WEAKREF(source)
	else if(original_owner && !IS_WEAKREF_OF(owner, original_owner)) //Foreign limb
		no_update = TRUE
	else
		C = owner
		no_update = FALSE

	if(HAS_TRAIT(C, TRAIT_HUSK) && IS_ORGANIC_LIMB(src))
		dmg_overlay_type = "" //no damage overlay shown when husked
		is_husked = TRUE
	else
		is_husked = FALSE

	if(!dropping_limb && C.dna?.check_mutation(HULK)) //Please remove hulk from the game. I beg you.
		mutation_color = "00aa00"
	else
		mutation_color = null

	if(mutation_color) //I hate mutations
		draw_color = mutation_color
	else if(should_draw_greyscale)
		draw_color = (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))
	else
		draw_color = null

	if(no_update)
		return

	if(!is_creating)
		return

	if(!animal_origin && ishuman(C))
		var/mob/living/carbon/human/H = C

		var/datum/species/S = H.dna.species
		species_flags_list = H.dna.species.species_traits //Literally only exists for a single use of NOBLOOD, but, no reason to remove it i guess...?
		limb_gender = (H.dna.features["body_model"] == MALE) ? "m" : "f"
		if(S.use_skintones)
			skin_tone = H.skin_tone
		else
			skin_tone = ""

		if(((MUTCOLORS in S.species_traits) || (DYNCOLORS in S.species_traits)) && uses_mutcolor) //Ethereal code. Motherfuckers.
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
		else
			species_color = null

		draw_color = mutation_color
		if(should_draw_greyscale) //Should the limb be colored?
			draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))

		dmg_overlay_type = S.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(!IS_ORGANIC_LIMB(src))
		dmg_overlay_type = "robotic"

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)


/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	//Handles dropped icons
	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)

	var/image/limb = image(layer = CALCULATE_MOB_OVERLAY_LAYER(BODYPARTS_LAYER), dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin) //Cringe ass animal-specific code.
		if(IS_ORGANIC_LIMB(src))
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(is_husked)
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		. += emissive_blocker(limb.icon, limb.icon_state, limb.layer, limb.alpha)
		return

	if(is_husked)
		limb.icon = husk_icon
		limb.icon_state = "[husk_type]_husk_[body_zone]"
		. += emissive_blocker(limb.icon, limb.icon_state, limb.layer, limb.alpha)
		if(aux_zone) //Hand shit
			aux = image(limb.icon, "[husk_type]_husk_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
			. += aux
			. += emissive_blocker(limb.icon, "[husk_type]_husk_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
		return

	////This is the MEAT of limb icon code
	if(!should_draw_greyscale || !icon)
		limb.icon = static_icon
	else
		limb.icon = icon

	///The icon_state overlay for the limb
	limb.icon_state = "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]"
	. += emissive_blocker(limb.icon, limb.icon_state, limb.layer, limb.alpha)

	if(!icon_exists(limb.icon, limb.icon_state))
		stack_trace("Limb generated with nonexistant icon. File: [limb.icon] | State: [limb.icon_state]")

	if(aux_zone) //Hand shit
		aux = image(limb.icon, "[limb_id]_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
		. += aux
		. += emissive_blocker(limb.icon, "[limb_id]_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)

	draw_color = mutation_color
	if(should_draw_greyscale) //Should the limb be colored?
		draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))

	if(draw_color)
		limb.color = "#[draw_color]"
		if(aux_zone)
			aux.color = "#[draw_color]"

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	plaintext_zone = "chest"
	px_x = 0
	px_y = 0
	stam_damage_coeff = 1
	max_stamina_damage = 120
	is_dimorphic = TRUE
	var/obj/item/cavity_item

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	if(!((owner.stat == DEAD) || owner.InFullCritical()))
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART

/obj/item/bodypart/chest/monkey/teratoma
	icon_state = "teratoma_chest"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_chest"
	dismemberable = 0
	max_damage = 500
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/chest/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "larva_chest"
	dismemberable = 0
	max_damage = 50
	animal_origin = LARVA_BODYPART

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 1
	px_x = -6
	px_y = 0

/obj/item/bodypart/l_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/l_arm/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/L = owner.hud_used.hand_slots["[held_index]"]
		if(L)
			L.update_icon()

/obj/item/bodypart/l_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_x = -5
	px_y = -3

/obj/item/bodypart/l_arm/monkey/teratoma
	icon_state = "teratoma_l_arm"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/l_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 2
	px_x = 6
	px_y = 0

/obj/item/bodypart/r_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/r_arm/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
		if(held_index)
			owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/R = owner.hud_used.hand_slots["[held_index]"]
		if(R)
			R.update_icon()

/obj/item/bodypart/r_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_x = 5
	px_y = -3

/obj/item/bodypart/r_arm/monkey/teratoma
	icon_state = "teratoma_r_arm"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/r_arm/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_arm"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_arm/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/l_leg
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	plaintext_zone = "left leg"
	body_damage_coeff = 0.75
	px_x = -2
	px_y = 12
	max_stamina_damage = 50

/obj/item/bodypart/l_leg/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/l_leg/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")


/obj/item/bodypart/l_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/l_leg/monkey/teratoma
	icon_state = "teratoma_l_leg"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/l_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_l_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/l_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are available
	icon_state = "default_human_r_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	plaintext_zone = "right leg"
	body_damage_coeff = 0.75
	px_x = 2
	px_y = 12
	max_stamina_damage = 50

/obj/item/bodypart/r_leg/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/r_leg/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(disabled == BODYPART_DISABLED_DAMAGE)
		if(owner.stat < UNCONSCIOUS)
			owner.emote("scream")
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>Your [name] is too damaged to function!</span>")
	else if(disabled == BODYPART_DISABLED_PARALYSIS)
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>You can't feel your [name]!</span>")


/obj/item/bodypart/r_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	animal_origin = MONKEY_BODYPART
	px_y = 4

/obj/item/bodypart/r_leg/monkey/teratoma
	icon_state = "teratoma_r_leg"
	limb_id = "teratoma"
	animal_origin = TERATOMA_BODYPART

/obj/item/bodypart/r_leg/alien
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "alien_r_leg"
	px_x = 0
	px_y = 0
	dismemberable = 0
	max_damage = 100
	animal_origin = ALIEN_BODYPART

/obj/item/bodypart/r_leg/devil
	dismemberable = 0
	max_damage = 5000
	animal_origin = DEVIL_BODYPART
