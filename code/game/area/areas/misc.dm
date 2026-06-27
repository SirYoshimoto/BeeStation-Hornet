// Areas that don't fit any of the other files, or only serve one purpose.

/area/misc/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE
	has_starlight_overlay = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA | NO_GRAVITY
	outdoors = TRUE
	ambience_index = null
	ambient_music_index = AMBIENCE_SPACE
	ambient_buzz = null //Space is deafeningly quiet
	sound_environment = SOUND_AREA_SPACE
	default_gravity = ZERO_GRAVITY
	flags_1 = CAN_BE_DIRTY_1

/area/misc/space/nearstation
	icon_state = "space_near"
	static_lighting = TRUE

/area/misc/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	default_gravity = STANDARD_GRAVITY
	ambience_index = null
	ambient_buzz = null

/area/misc/testroom
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "test_room"


//OUTDOOR DEPARTMENT AREAS FOR PLANETS
/area/outdoor
	outdoors = TRUE
	static_lighting = TRUE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
// engi/atmos
/area/outdoor/atmosoutside
	name = "Atmosphereics Outside"
	icon_state = "atmos_outside"

// security
/area/outdoor/prisonyard
	name = "Prison Yard"
	icon_state = "sec_prison_yard"

/area/outdoor/trainingyard
	name = "Training Yard"
	icon_state = "trainyard"

// cargo
/area/outdoor/cargo_bay
	name = "Outdoor Cargo Bay"
	icon_state = "cargo_bay_outside"

// science
/area/outdoor/xenooutside
	name = "Xenobiology Outdoor Cells"
	icon_state = "xeno_outside"

// service
/area/outdoor/farm
	name = "Farm"
	icon_state = "farm"
