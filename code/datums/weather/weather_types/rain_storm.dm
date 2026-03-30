/datum/weather/rain_storm
	/*Essentially a clone of ash storms, but it's a harmless weather that just wettens and mildly impairs vision of most species.
	Also for aesthetic combat scenes in the forest.
	Will most likely straight up murder Oozelings and slimes, however*/

	name = "rain_storm"
	desc = "A light shower of rain. Fine for most species, acid rain for Oozlings"

	telegraph_message = span_warning("Clouds begin to gather in the sky.")
	telegraph_duration = 300
	telegraph_overlay = "cloud_cover"
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = span_userdanger("<i>Water spits down from the clouds! It is raining!</i>")
	weather_overlay = "light_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 300
	end_message = span_boldannounce("The rain softens to a halt, the clouds receed, and the smell of petrichor fills the air.")
	end_overlay = "cloud_cover"
	end_sound = 'sound/ambience/acidrain_end.ogg'

	///Made for Vulkan, echo is a placeholder in this case
	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_RAINSTORM

	immunity_type = TRAIT_RAINSTORM_IMMUNE

	barometer_predictable = TRUE

	probability = 10


/datum/weather/rain_storm/weather_act_mob(mob/living/L)
	//L.mood_event(/datum/mood_event/wet)
	L.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))

