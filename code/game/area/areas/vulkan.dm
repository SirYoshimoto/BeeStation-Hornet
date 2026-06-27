// AREAS FOR VULKAN.
// Also includes outdoor department areas
/area/vulkan
	name = "vulkan"
	icon = 'icons/area/areas_vulkan.dmi'
	icon_state = "vulkan"
	outdoors = TRUE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	has_starlight_overlay = TRUE

/area/vulkan/field
	name = "vulkan field"
	icon_state = "vulkfield"
	//ambientsounds = list('sound/ambience/ambivulk1.ogg')
	sound_environment = null
	area_flags = VALID_TERRITORY | FLORA_ALLOWED | UNIQUE_AREA | HIDDEN_STASH_LOCATION
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/vulkan/field/forest
	name = "vulkan forest"
	icon_state = "vulkforest"
	//ambientsounds = list('sound/ambience/ambivulkforest.ogg')
	map_generator = /datum/map_generator/jungle_generator

/area/vulkan/field/water
	name = "vulkan water"
	icon_state = "vulkwater"
	ambientsounds = list('sound/ambience/shore.ogg')
	mood_bonus = 1
	mood_message = span_warning("The waves sound nice.\n")

// actual volcano areas
/area/vulkan/field/volcano
	name = "vulkan volcano"
	icon_state = "vulkano"
	//ambientsounds = list('sound/ambience/ambivulk4.ogg')

/area/vulkan/field/hotsprings
	name = "vulkan hotsprings"
	icon_state = "vulkano"

/area/vulkan/hotspring_room
	name = "vulkan hotspring room"
	icon_state = "vulkano"
	outdoors = FALSE

// SUBWAY HALLS
/area/subway
	icon_state = "subhall"
	sound_environment = SOUND_AREA_STANDARD_STATION
	lights_always_start_on = TRUE
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
/*
/area/subway/engineering
	name = "Engineering Subway"
	icon_state = "hall_engineering"

/area/subway/security
	name = "Security Subway"
	icon_state = "hall_security"

/area/subway/science
	name = "Science Subway"
	icon_state = "hall_science"
*/
