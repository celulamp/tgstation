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
	maxHealth = 75
	health = 25 
	harm_intent_damage = 8
	obj_damage = 54
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
	var/obj/item/kirbyplants/plantdisguise = null 
	loot = list(/obj/item/clothing/head/gnome)	

/mob/living/simple_animal/hostile/gnome/Initialize(mapload)
	..()
	AddComponent(/datum/component/swarming)
	update_icon()

/mob/living/simple_animal/hostile/gnome/Destroy()
	gib_animation()
	..()	

/mob/living/simple_animal/hostile/gnome/update_overlays()
	. = ..()
	var/mutable_appearance/hat_overlay = mutable_appearance('icons/mob/gnome.dmi', "hat")
	hat_overlay.color = pick("red","blue","green","yellow","gray","purple","orange")
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
	if(!plantdisguise && DT_PROB(30, delta_time))
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
	..()

/mob/living/simple_animal/hostile/gnome/proc/consume_bait()
	for(var/obj/potential_consumption in view(1, src))
		if(istype(potential_consumption, /obj/item/food/grown/harebell))
			qdel(potential_consumption)
			visible_message(span_notice("[src] gobbles down [potential_consumption]."))		

/obj/item/clothing/head/gnome
	name = "Gnome Hat"
	desc = "Hat of the fallen child."
	icon_state = "gnome_hat"			

/mob/living/simple_animal/hostile/gnome/icenome
	name = "Icnome"
	desc = "A gnome trapped inside a ice cube."
	icon_state = "icnome"
	icon_living = "icnome"
	speed = 0	
	var/temperature = -50

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

