/mob/living/carbon/human/gib()
	if(team == CHUNGUS_TEAM)
		chungus_tickets--
	if(team == NOOB_TEAM)
		noob_tickets--
	for(var/obj/item/organ/I in internal_organs)
		I.removed()
		if(istype(loc,/turf))
			I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),30)

	for(var/obj/item/organ/external/E in src.organs)
		E.droplimb(0,DROPLIMB_EDGE,1)

	sleep(1)

	for(var/obj/item/I in src)
		drop_from_inventory(I)
		I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)), rand(1,3), round(30/I.w_class))

	..(species.gibbed_anim)
	gibs(loc, dna, null, species.get_flesh_colour(src), species.get_blood_colour(src))

/mob/living/carbon/human/dust()
	if(species)
		..(species.dusted_anim, species.remains_type)
	else
		..()

/mob/living/carbon/human/death(gibbed,deathmessage="seizes up and falls limp...", show_dead_message = "You have died.")

	if(stat == DEAD) return

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)


	//Handle species-specific deaths.
	species.handle_death(src)





	callHook("death", list(src, gibbed))

	if(ticker && ticker.mode)
		sql_report_death(src)
		ticker.mode.check_win()

	if(wearing_rig)
		wearing_rig.notify_ai("<span class='danger'>Warning: user death event. Mobility control passed to integrated intelligence system.</span>")

	. = ..(gibbed,"no message")
	if(!gibbed)
		handle_organs()
		if(species.death_sound)
			playsound(loc, species.death_sound, 80, 1, 1)
		spawn(50)
			if(bowels >= 30)
				handle_shit()
			if(bladder >= 30)
				handle_piss()
	handle_hud_list()
	death_timer = 30
	stop_death = 0
	reviveable_sequence()
/mob/living/carbon/human/proc/reviveable_sequence()
	while(death_timer > 0)
		if(stop_death)
			return
		death_timer--
		sleep(10)
	ghost()






/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(HUSK)
	for(var/obj/item/organ/external/E in organs)
		E.disfigured = 1
	update_body(1)
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= HUSK
	return

/mob/living/carbon/human/proc/ChangeToSkeleton()
	if(SKELETON in src.mutations)	return

	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(SKELETON)
	for(var/obj/item/organ/external/E in organs)
		E.disfigured = 1
	update_body(1)
	return
