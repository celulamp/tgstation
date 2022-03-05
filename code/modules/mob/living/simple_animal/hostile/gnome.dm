/mob/living/simple_animal/hostile/gnome
	name = "Gnome"
	desc = "A living automaton with the appearance of a lawn gnome."
	del_on_death = TRUE
	icon = 'icons/mob/gnome.dmi'
	icon_state = "gnome"
	icon_living = "gnome"
	icon_gib = "gnome_death"
	aggro_vision_range = 13
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 2
	turns_per_move = 5
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	robust_searching = 1
	search_objects = 1
	wanted_objects = list(/obj/item/food/grown/harebell)		
	emote_taunt = list("growls")
	taunt_chance = 20
	speed = 1
	health = 45
	maxHealth = 45
	harm_intent_damage = 8
	obj_damage = 48
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/creatures/gnomechomp.wav'
	deathsound = 'sound/creatures/gnomedeath.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("growls")
	//Space gnomes aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("gnome")
	pass_flags = PASSTABLE		
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/item/clothing/head/gnome)	
	var/obj/item/kirbyplants/plantdisguise = null 
	var/hatcolor
	var/has_drip = TRUE	
	var/can_disguise = TRUE

/mob/living/simple_animal/hostile/gnome/Initialize(mapload)
	..()
	AddComponent(/datum/component/swarming)
	hatcolor = pick("red","blue","green","yellow","gray","purple","orange")	
	update_icon()

/mob/living/simple_animal/hostile/gnome/Destroy()
	gib_animation()
	..()	

/mob/living/simple_animal/hostile/gnome/update_overlays()
	. = ..()
	if(!has_drip)
		return
	else
		var/mutable_appearance/hat_overlay = mutable_appearance('icons/mob/gnome.dmi', "hat")
		hat_overlay.color = hatcolor
		. += hat_overlay
	if(plantdisguise)
		var/mutable_appearance/plant_overlay = mutable_appearance(plantdisguise.icon, plantdisguise.icon_state)
		. += plant_overlay
		
/mob/living/simple_animal/hostile/gnome/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(DT_PROB(5, delta_time))
		playsound(src, 'sound/creatures/gnomechuckle.wav', 50, TRUE)
	if(can_disguise && !plantdisguise && DT_PROB(30, delta_time))
		var/obj/item/kirbyplants/plant = locate() in range(src,2)	
		if (plant)
			plantdisguise = plant
			plant.loc = src
			update_icon() 		 
	if(stat == CONSCIOUS)
		consume_bait()		

/mob/living/simple_animal/hostile/gnome/Aggro()
	. = ..()
	if(plantdisguise)
		plantdisguise.loc = loc
		plantdisguise = null
		update_icon()

/mob/living/simple_animal/hostile/gnome/death()
	GLOB.gnome_kills++
	message_admins("Gnome death increased")
	if(plantdisguise)
		plantdisguise.loc = loc
		plantdisguise = null
	gribelspawn()	
	..()

/mob/living/simple_animal/hostile/gnome/proc/consume_bait()
	for(var/obj/potential_consumption in view(1, src))
		if(istype(potential_consumption, /obj/item/food/grown/harebell))
			qdel(potential_consumption)
			visible_message(span_notice("[src] gobbles down [potential_consumption]."))		

/mob/living/simple_animal/hostile/gnome/proc/gribelspawn()
	message_admins("Gribel arrives.")
	if(!GLOB.gribelspawned)
		if(GLOB.gnome_kills >= 25)
			if(!GLOB.xeno_spawn.len)
				message_admins("No valid spawn locations found, aborting...")
				return MAP_ERROR
			var/mob/living/simple_animal/hostile/gribel/theGribel = new /mob/living/simple_animal/hostile/gribel(pick(GLOB.xeno_spawn))
			GLOB.gribelspawned = TRUE
			message_admins("Gribel can not be respawned")
/obj/item/clothing/head/gnome
	name = "Gnome Hat"
	desc = "Hat of the fallen child."
	icon_state = "gnome_hat"			

/mob/living/simple_animal/hostile/gnome/icnome
	name = "Icnome"
	desc = "If he's trapped in there and we're out here then what I wanna know is.."
	icon_state = "icnome"
	icon_living = "icnome"
	speed = 2
	var/temperature = -5
	loot = list()
	has_drip = FALSE
	can_disguise = FALSE	

/mob/living/simple_animal/hostile/gnome/icnome/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/hit_mob = target
		var/thermal_protection = 1 - hit_mob.get_insulation_protection(hit_mob.bodytemperature + src.temperature)

		// The new body temperature is adjusted by the bullet's effect temperature
		// Reduce the amount of the effect temperature change based on the amount of insulation the mob is wearing
		hit_mob.adjust_bodytemperature((thermal_protection * src.temperature) + src.temperature)

	else if(isliving(target))
		var/mob/living/L = target
		// the new body temperature is adjusted by the bullet's effect temperature
		L.adjust_bodytemperature(temperature)

/mob/living/simple_animal/hostile/gnome/icnome/death()
	var/turf/turf = get_turf(src)
	if(isopenturf(turf))
		var/turf/open/O = turf
		O.freeze_turf()
		..()

/mob/living/simple_animal/hostile/gnome/sternome
	name = "Sternome"
	desc = "Assistants captured and fed maintence drugs to this beast."	
	icon_state = "sternome"
	icon_living = "sternome"
	icon_dead = "sternome_dead"
	del_on_death = FALSE	
	speed = 7
	health = 390
	maxHealth = 390
	loot = list()
	has_drip = FALSE
	can_disguise = FALSE	
	harm_intent_damage = 12
	obj_damage = 59
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "pulverizes"
	attack_verb_simple = "pulverizes"	
	attack_vis_effect = ATTACK_EFFECT_SLASH
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/creatures/sternomeattack.ogg'
	deathsound = 'sound/creatures/sternomedeath.ogg'	

/mob/living/simple_animal/hostile/gnome/sternome/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		var/atom/throw_target = get_edge_target_turf(L, dir)
		L.throw_at(throw_target, rand(1,2), 7, src)		

/mob/living/simple_animal/hostile/gribel
	name = "Gribel"
	desc = "His eyes follow your every move."
	icon_state = "gribel"
	icon_living = "gribel"
	health = 3500
	maxHealth = 3500
	attack_verb_continuous = "degrades"
	attack_verb_simple = "degrades"
	attack_sound = 'sound/creatures/gribelattack.mp3'
	deathsound = 'sound/creatures/gribeldeath.mp3'
	speak_emote = list("cries")
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	armour_penetration = 46
	melee_damage_lower = 32
	melee_damage_upper = 32
	speed = 12
	move_to_delay = 7
	del_on_death = TRUE
	loot = list(/obj/structure/closet/crate/necropolis/tendril)
	deathmessage = "sacrifices himself for all of the gnomes."
	var/has_drip = FALSE
	icon = 'icons/mob/gribel.dmi'
	aggro_vision_range = 21
	faction = list("gnome")
	health_doll_icon = "gribel"
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 96
	maptext_width = 96
	pressure_resistance = 200
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/mob/living/simple_animal/hostile/gribel/AttackingTarget()
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon = target
		if(!istype(carbon.head, /obj/item/clothing/head/helmet))
			carbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 60)
			to_chat(carbon, span_danger("You feel dumber."))
		if(prob(28))
			carbon.gain_trauma(/datum/brain_trauma/special/gnomosis)

/mob/living/simple_animal/hostile/gribel/death()
	GLOB.gribelalive = FALSE
	..()
