/* Glass stack types
 * Contains:
 *		Glass
 *		Reinforced glass
 *		Plasma glass
 *		Reinforced plasma glass
 *		Depleted uranium glass
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/* Glass */

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	item_state = "sheet-glass"
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/glass
	grind_results = list(/datum/reagent/silicon = 20)
	material_type = /datum/material/glass
	point_value = 1
	tableVariant = /obj/structure/table/glass
	matter_amount = 4

/obj/item/stack/sheet/glass/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to slice [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/stack/sheet/glass/get_main_recipes()
	. = ..()
	. += GLOB.glass_recipes

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if (get_amount() < 1 || CC.get_amount() < 5)
			to_chat(user, "<span class='warning>You need five lengths of coil and one sheet of glass to make wired glass!</span>")
			return
		CC.use(5)
		use(1)
		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		new /obj/item/stack/light_w(user.loc, 1, TRUE, user)
	else if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/rglass/RG = new (get_turf(user), null, TRUE, user)
			var/replace = user.get_inactive_held_item() == src
			V.use(1)
			use(1)
			if(QDELETED(src) && !QDELETED(RG) && replace)
				user.put_in_hands(RG)
		else
			to_chat(user, "<span class='warning'>You need one rod and one sheet of glass to make reinforced glass!</span>")
			return
	else
		return ..()

/* Reinforced glass */

/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	item_state = "sheet-rglass"
	custom_materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/rglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/iron = 10)
	point_value = 4
	matter_amount = 6

/obj/item/stack/sheet/rglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	..()

/obj/item/stack/sheet/rglass/cyborg
	mats_per_unit = null
	cost = 250
	source = /datum/robot_energy_storage/metal

	/// What energy storage this draws glass from as a robot module.
	var/datum/robot_energy_storage/glasource = /datum/robot_energy_storage/glass
	/// The amount of energy this draws from the glass source per stack unit.
	var/glacost = 500

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(source.energy / cost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(used, transfer = FALSE) // Requires special checks, because it uses two storages
	source.use_charge(used * cost)
	glasource.use_charge(used * glacost)

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	source.add_charge(amount * cost)
	glasource.add_charge(amount * glacost)

/obj/item/stack/sheet/rglass/get_main_recipes()
	. = ..()
	. += GLOB.reinforced_glass_recipes

/* Plasma glass */

/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy. It looks extremely tough and heavily fire resistant."
	singular_name = "plasma glass sheet"
	icon_state = "sheet-pglass"
	item_state = "sheet-pglass"
	mats_per_unit = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 75, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plasmaglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/toxin/plasma = 10)
	material_flags = NONE
	tableVariant = /obj/structure/table/glass/plasma

/obj/item/stack/sheet/plasmaglass/get_main_recipes()
	. = ..()
	. += GLOB.pglass_recipes

/obj/item/stack/sheet/plasmaglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/plasmarglass/RG = new (get_turf(user), null, TRUE, user)
			var/replace = user.get_inactive_held_item()==src
			V.use(1)
			use(1)
			if(QDELETED(src) && replace)
				user.put_in_hands(RG)
		else
			to_chat(user, "<span class='warning'>You need one rod and one sheet of plasma glass to make reinforced plasma glass!</span>")
			return
	else
		return ..()

/* Reinforced plasma glass */

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough and nearly fire-proof!"
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-prglass"
	item_state = "sheet-prglass"
	mats_per_unit = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.5)
	armor = list(MELEE = 20,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	material_flags = NONE
	merge_type = /obj/item/stack/sheet/plasmarglass
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/toxin/plasma = 10, /datum/reagent/iron = 10)
	point_value = 23
	matter_amount = 8

/obj/item/stack/sheet/plasmarglass/get_main_recipes()
	. = ..()
	. += GLOB.prglass_recipes

/* Titanium glass */

/obj/item/stack/sheet/titaniumglass
	name = "titanium glass"
	desc = "A glass sheet made out of a titanium-silicate alloy."
	singular_name = "titanium glass sheet"
	icon_state = "sheet-titaniumglass"
	item_state = "sheet-titaniumglass"
	mats_per_unit = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/titaniumglass

/obj/item/stack/sheet/titaniumglass/get_main_recipes()
	. = ..()
	. += GLOB.titaniumglass_recipes

/* Plastitanium glass */

/obj/item/stack/sheet/plastitaniumglass
	name = "plastitanium glass"
	desc = "A glass sheet made out of a plasma-titanium-silicate alloy."
	singular_name = "plastitanium glass sheet"
	icon_state = "sheet-plastitaniumglass"
	item_state = "sheet-plastitaniumglass"
	mats_per_unit = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/plasma=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100, STAMINA = 0)
	resistance_flags = ACID_PROOF
	material_flags = NONE
	merge_type = /obj/item/stack/sheet/plastitaniumglass

/obj/item/stack/sheet/plastitaniumglass/get_main_recipes()
	. = ..()
	. += GLOB.plastitaniumglass_recipes

/*SHARDS FROM HERE ONWARD, NOT A STACK, MOVE IT AS THE PROPHECY FORETOLD*/
/obj/item/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	custom_materials = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 100,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100, STAMINA = 0)
	max_integrity = 40
	sharpness = IS_SHARP
	var/icon_prefix
	embedding = list("embed_chance" = 65)


/obj/item/shard/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shard of glass! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS


/obj/item/shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, force)
	AddComponent(/datum/component/butchering, 150, 65)
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)
	if (icon_prefix)
		icon_state = "[icon_prefix][icon_state]"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/shard/afterattack(atom/A as mob|obj, mob/user, proximity)
	. = ..()
	if(!proximity || !(src in user))
		return
	if(isturf(A))
		return
	if(istype(A, /obj/item/storage))
		return
	var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !HAS_TRAIT(H, TRAIT_PIERCEIMMUNE)) // golems, etc
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			H.apply_damage(force*0.5, BRUTE, hit_hand)
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		if(!HAS_TRAIT(M, TRAIT_PIERCEIMMUNE))
			to_chat(M, "<span class='warning'>[src] cuts into your hand!</span>")
			M.apply_damage(force*0.5, BRUTE, hit_hand)


/obj/item/shard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/lightreplacer))
		I.attackby(src, user)
	else
		return ..()

/obj/item/shard/welder_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 0, volume=50))
		var/obj/item/stack/sheet/glass/NG = new (user.loc)
		for(var/obj/item/stack/sheet/glass/G in user.loc)
			if(G == NG)
				continue
			if(G.amount >= G.max_amount)
				continue
			G.attackby(NG, user)
		to_chat(user, "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>")
		qdel(src)
	return TRUE

/obj/item/shard/proc/on_entered(datum/source, mob/living/L)
	SIGNAL_HANDLER

	if(istype(L) && has_gravity(loc))
		if(HAS_TRAIT(L, TRAIT_LIGHT_STEP))
			playsound(loc, 'sound/effects/glass_step.ogg', 30, 1)
		else
			playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)

/obj/item/shard/plasma
	name = "purple shard"
	desc = "A nasty looking shard of plasma glass."
	force = 6
	throwforce = 11
	icon_state = "plasmalarge"
	custom_materials = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plasma"
