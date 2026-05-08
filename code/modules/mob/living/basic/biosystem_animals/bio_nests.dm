/* Spawners and homes for biosystem animals.
They spawn a few when first initialized and then no longer spawn,
Only serving as a nest for the animals to lay eggs/give birth.*/

/mob/living/basic/biosystem_animals/bio_nest
	name = "bio nest"
	desc = "A nest for biosystem animals to lay eggs or give birth in."
	icon = 'icons/mob/biosystem/biosystem_animals.dmi'
	icon_state = "nest"
	density = FALSE

/mob/living/basic/biosystem_animals/bio_nest/Initialize()
	. = ..()
	apply_status_effect(/datum/status_effect/bio_nest)
