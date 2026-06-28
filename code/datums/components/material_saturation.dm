///	Allows atoms to undergo "Saturation" with a reagent.
///	Drying/wetting of materials will change properties over time, eg, concrete walls drying to become stronger, or steel structures rusting out when exposed to a reagent.
/*
/datum/component/material_saturation
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///	How saturated it currently is.
	var/saturation
	///	Holds what stage of how "dry" or "wet" the atom is. 0 is dry, 5 is normal, 10 is saturated with a reagent.
	var/saturation_level = 5
	///	These two decide what direction in the saturation_level it can progresses.
	var/can_be_dried = TRUE
	var/can_be_wetted = TRUE
	///	Is the atom being dried/wetted reversable, or will it stay at its current saturation level until it reaches its max?
	var/reversable = TRUE
	///	The reagent that is used to wet the atom.
	var/wetting_reagent = /datum/reagent/water

/// DRYING STUFF
	///	Atom is currently not being wetted and is "drying".
	var/is_drying = TRUE
	/// How much this atom being wetted contributes to the "dry" side of the saturation level
	var/drying_level = 0.5
	/// If the atom dries to a new atom, or if it just changes color/properties.
	var/dry_type = FALSE
	/// The color the atom will slowly change to when fully dried.
	var/dried_color = "#FFFFFF"
	/// The new icon the atom will change to if fully dried.
	var/dried_icon_state
	/// The new atom the atom will change to when fully dry.
	var/dried_atom

///	WET STUFF
	///	Atom is currently being wetted with a reagent and is becoming "saturated".
	var/is_wetted = TRUE
	/// How much this atom being wetted contributes to its "wetness" level
	var/wetting_level = 0.5
	/// If the atom turns into a new atom when it becomes fully saturated, or if it just changes color/properties.
	var/wetting_type = FALSE
	/// The color the atom will slowly change to when fully saturated with a reagent.
	var/wetting_color = "#000000"
	/// The new icon the atom will change to if fully saturated in a reagent.
	var/wetted_icon_state
	/// The new atom the atom will change to when fully saturated with a reagent.
	var/wetted_atom

/datum/component/material_saturation/Initialize(saturation, wetting_reagent, drying_level, wetting_level, dry_type, wetting_type, dried_color, wetting_color, dried_icon_state, wetted_icon_state, dried_atom, wetted_atom)
	src.saturation = saturation
	src.wetting_reagent = wetting_reagent
	src.drying_level = drying_level
	src.wetting_level = wetting_level
	src.dry_type = dry_type
	src.wetting_type = wetting_type
	src.dried_color = dried_color
	src.wetting_color = wetting_color
	src.dried_icon_state = dried_icon_state
	src.wetted_icon_state = wetted_icon_state
	src.dried_atom = dried_atom
	src.wetted_atom = wetted_atom

/datum/component/material_saturation/proc/is_wetted()

	return parent.is_wetted

/datum/component/material_saturation/wetted


/datum/component/material_saturation/proc/update_saturation_level()
	if (parent.is_wetted = TRUE)
		saturation = wetting_level * 10 + 5
	if (parent.is_drying = TRUE)
		saturation = 5 - drying_level * 10
	switch(saturation)
		if(0)
			saturation_level = 0
		if(1)
			saturation_level = 1
		if(2)
			saturation_level = 2
		if(3)
			saturation_level = 3
		if(4)
			saturation_level = 4
		if(5)
			saturation_level = 5
		if(6)
			saturation_level = 6
		if(7)
			saturation_level = 7
		if(8)
			saturation_level = 8
		if(9)
			saturation_level = 9
		if(10)
			saturation_level = 10

/datum/component/material_saturation/process(delta_time)
	if(is_drying && can_be_dried)
		saturation -= drying_level * delta_time
	if(is_wetted && can_be_wetted)
		saturation += wetting_level * delta_time
	update_saturation_level()
*/
