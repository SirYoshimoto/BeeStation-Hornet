/*
MOLDS FOR MATERIAL CASTING STUFF!

*/
/**********************
Brick molds can make bricks or slabs of these substances:
	- Clay (cold form)
	- Concrete (cold form)
	- Gold (hotform)
	- Iron (hotform)
Brick molds are also able to make "clothes" of these materials:
	- Concrete (cold form)
	-
	-
	-
**********************/

#define HOT_FORM // For molds that can handle high heat and for materials that need to be hotformed (Molten metals) if FALSE; the mold can not handle hot materials, only room temperature materials or it will burn.

/obj/structure/brick_mold
	name = "brick mold"
	desc = "A wooden brick mold for filling with materials to make bricks. There are also attachment points to buckle someone to it."
	icon = 'icons/obj/structures.dmi'
	icon_state = "wood_mold"
	can_buckle = TRUE
	buckle_lying = TRUE
	move_resist = MOVE_FORCE_WEAK
	layer = OBJ_LAYER
	var/form_type = FALSE
	var/input_materials = list()
	var/output_materials = list()

/*
/obj/structure/brick_mold/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")
	if(!has_buckled_mobs())
		. += span_notice("Drag your sprite to sit in it.")

/obj/structure/brick_mold/attacked_by(mob/living/user)
	. = ..()
	var/mob/living/user = U
	if(U.)

*/
/obj/structure/brick_mold/attackby(obj/item/W, mob/user, params)
	if(is_concrete(W))
		var/obj/item/stack/ST = W
		if (ST.get_amount() < 4)
			to_chat(user, span_warning("You need at least 4 concrete bags for that!"))
			return
		to_chat(user, span_notice("You pour the concrete into the mold and watch as it hardens!"))
		playsound(W.loc, 'sound/effects/shovel_dig.ogg', rand(10,50), TRUE)
		sleep(3)
		to_chat(user, span_notice("A concrete slab pops out of the mold!"))
		spawn_atom_to_turf(/obj/item/stack/sheet/conc_sheet, src, 4, FALSE)
		playsound(W.loc, 'sound/effects/cartoon_pop.ogg', rand(10,50), TRUE)
		ST.use(4)
		return

/obj/structure/brick_mold/deconstruct(disassembled = TRUE)
	if(!has_buckled_mobs())
		new /obj/item/stack/sheet/wood(drop_location(), 10)
		qdel(src)
		..()
/*	else
		. = ..()
		. += span_notice("Make sure nothing is buckled to the mold first!.")*/
	return

