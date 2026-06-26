// These aren't just reskinned windows, shur up
/obj/structure/mineral_halfwall
	name = "Material Halfwall"
	desc = "Probably shouldn't be looking at this now should you?."
	icon_state = "concrete_halfwall"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	can_be_unanchored = TRUE
	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	pass_flags_self = PASSTRANSPARENT
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	var/decon_speed = 30
	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 1
	var/added_leaning = FALSE
	var/real_explosion_block	//I'm gonna stick this in anyway even though windows.dm told me to ignore it.

/obj/structure/mineral_halfwall/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	air_update_turf(TRUE, TRUE)

	// This is needed, I think.
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM, AfterRotation = CALLBACK(src, PROC_REF(AfterRotation)))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

	AddElement(/datum/element/atmos_sensitive)

/obj/structure/mineral_halfwall/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("The [src] is <b>wrenched</b> to the floor.")
	else
		. += span_notice("The [src] is <i>unwrenched</i> from the floor, and could be deconstructed by <b>welding</b>.")

/obj/structure/mineral_halfwall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(!density)
		return TRUE

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/mineral_halfwall))
		var/obj/structure/mineral_halfwall/moved_halfwall = mover
		return valid_build_direction(loc, moved_halfwall.dir)
	return TRUE

/obj/structure/mineral_halfwall/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (leaving.pass_flags & PASSTRANSPARENT)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/mineral_halfwall/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount = 0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume = 50))
				atom_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_WRENCH)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice("You begin to [anchored ? "unwrench the [src] from":"wrench the [src] to"] the floor..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
				set_anchored(!anchored)
				to_chat(user, span_notice("You [anchored ? "wrench the [src] to":"unwrench the [src] from"] the floor."))
		else if(I.tool_behaviour == TOOL_CROWBAR && !anchored)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice(" You begin to disassemble [src]..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
				new sheet_type(user.loc, sheet_amount, TRUE, user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, span_notice("You successfully disassemble the [src]."))
				qdel(src)
			return
	return ..()

//This is also needed apparently, to update nearby wall icons
/obj/structure/mineral_halfwall/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/mineral_halfwall/set_anchored(anchorvalue)
	..()
	air_update_turf(TRUE, anchorvalue)

/obj/structure/mineral_halfwall/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/mineral_halfwall/proc/can_be_reached(mob/user)
	var/checking_dir = get_dir(user, src)
	if(!(checking_dir & dir))
		return TRUE // Only halfwallss on the other side may be blocked by other things.
	checking_dir = REVERSE_DIR(checking_dir)
	for(var/obj/blocker in loc)
		if(!blocker.CanPass(user, checking_dir))
			return FALSE
	return TRUE

/obj/structure/mineral_halfwall/proc/AfterRotation(mob/user, degrees)
	air_update_turf(TRUE, FALSE)

/obj/structure/mineral_halfwall/Destroy()
	var/turf/local_turf = get_turf(src)
	update_nearby_icons()
	. = ..()
	local_turf.air_update_turf(TRUE, FALSE)

/obj/structure/mineral_halfwall/Move()
	var/turf/T = loc
	. = ..()
	if(anchored)
		move_update_air(T)

/obj/structure/mineral_halfwall/can_atmos_pass(turf/T, vertical = FALSE)
	if(!anchored || !density)
		return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/spawner, 0)

/obj/structure/mineral_halfwall/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/unanchored/spawner, 0)

/obj/structure/mineral_halfwall/concrete
	name = "Thin concrete wall"
	icon_state = "concrete_halfwall"
	desc = "A thin wall of concrete."
	pressure_resistance = 8*ONE_ATMOSPHERE
	rad_insulation = RAD_LIGHT_INSULATION
	opacity = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/concrete/spawner, 0)

/obj/structure/mineral_halfwall/iron
	name = "Thin iron panel"
	desc = "A slim panel wall made of iron."
	icon_state = "iron_halfwall"
	pressure_resistance = 12*ONE_ATMOSPHERE
	rad_insulation = RAD_MEDIUM_INSULATION
	opacity = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/iron/spawner, 0)

/obj/structure/mineral_halfwall/iron/corrogated
	name = "Thin Corrugated iron wall"
	icon_state = "corrugated_halfwall"
	desc = "A corrogated panel of iron."
	pressure_resistance = 6*ONE_ATMOSPHERE
	rad_insulation = RAD_LIGHT_INSULATION
	opacity = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/iron/corrogated/spawner, 0)

/obj/structure/mineral_halfwall/wood
	name = "Thin Wooden Panel"
	icon_state = "wood_halfwall"
	desc = "A wooden panel wall."
	pressure_resistance = 2*ONE_ATMOSPHERE
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	opacity = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mineral_halfwall/wood/spawner, 0)

//////////////////////////////////////////// HALF GIRDER STUFF //////////////////////////////////////////////

/obj/structure/girder/halfwall
	name = "displaced half girder"
	desc = "A half sized structural frame made out of iron; It requires a layer of materials before it can be considered a wall. This one has unachored from the ground."
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced_girder"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 60

/obj/structure/girder/halfwall/attackby(obj/item/W, mob/user, params)
	var/platingmodifier = 1
	if(HAS_TRAIT(user, TRAIT_QUICK_BUILD))
		platingmodifier = 0.7
		if(next_beep <= world.time)
			next_beep = world.time + 10
			playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)
	add_fingerprint(user)

	if(istype(W, /obj/item/gun/energy/plasmacutter))
		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=100))
			var/obj/item/stack/sheet/iron/M = new (loc, 1)
			if(!QDELETED(M))
				M.add_fingerprint(user)
			qdel(src)
			return

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("You smash through [src]!"))
		new /obj/item/stack/sheet/iron(get_turf(src))
		W.play_tool_sound(src)
		qdel(src)


	else if(isstack(W))
		if(!isfloorturf(loc))
			balloon_alert(user, "need floor!")
			return

		if(!istype(W, /obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/sheets = W
		if(istype(sheets, /obj/item/stack/sheet/iron))
			var/amount = construction_cost[/obj/item/stack/sheet/iron]
			if(sheets.get_amount() < amount)
				balloon_alert(user, "need [amount] sheets!")
				return
			balloon_alert(user, "adding plating...")
			if (do_after(user, 40*platingmodifier, target = src))
				if(sheets.get_amount() < amount)
					return
				sheets.use(amount)
				var/turf/T = get_turf(src)
				T.spawn/obj/structure/mineral_halfwall/iron
				transfer_fingerprints_to(T)
				qdel(src)
			return

		if(!sheets.has_unique_girder && sheets.material_type)
			var/M = sheets.sheettype
			var/amount = construction_cost["exotic_material"]
			if(state == GIRDER_DISPLACED)
				balloon_alert(user, "secure the girder first!")
				return
			else
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "adding plating...")
				if (do_after(user, 4 SECONDS, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/turf/T = get_turf(src)
					if(sheets.walltype)
						T.PlaceOnTop(sheets.walltype)
					else
						var/turf/newturf = T.PlaceOnTop(/turf/closed/wall/material)
						var/list/material_list = list()
						material_list[SSmaterials.GetMaterialRef(sheets.material_type)] = MINERAL_MATERIAL_AMOUNT * 2
						if(material_list)
							newturf.set_custom_materials(material_list)

					transfer_fingerprints_to(T)
					qdel(src)
				return

		add_hiddenprint(user)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			if(!user.transferItemToLoc(P, drop_location()))
				return
			balloon_alert(user, "inserted pipe")
	else
		return ..()
