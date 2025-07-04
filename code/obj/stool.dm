// CONTENTS:
// - Stools
// - Benches
// - Beds
// - Chairs
// - Syndicate Chairs (will trip you up)
// - Folded Chairs
// - Comfy Chairs
// - Shuttle Chairs
// - Wheelchairs
// - Wooden Chairs
// - Pews
// - Office Chairs
// - Electric Chairs

/* ================================================ */
/* -------------------- Stools -------------------- */
/* ================================================ */

/obj/stool
	name = "stool"
	desc = "A four-legged padded stool for crewmembers to relax on."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool"
	flags = FLUID_SUBMERGE
	throwforce = 10
	pressure_resistance = 3*ONE_ATMOSPHERE
	layer = STORAGE_LAYER //dumb
	default_material = "steel"
	uses_default_material_appearance = FALSE
	var/allow_unbuckle = 1
	var/mob/living/buckled_guy = null
	var/deconstructable = 1
	var/securable = 0
	var/list/scoot_sounds = null
	var/parts_type = /obj/item/furniture_parts/stool
	material_amt = 0.1

	New()
		START_TRACKING
		if (!src.anchored && src.securable) // we're able to toggle between being secured to the floor or not, and we started unsecured
			src.p_class = 2 // so make us easy to move
		..()

	ex_act(severity)
		switch(severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return
			if (3)
				if (prob(5))
					if (src.deconstructable)
						src.deconstruct()
					else
						qdel(src)
					return

	blob_act(var/power)
		if (prob(power * 2.5))
			var/obj/item/I = new /obj/item/raw_material/scrap_metal
			I.set_loc(get_turf(src))

			if (src.material)
				I.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				I.setMaterial(M)
			qdel(src)

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && src.deconstructable)
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (isscrewingtool(W) && src.securable)
			src.toggle_secure(user)
			return
		else if (istype(W, /obj/item/cloth/towel))
			user.visible_message(SPAN_NOTICE("[user] wipes down [src] with [W]."))
		else
			return ..()

	proc/can_buckle(var/mob/living/to_buckle, var/mob/user)
		if (!istype(to_buckle) || isintangible(to_buckle) || isflockmob(to_buckle)) //no buckling AI-eyes
			return FALSE
		if (!ticker)
			boutput(user, "You can't buckle anyone in before the game starts.")
			return FALSE
		if (to_buckle.buckled)
			boutput(user, "[capitalize(hes_or_shes(to_buckle))] already buckled into something!", "red")
			return FALSE
		if (BOUNDS_DIST(src, user) > 0 || to_buckle.loc != src.loc || user.restrained() || is_incapacitated(user) || !isalive(user))
			return FALSE
		if (user.hasStatus("knockdown"))
			return FALSE
		if (src.buckled_guy && src.buckled_guy.buckled == src && to_buckle != src.buckled_guy)
			user.show_text("There's already someone buckled in [src]!", "red")
			return FALSE
		return TRUE

	proc/buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0) //Handles the actual buckling in
		if (!can_buckle(to_buckle,user))
			return FALSE

		if (to_buckle.pulling == src)
			to_buckle.remove_pulling()

		if (to_buckle == user)
			user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> buckles in!"), SPAN_NOTICE("You buckle yourself in."))
		else
			user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> is buckled in by [user]."), SPAN_NOTICE("You buckle in [to_buckle]."))

		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		return TRUE

	proc/unbuckle() //Ditto but for unbuckling
		if (src.buckled_guy)
			src.buckled_guy.end_chair_flip_targeting()

	proc/toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the castors of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	proc/deconstruct()
		if (!src.deconstructable)
			return
		unbuckle()
		if (ispath(src.parts_type))
			var/obj/item/furniture_parts/P = new src.parts_type(src.loc)
			if (P && src.material)
				P.setMaterial(src.material)
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			var/obj/item/sheet/S = new (src.loc)
			if (src.material)
				S.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				S.setMaterial(M)
		qdel(src)
		return

	Move(atom/target)
		. = ..()
		if (. && islist(scoot_sounds) && scoot_sounds.len && prob(75))
			playsound( get_turf(src), pick( scoot_sounds ), 50, 1 )

/obj/stool/pet_bed
	name = "pet bed"
	icon_state = "petbed"
	desc = "A soft bed designed for small animals to snuggle up in."
	parts_type = /obj/item/furniture_parts/stool/pet_bed

/obj/stool/pet_bed/jones
	name = "cat bed"
	desc = "Though it was made to suit him, Jones still seems to sleep in every spot that is NOT this little bed."

/obj/stool/bee_bed
	// idk. Not a bed proper since humans can't lay in it. Weirdos.
	// would also be cool to make these work with bees.
	// it's hip to tuck bees!
	name = "bee bed"
	icon_state = "beebed"
	desc = "A soft little bed the general size and shape of a space bee."
	parts_type = /obj/item/furniture_parts/stool/bee_bed

/obj/stool/bee_bed/heisenbee
	name = "heisenbed"

/obj/stool/bee_bed/double // Prefab variant
	name = "double bee bed"
	icon_state = "beebed_double"
	desc = "A bee bed shaped to accomodate two sleeping bees while also gently smushing them together, creating one of the most adorable sights in the universe."
	parts_type = /obj/item/furniture_parts/stool/bee_bed/double

/obj/stool/bar
	name = "bar stool"
	icon_state = "bar-stool"
	desc = "Like a stool, but in a bar."
	parts_type = /obj/item/furniture_parts/stool/bar

/obj/stool/neon
	name = "neon bar stool"
	icon_state = "neonstool"
	desc = "Like a bar stool, but in electric blue."
	parts_type = /obj/item/furniture_parts/stool/neon

TYPEINFO(/obj/stool/wooden)
	mat_appearances_to_ignore = list("wood")
/obj/stool/wooden
	name = "wooden stool"
	icon_state = "wstool"
	default_material = "wood"
	desc = "Like a stool, but just made out of wood."
	parts_type = /obj/item/furniture_parts/woodenstool

	constructed //no "wood wood stool"
		name = "stool"

/obj/stool/sleek
	name = "sleek bar stool"
	icon_state = "sleek_stool"
	desc = "Like a bar stool, but sleek and stylish."
	parts_type = /obj/item/furniture_parts/stool/sleek

/* ================================================= */
/* -------------------- Benches -------------------- */
/* ================================================= */

/obj/stool/bench
	name = "bench"
	desc = "It's a bench! You can sit on it!"
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "0"
	anchored = ANCHORED
	var/auto = 0
	var/auto_path = null
	parts_type = /obj/item/furniture_parts/bench

	New()
		..()
		SPAWN(0)
			if (src.auto && ispath(src.auto_path))
				src.set_up(1)

	proc/set_up(var/setup_others = 0)
		if (!src.auto || !ispath(src.auto_path))
			return
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (locate(src.auto_path) in T)
				dirs |= dir
		icon_state = num2text(dirs)
		if (setup_others)
			for (var/obj/stool/bench/B in orange(1,src))
				if (istype(B, src.auto_path))
					B.set_up()

	deconstruct()
		if (!src.deconstructable)
			return
		var/oldloc = src.loc
		..()
		for (var/obj/stool/bench/B in orange(1,oldloc))
			if (B.auto)
				B.set_up()
		return

/obj/stool/bench/auto
	auto = 1
	auto_path = /obj/stool/bench/auto

/* ---------- Red ---------- */

/obj/stool/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	parts_type = /obj/item/furniture_parts/bench/red

/obj/stool/bench/red/auto
	auto = 1
	auto_path = /obj/stool/bench/red/auto

/* ---------- Blue ---------- */

/obj/stool/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	parts_type = /obj/item/furniture_parts/bench/blue

/obj/stool/bench/blue/auto
	auto = 1
	auto_path = /obj/stool/bench/blue/auto

/* ---------- Green ---------- */

/obj/stool/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	parts_type = /obj/item/furniture_parts/bench/green

/obj/stool/bench/green/auto
	auto = 1
	auto_path = /obj/stool/bench/green/auto

/* ---------- Yellow ---------- */

/obj/stool/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	parts_type = /obj/item/furniture_parts/bench/yellow

/obj/stool/bench/yellow/auto
	auto = 1
	auto_path = /obj/stool/bench/yellow/auto

/* ---------- Purple ---------- */

/obj/stool/bench/purple
	icon = 'icons/obj/furniture/bench_purple.dmi'
	parts_type = /obj/item/furniture_parts/bench/purple

/obj/stool/bench/purple/auto
	auto = 1
	auto_path = /obj/stool/bench/purple/auto

/* ---------- Wooden ---------- */

/obj/stool/bench/wooden
	icon = 'icons/obj/furniture/bench_wood.dmi'
	parts_type = /obj/item/furniture_parts/bench/wooden

/obj/stool/bench/wooden/auto
	auto = 1
	auto_path = /obj/stool/bench/wooden/auto

/* ---------- Sauna ---------- */

/obj/stool/bench/sauna
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "saunabench"

/* ============================================== */
/* -------------------- beds -------------------- */
/* ============================================== */

/obj/stool/bed
	name = "bed"
	desc = "A solid metal frame with some padding on it, useful for sleeping on."
	icon_state = "bed"
	anchored = ANCHORED
	var/security = 0
	var/obj/item/clothing/suit/bedsheet/sheet = null
	parts_type = /obj/item/furniture_parts/bed
	material_amt = 0.2

	brig
		name = "brig cell bed"
		desc = "It doesn't look very comfortable. Fortunately there's no way to be buckled to it."
		security = 1
		parts_type = null

	moveable
		name = "roller bed"
		desc = "A solid metal frame with some padding on it, useful for sleeping on. This one has little wheels on it, neat!"
		anchored = UNANCHORED
		securable = 1
		icon_state = "rollerbed"
		parts_type = /obj/item/furniture_parts/bed/roller
		scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	New()
		..()
		START_TRACKING

	Move()
		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()
		. = ..()
		if (. && src.buckled_guy)
			var/mob/living/carbon/C = src.buckled_guy
			C.buckled = null
			C.Move(src.loc)
			C.buckled = src

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/suit/bedsheet))
			src.tuck_sheet(W, user)
			return
		if (iswrenchingtool(W) && !src.deconstructable)
			boutput(user, SPAN_ALERT("You briefly ponder how to go about disassembling a featureless slab using a wrench. You quickly give up."))
			return
		else
			return ..()

	attack_hand(mob/user)
		..()
		if (src.sheet)
			src.untuck_sheet(user)
		for (var/mob/M in src.loc)
			src.unbuckle_mob(M, user)
		return

	can_buckle(var/mob/living/C, var/mob/user)
		if (!..())
			return FALSE
		if (src.security)
			user.show_text("There's nothing you can buckle them to!", "red")
			return FALSE
		return TRUE

	proc/unbuckle_mob(var/mob/M as mob, var/mob/user as mob)
		if (M.buckled && !user.restrained() && !is_incapacitated(user))
			if (allow_unbuckle)
				if (M != user)
					user.visible_message(SPAN_NOTICE("<b>[M]</b> is unbuckled by [user]."), SPAN_NOTICE("You unbuckle [M]."))
				else
					user.visible_message(SPAN_NOTICE("<b>[M]</b> unbuckles."), SPAN_NOTICE("You unbuckle."))
				unbuckle()
			else
				user.show_text("Seems like the buckle is firmly locked into place.", "red")

			src.add_fingerprint(user)

	buckle_in(mob/living/to_buckle, mob/living/user)
		if(src.buckled_guy && src.buckled_guy.buckled == src)
			return FALSE
		if (!can_buckle(to_buckle,user))
			return FALSE

		if (to_buckle.pulling == src)
			to_buckle.remove_pulling()


		if (to_buckle == user)
			user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> lies down on [src], fastening the buckles!"), SPAN_NOTICE("You lie down and buckle yourself in."))
		else
			user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> is buckled in by [user]."), SPAN_NOTICE("You buckle in [to_buckle]."))

		to_buckle.lying = 1
		if (src.anchored)
			to_buckle.anchored = ANCHORED
		to_buckle.buckled = src
		src.buckled_guy = to_buckle
		to_buckle.set_loc(src.loc)

		to_buckle.set_clothing_icon_dirty()
		playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)
		to_buckle.setStatus("buckled", duration = INFINITE_STATUS)

		if (istype(ticker?.mode, /datum/game_mode/revolution) && to_buckle.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
			to_buckle.update_canmove()
			SPAWN(1 SECOND) // so no abrupt ending
				ticker.mode.check_win()

		return TRUE

	unbuckle()
		..()
		if(src.buckled_guy && src.buckled_guy.buckled == src)
			reset_anchored(buckled_guy)
			buckled_guy.buckled = null
			buckled_guy.force_laydown_standup()
			src.buckled_guy = null
			playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)

	proc/tuck_sheet(var/obj/item/clothing/suit/bedsheet/newsheet as obj, var/mob/user as mob)
		if (!newsheet || newsheet.cape || (src.sheet == newsheet && newsheet.loc == src.loc)) // if we weren't provided a new bedsheet, the new bedsheet we got is tied into a cape, or the new bedsheet is actually the one we already have and is still in the same place as us...
			return // nevermind

		if (src.sheet && src.sheet.loc != src.loc) // a safety check: do we have a sheet and is it not where we are?
			if (src.sheet.bed && src.sheet.bed == src) // does our sheet have us listed as its bed?
				src.sheet.bed = null // set its bed to null
			src.sheet = null // then set our sheet to null: it's not where we are!

		if (src.sheet && src.sheet != newsheet) // do we have a sheet, and is the new sheet we've been given not our sheet?
			user.show_text("You try to kinda cram [newsheet] into the edges of [src], but there's not enough room with [src.sheet] tucked in already!", "red")
			return // they're crappy beds, okay?  there's not enough space!

		if (!src.sheet && (newsheet.loc == src.loc || user.find_in_hand(newsheet))) // finally, do we have room for the new sheet, and is the sheet where we are or in the hand of the user?
			src.sheet = newsheet // let's get this shit DONE!
			newsheet.bed = src
			user.u_equip(newsheet)
			newsheet.set_loc(src.loc)
			LAZYLISTADDUNIQUE(src.attached_objs, newsheet)

			var/mob/somebody
			if (src.buckled_guy)
				somebody = src.buckled_guy
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message(somebody, SPAN_NOTICE("<b>[user]</b> tucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] into bed."),\
					SPAN_NOTICE("You tuck [somebody == user ? "yourself" : "[somebody]"] into bed."),\
					SPAN_NOTICE("[somebody == user ? "You tuck yourself" : "<b>[user]</b> tucks you"] into bed."))
				newsheet.layer = EFFECTS_LAYER_BASE-1
			else
				user.visible_message(SPAN_NOTICE("<b>[user]</b> tucks [newsheet] into [src]."),\
				SPAN_NOTICE("You tuck [newsheet] into [src]."))

	proc/untuck_sheet(var/mob/user as mob)
		if (!src.sheet) // vOv
			return // there's nothing to do here, everyone go home

		var/obj/item/clothing/suit/bedsheet/oldsheet = src.sheet

		if (user)
			var/mob/somebody
			if (src.buckled_guy)
				somebody = src.buckled_guy
			else
				somebody = locate(/mob/living/carbon) in get_turf(src)
			if (somebody?.lying)
				user.tri_message(somebody, SPAN_NOTICE("<b>[user]</b> untucks [somebody == user ? "[him_or_her(user)]self" : "[somebody]"] from bed."),\
					SPAN_NOTICE("You untuck [somebody == user ? "yourself" : "[somebody]"] from bed."),\
					SPAN_NOTICE("[somebody == user ? "You untuck yourself" : "<b>[user]</b> untucks you"] from bed."))
				oldsheet.layer = initial(oldsheet.layer)
			else
				user.visible_message(SPAN_NOTICE("<b>[user]</b> untucks [oldsheet] from [src]."),\
				SPAN_NOTICE("You untuck [oldsheet] from [src]."))

		if (oldsheet.bed == src) // just in case it's somehow not us
			oldsheet.bed = null
		mutual_detach(src, oldsheet)
		src.sheet = null

	MouseDrop_T(atom/A as mob|obj, mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0 || A.loc != src.loc || user.restrained() || !isalive(user))
			..()
		else if (istype(A, /obj/item/clothing/suit/bedsheet))
			if ((!src.sheet || (src.sheet && src.sheet.loc != src.loc)) && A.loc == src.loc)
				src.tuck_sheet(A, user)
				return
			if (src.sheet && A == src.sheet)
				src.untuck_sheet(user)
				return

		else if (ismob(A))
			src.buckle_in(A, user)
			var/mob/M = A
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/area = get_area(M)
				if (istype(area))
					user.unlock_medal("Leave no man behind!", 1)
			src.add_fingerprint(user)
		else
			return ..()

	disposing()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
				M.lying = 0
				reset_anchored(M)
		if (src.sheet && src.sheet.bed == src)
			src.sheet.bed = null
			src.sheet = null
		STOP_TRACKING
		..()

	proc/sleep_in(var/mob/M)
		if (!ishuman(M))
			return

		var/mob/living/carbon/user = M

		if (isdead(user))
			boutput(user, SPAN_ALERT("Some would say that death is already the big sleep."))
			return

		if ((get_turf(user) != src.loc) || (!user.lying))
			boutput(user, SPAN_ALERT("You must be lying down on [src] to sleep on it."))
			return

		user.setStatus("resting", INFINITE_STATUS)
		user.sleeping = 4
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()

/* ================================================ */
/* -------------------- Chairs -------------------- */
/* ================================================ */
TYPEINFO(/obj/stool/chair)
	mat_appearances_to_ignore = list("steel")

/obj/stool/chair
	name = "chair"
	desc = "A four-legged metal chair, rigid and slightly uncomfortable. Helpful when you don't want to use your legs at the moment."
	HELP_MESSAGE_OVERRIDE("")
	icon_state = "chair"
	var/comfort_value = 3
	var/buckledIn = 0
	var/status = 0
	var/rotatable = 1
	var/foldable = 1
	var/climbable = 1
	var/buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	var/obj/item/clothing/head/butt/has_butt = null // time for mature humour
	var/image/butt_img
	securable = 1
	anchored = ANCHORED
	scoot_sounds = list( 'sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg' )
	parts_type = null
	material_amt = 0.1

	moveable
		anchored = UNANCHORED

	get_help_message(dist, mob/user)
		. = "You can <b>sit</b> on it by standing on the same tile then click dragging yourself to the chair or using the Block hotkey with any intent except <b>Grab</b>. "
		if (src.climbable)
			. += "It will be <b>climbed on</b> if you are using the <b>Grab intent</b>. "
		if (src.foldable)
			. += "It can be <b>folded</b> up to carry by clicking on it. "
		if (src.securable)
			. += "It can be <b>secured to the floor</b> with a screwing tool. "

	New()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		butt_img = image('icons/obj/furniture/chairs.dmi')
		butt_img.layer = OBJ_LAYER + 0.5 //In between OBJ_LAYER and MOB_LAYER
		..()
		return

	Move()
		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()

		. = ..()
		if (.)
			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER

			if (src.buckled_guy)
				var/mob/living/carbon/C = src.buckled_guy
				C.buckled = null
				C.Move(src.loc)
				C.buckled = src

		if(src.buckled_guy?.loc != src.loc)
			src.unbuckle()

	toggle_secure(mob/user as mob)
		if (!src.anchored && istype(get_turf(src), /turf/space))
			if (user)
				user.show_text("What exactly are you gunna secure [src] to?", "red")
			return
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "unscrews [src] from" : "secures [src] to"] the floor.")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W) && has_butt)
			user.put_in_hand_or_drop(has_butt)
			boutput(user, SPAN_NOTICE("You pry [has_butt.name] from [name]."))
			has_butt = null
			UpdateOverlays(null, "chairbutt")
			return
		if (istype(W, /obj/item/clothing/head/butt) && !has_butt)
			has_butt = W
			user.u_equip(has_butt)
			has_butt.set_loc(src)
			boutput(user, SPAN_NOTICE("You place [has_butt.name] on [name]."))
			butt_img.icon_state = "chair_[has_butt.icon_state]"
			UpdateOverlays(butt_img, "chairbutt")
			return
		else
			return ..()

	attack_hand(mob/user)
		if (!isliving(user)) return
		var/mob/living/L = user
		var/mob/living/carbon/human/chair_chump = null
		for (var/mob/living/M in src.loc)

			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.on_chair)
					chair_chump = H

			if (chair_chump)// == 1)
				if (chair_chump == L)
					user.visible_message(SPAN_NOTICE("<b>[chair_chump]</b> steps off [chair_chump.on_chair]."), SPAN_NOTICE("You step off [src]."))
					src.add_fingerprint(user)
					unbuckle()
					return

			if (M.buckled && M != chair_chump)
				if (allow_unbuckle)
					if(user.restrained() || is_incapacitated(user))
						return
					if (M != user)
						user.visible_message(SPAN_NOTICE("<b>[M]</b> is unbuckled by [user]."), SPAN_NOTICE("You unbuckle [M]."))
					else
						user.visible_message(SPAN_NOTICE("<b>[M]</b> unbuckles."), SPAN_NOTICE("You unbuckle."))
					src.add_fingerprint(user)
					unbuckle()
					return
				else
					user.show_text("Seems like the buckle is firmly locked into place.", "red")
					return

		if (src.foldable)
			user.visible_message("<b>[user.name] folds [src].</b>")
			if ((chair_chump) && (chair_chump != user))
				chair_chump.visible_message(SPAN_ALERT("<b>[chair_chump.name] falls off of [src]!</b>"))
				chair_chump.on_chair = null
				chair_chump.pixel_y = 0
				chair_chump.changeStatus("knockdown", 1 SECOND)
				chair_chump.changeStatus("stunned", 2 SECONDS)
				random_brute_damage(chair_chump, 15)
				playsound(chair_chump.loc, "swing_hit", 50, 1)
				chair_chump.end_chair_flip_targeting()

			var/obj/item/chair/folded/C = null
			if(istype(src, /obj/stool/chair/syndicate))
				C = new/obj/item/chair/folded/syndicate(src.loc)
			else
				C = new/obj/item/chair/folded(src.loc)
			if (src.material)
				C.setMaterial(src.material)
			if (src.icon_state)
				C.c_color = src.icon_state
				C.icon_state = "folded_[src.icon_state]"
				C.item_state = C.icon_state

			C.forensic_holder = src.forensic_holder
			qdel(src)
		else
			src.rotate()

		return

	MouseDrop_T(mob/M as mob, mob/user as mob)
		..()
		if (M == user)
			if (user.a_intent == INTENT_GRAB)
				if(climbable)
					buckle_in(M, user, 1)
				else
					boutput(user, SPAN_ALERT("[src] isn't climbable."))
			else
				buckle_in(M,user)
		else
			buckle_in(M,user)
			if (isdead(M) && M != user && emergency_shuttle?.location == SHUTTLE_LOC_STATION) // 1 should be SHUTTLE_LOC_STATION
				var/area/shuttle/escape/station/A = get_area(M)
				if (istype(A))
					user.unlock_medal("Leave no man behind!", 1)
		return

	mouse_drop(atom/over_object as mob|obj)
		if(BOUNDS_DIST(src,usr) == 0)
			src.rotate(get_dir(get_turf(src),get_turf(over_object)))
		..()

	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		if (!can_buckle(to_buckle,user))
			return FALSE

		if (to_buckle.pulling == src)
			to_buckle.remove_pulling()

		if(stand && ishuman(to_buckle))
			if(ON_COOLDOWN(to_buckle, "chair_stand", 1 SECOND))
				return
			user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> climbs up on [src]!"), SPAN_NOTICE("You climb up on [src]."))

			var/mob/living/carbon/human/H = to_buckle
			to_buckle.set_loc(src.loc)
			to_buckle.pixel_y = 10
			if (src.anchored)
				to_buckle.anchored = ANCHORED
			H.on_chair = src
			to_buckle.buckled = src
			src.buckled_guy = to_buckle
			src.buckledIn = 1
			to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
			H.start_chair_flip_targeting()
		else
			if (to_buckle == user)
				user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> buckles in!"), SPAN_NOTICE("You buckle yourself in."))
			else
				user.visible_message(SPAN_NOTICE("<b>[to_buckle]</b> is buckled in by [user]."), SPAN_NOTICE("You buckle in [to_buckle]."))

			if (src.anchored)
				to_buckle.anchored = ANCHORED
			to_buckle.buckled = src
			src.buckled_guy = to_buckle
			to_buckle.set_loc(src.loc)
			src.buckledIn = 1
			to_buckle.setStatus("buckled", duration = INFINITE_STATUS)
		if (has_butt)
			playsound(src, (has_butt.sound_fart ? has_butt.sound_fart : 'sound/voice/farts/fart1.ogg'), 50, 1)
		else
			playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)
		return TRUE


	unbuckle()
		..()
		if(!src.buckled_guy) return

		var/mob/living/M = src.buckled_guy
		var/mob/living/carbon/human/H = src.buckled_guy

		M.end_chair_flip_targeting()

		if (istype(H) && H.on_chair)
			M.pixel_y = 0
			reset_anchored(M)
			M.buckled = null
			buckled_guy.force_laydown_standup()
			SPAWN(0.5 SECONDS)
				H.on_chair = null
				src.buckledIn = 0
		else if ((M.buckled))
			reset_anchored(M)
			M.buckled = null
			buckled_guy.force_laydown_standup()
			SPAWN(0.5 SECONDS)
				src.buckledIn = 0

		src.buckled_guy = null

		playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)

	ex_act(severity)
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return
			if (3)
				if (prob(5))
					qdel(src)
					return
		return

	blob_act(var/power)
		if (prob(power * 2.5))
			for (var/mob/M in src.loc)
				if (M.buckled == src)
					M.buckled = null
					src.buckled_guy = null
			qdel(src)

	disposing()
		unbuckle()
		for (var/mob/M in src.loc)
			if (M.buckled == src)
				M.buckled = null
				src.buckled_guy = null
		if (has_butt)
			has_butt.set_loc(loc)
		has_butt = null
		..()
		return

	Click(location,control,params)
		var/lpm = params2list(params)
		if(istype(usr, /mob/dead/observer) && !lpm["ctrl"] && !lpm["shift"] && !lpm["alt"])
			rotate()

#ifdef HALLOWEEN
			if (istype(usr.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = usr.abilityHolder
				GH.change_points(3)
#endif
		else return ..()

	proc/rotate(var/face_dir = 0)
		if (rotatable)
			if (!face_dir)
				src.set_dir(turn(src.dir, 90))
			else
				src.set_dir(face_dir)

			if (src.dir == NORTH)
				src.layer = FLY_LAYER+1
			else
				src.layer = OBJ_LAYER
			if (buckled_guy)
				var/mob/living/carbon/C = src.buckled_guy
				C.set_dir(dir)
		return

	blue
		icon_state = "chair-b"

	yellow
		icon_state = "chair-y"

	red
		icon_state = "chair-r"

	green
		icon_state = "chair-g"

	purple
		icon_state = "chair-p"

	black
		icon_state = "chair-blk"

/* ========================================================== */
/* -------------------- Syndicate Chairs -------------------- */
/* ========================================================== */

/obj/stool/chair/syndicate
	desc = "That chair is giving off some bad vibes."
	comfort_value = -5

	New()
		..()
		src.AddComponent(/datum/component/proximity)

	EnteredProximity(atom/movable/AM)
		if (isliving(AM) && !isintangible(AM) && prob(40) && !AM.hasStatus("knockdown"))
			src.visible_message(SPAN_ALERT("[src] trips [AM]!"), SPAN_ALERT("You hear someone fall."))
			AM.changeStatus("knockdown", 2 SECONDS)
		return

/* ======================================================= */
/* -------------------- Material Chairs ------------------ */
/* ======================================================= */

/obj/stool/chair/material
	name = "material chair"
	desc = "A chair made from a material"
	uses_default_material_appearance = TRUE
	mat_changename = TRUE

/obj/stool/chair/material/mauxite
	name = "chair"
	icon_state = "chair$$mauxite"
	desc = "A sturdy chair. It doesn't look very comfortable..."
	comfort_value = -2
	default_material = "mauxite"

/* ======================================================= */
/* -------------------- Folded Chairs -------------------- */
/* ======================================================= */

TYPEINFO(/obj/item/chair/folded)
	mat_appearances_to_ignore = list("steel")
/obj/item/chair/folded
	name = "chair"
	desc = "A folded chair. Good for smashing noggin-shaped things."
	HELP_MESSAGE_OVERRIDE("It can be unfolded back into a chair by <b>using it<b> with the C key.")
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "folded_chair"
	item_state = "folded_chair"
	w_class = W_CLASS_BULKY
	throwforce = 10
	flags = TABLEPASS | CONDUCT
	force = 5
	stamina_damage = 45
	stamina_cost = 21
	stamina_crit_chance = 10
	material_amt = 0.1
	hitsound = 'sound/impact_sounds/folding_chair.ogg'
	var/c_color = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	syndicate
		desc = "That chair is giving off some bad vibes."

/obj/item/chair/folded/attack_self(mob/user as mob)
	if(cant_drop == 1)
		boutput(user, "You can't unfold the [src] when its attached to your arm!")
		return
	var/obj/stool/chair/C = null
	if(istype(src, /obj/item/chair/folded/syndicate))
		C = new/obj/stool/chair/syndicate(user.loc)
	else
		C = new/obj/stool/chair(user.loc)
	if (src.material)
		C.setMaterial(src.material)
	if (src.c_color)
		C.icon_state = src.c_color
	C.forensic_holder = src.forensic_holder
	C.set_dir(user.dir)
	ON_COOLDOWN(user, "chair_stand", 1 SECOND)
	boutput(user, "You unfold [C].")
	user.drop_item()
	qdel(src)
	return

/obj/item/chair/folded/attack(atom/target as mob, mob/user as mob, params)
	var/oldcrit = src.stamina_crit_chance
	if(iswrestler(user))
		src.stamina_crit_chance = 100
	..()
	src.stamina_crit_chance = oldcrit

/* ====================================================== */
/* -------------------- Comfy Chairs -------------------- */
/* ====================================================== */

/obj/stool/chair/comfy
	name = "comfy brown chair"
	desc = "This advanced seat commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "chair_comfy"
	comfort_value = 7
	foldable = 0
	deconstructable = 1
//	var/atom/movable/overlay/overl = null
	var/image/arm_image = null
	var/arm_icon_state = "arm"
	parts_type = /obj/item/furniture_parts/comfy_chair

	New()
		..()
		UpdateIcon()
/* what in the unholy mother of god was this about
		src.overl = new /atom/movable/overlay( src.loc )
		src.overl.icon = 'icons/obj/objects.dmi'
		src.overl.icon_state = "arm"
		src.overl.layer = 6// TODO Layer wtf
		src.overl.name = "chair arm"
		src.overl.master = src
		src.overl.set_dir(src.dir)
*/
	rotate()
		set src in oview(1)
		set category = "Local"

		src.set_dir(turn(src.dir, 90))
//		src.overl.set_dir(src.dir)
		src.UpdateIcon()
		if (buckled_guy)
			var/mob/living/carbon/C = src.buckled_guy
			C.set_dir(dir)
		return


	update_icon()

		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	blue
		name = "comfy blue chair"
		icon_state = "chair_comfy-blue"
		arm_icon_state = "arm-blue"
		parts_type = /obj/item/furniture_parts/comfy_chair/blue

	red
		name = "comfy red chair"
		icon_state = "chair_comfy-red"
		arm_icon_state = "arm-red"
		parts_type = /obj/item/furniture_parts/comfy_chair/red

	green
		name = "comfy green chair"
		icon_state = "chair_comfy-green"
		arm_icon_state = "arm-green"
		parts_type = /obj/item/furniture_parts/comfy_chair/green

	yellow
		name = "comfy yellow chair"
		icon_state = "chair_comfy-yellow"
		arm_icon_state = "arm-yellow"
		parts_type = /obj/item/furniture_parts/comfy_chair/yellow

	purple
		name = "comfy purple chair"
		icon_state = "chair_comfy-purple"
		arm_icon_state = "arm-purple"
		parts_type = /obj/item/furniture_parts/comfy_chair/purple

/obj/stool/chair/comfy/throne_gold
	name = "golden throne"
	desc = "This throne commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "thronegold"
	arm_icon_state = "thronegold-arm"
	comfort_value = 7
	anchored = UNANCHORED
	deconstructable = 1
	parts_type = /obj/item/furniture_parts/throne_gold

/obj/stool/chair/comfy/sleek
	name = "sleek chair"
	desc = "This advanced seat commands authority and respect. Everyone is super envious of whoever sits in this chair."
	icon_state = "chair_comfy_sleek"
	arm_icon_state = "arm_sleek"
	comfort_value = 7
	anchored= UNANCHORED
	deconstructable = 1
	parts_type = /obj/item/furniture_parts/sleekchair

/* ======================================================== */
/* -------------------- Shuttle Chairs -------------------- */
/* ======================================================== */

/obj/stool/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "Equipped with a safety buckle and a tray on the back for the person behind you to use!"
	icon_state = "shuttle_chair"
	arm_icon_state = "shuttle_chair-arm"
	comfort_value = 5
	deconstructable = 0
	parts_type = null

	red
		icon_state = "shuttle_chair-red"
	brown
		icon_state = "shuttle_chair-brown"
	green
		icon_state = "shuttle_chair-green"

/obj/stool/chair/comfy/shuttle/pilot
	name = "pilot's seat"
	desc = "Only the most important crew member gets to sit here. Everyone is super envious of whoever sits in this chair."
	icon_state = "shuttle_chair-pilot"
	arm_icon_state = "shuttle_chair-pilot-arm"
	comfort_value = 7

/* ===================================================== */
/* -------------------- Wheelchairs -------------------- */
/* ===================================================== */

TYPEINFO(/obj/stool/chair/comfy/wheelchair)
	mats = 15
	mat_appearances_to_ignore = list("steel")
/obj/stool/chair/comfy/wheelchair
	name = "wheelchair"
	desc = "It's a chair that has wheels attached to it. Do I really have to explain this to you? Can you not figure this out on your own? Wheelchair. Wheel, chair. Chair that has wheels."
	icon_state = "wheelchair"
	arm_icon_state = "arm-wheelchair"
	anchored = UNANCHORED
	comfort_value = 3
	buckle_move_delay = 1
	p_class = 2
	scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
	var/lying = 0 // didja get knocked over? fall down some stairs?
	parts_type = /obj/item/furniture_parts/wheelchair

	New()
		..()
		if (src.lying)
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying

	update_icon()

		ENSURE_IMAGE(src.arm_image, src.icon, src.arm_icon_state)
		src.arm_image.layer = FLY_LAYER+1
		src.UpdateOverlays(src.arm_image, "arm")

	proc/fall_over(var/turf/T)
		if (src.lying)
			return
		if (src.buckled_guy)
			var/mob/living/M = src.buckled_guy
			src.unbuckle()
			if (M && !src.buckled_guy)
				M.visible_message(SPAN_ALERT("[M] is tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!"),\
				SPAN_ALERT("You're tossed out of [src] as it tips [T ? "while rolling over [T]" : "over"]!"))
				var/turf/target = get_edge_target_turf(src, src.dir)
				M.throw_at(target, 3, 1)
				M.changeStatus("stunned", 5 SECONDS)
				M.changeStatus("knockdown", 3 SECONDS)
			else
				src.visible_message(SPAN_ALERT("[src] tips [T ? "as it rolls over [T]" : "over"]!"))
		else
			src.visible_message(SPAN_ALERT("[src] tips [T ? "as it rolls over [T]" : "over"]!"))
		src.lying = 1
		animate_rest(src, !src.lying)
		src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
		src.scoot_sounds = list('sound/misc/chair/normal/scoot1.ogg', 'sound/misc/chair/normal/scoot2.ogg', 'sound/misc/chair/normal/scoot3.ogg', 'sound/misc/chair/normal/scoot4.ogg', 'sound/misc/chair/normal/scoot5.ogg')

	attack_hand(mob/user)
		if (src.lying)
			user.visible_message("[user] sets [src] back on its wheels.",\
			"You set [src] back on its wheels.")
			src.lying = 0
			animate_rest(src, !src.lying)
			src.p_class = initial(src.p_class) + src.lying // 2 while standing, 3 while lying
			src.scoot_sounds = scoot_sounds = list('sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg')
			return
		else
			return ..()

	buckle_in(mob/living/to_buckle, mob/living/user, var/stand = 0)
		if (src.lying)
			return FALSE
		. = ..()
		if (.)
			APPLY_MOVEMENT_MODIFIER(to_buckle, /datum/movement_modifier/wheelchair, src.type)
			return TRUE

	unbuckle()
		if(src.buckled_guy)
			REMOVE_MOVEMENT_MODIFIER(src.buckled_guy, /datum/movement_modifier/wheelchair, src.type)
		return ..()

	set_loc(newloc)
		. = ..()
		if(src.buckled_guy?.loc != src.loc)
			unbuckle()

/* ======================================================= */
/* -------------------- Dining Chairs -------------------- */
/* ======================================================= */

TYPEINFO(/obj/stool/chair/dining/wood)
	mat_appearances_to_ignore = list("wood")
/obj/stool/chair/dining/
	name = "dining chair"
	icon_state = "chair_wooden"
	desc = "You shouldn't be seeing this!"
	comfort_value = 3
	foldable = 0
	anchored = UNANCHORED
	//deconstructable = 0



	wood
		name = "wooden chair"
		desc = "A wooden dining chair. neat."
		icon_state = "chair_wooden" // this sprite is bad I will fix it at some point
		parts_type = /obj/item/furniture_parts/dining_chair/wood

		constructed //no "wood wood chair"
			name = "chair"

	regal
		name = "regal chair"
		desc = "Much more comfortable than the average dining chair, and much more expensive."
		icon_state = "regalchair"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/dining_chair/regal

	scrap
		name = "scrap chair"
		desc = "Hopefully you didn't pay actual money for this."
		icon_state = "scrapchair"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/dining_chair/scrap

	industrial
		name = "industrial chair"
		desc = "Repurposed scaffolding in the shape of a chair."
		icon_state = "chair_industrial"
		comfort_value = 7
		parts_type = /obj/item/furniture_parts/dining_chair/industrial

/* ============================================== */
/* -------------------- Pews -------------------- */
/* ============================================== */

/obj/stool/chair/pew // pew pew
	name = "pew"
	desc = "It's like a bench, but more holy. No, not <i>holey</i>, <b>holy</b>. Like, godly, divine. That kinda thing.<br>Okay, it's actually kind of holey, too, now that you look at it closer."
	icon_state = "pew"
	anchored = ANCHORED
	rotatable = 0
	foldable = 0
	comfort_value = 2
	deconstructable = TRUE
	securable = 0
	parts_type = /obj/item/furniture_parts/bench/pew
	var/image/arm_image = null
	var/arm_icon_state = null

	New()
		..()
		if (arm_icon_state)
			src.UpdateIcon()

	get_help_message(dist, mob/user)
		. = ..()
		. += "You can reshape it with a screwdriving tool. You can turn it with a crowbar."


	attackby(obj/item/W, mob/user)
		if(isscrewingtool(W))
			switch(src.icon_state)
				if("pewL")
					src.icon_state = "pewC"
				if("pewC")
					src.icon_state = "pewR"
				if("pewR")
					src.icon_state = "pew"
				if("pew")
					src.icon_state = "pewL"
			playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
			user.visible_message(SPAN_NOTICE("[user] reshapes the pew."), SPAN_NOTICE("You reshape the pew."))
			src.update_icon()
			return
		if(ispryingtool(W))
			src.dir = turn(src.dir,90)
			src.update_icon()
			return
		. = ..()

	update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	left
		icon_state = "pewL"
	center
		icon_state = "pewC"
	right
		icon_state = "pewR"

/obj/stool/chair/pew/fancy
	icon_state = "fpew"
	arm_icon_state = "arm-fpew"

	left
		icon_state = "fpewL"
		arm_icon_state = "arm-fpewL"
	center
		icon_state = "fpewC"
		arm_icon_state = null
	right
		icon_state = "fpewR"
		arm_icon_state = "arm-fpewR"

/* ================================================= */
/* -------------------- Couches -------------------- */
/* ================================================= */

/obj/stool/chair/couch
	name = "comfy brown couch"
	desc = "You've probably lost some space credits in these things before."
	icon_state = "chair_couch-brown"
	rotatable = 0
	foldable = 0
	var/damaged = 0
	comfort_value = 5
	deconstructable = 0
	securable = 0
	var/max_uses = 0 // The maximum amount of time one can try to look under the cushions for items.
	var/spawn_chance = 0 // How likely is this couch to spawn something?
	var/last_use = 0 // To prevent spam.
	var/time_between_uses = 400 // The default time between uses.
	var/list/items = list (/obj/item/device/light/zippo,
	/obj/item/wrench,
	/obj/item/device/multitool,
	/obj/item/toy/plush/small/buddy,
	/obj/item/toy/plush/small/stress_ball,
	/obj/item/paper/lunchbox_note,
	/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/reagent_containers/food/snacks/candy/candyheart,
	/obj/item/bananapeel,
	/obj/item/reagent_containers/food/snacks/candy/lollipop/random_medical,
	/obj/item/currency/spacecash/small,
	/obj/item/currency/spacecash/tourist,
	/obj/item/currency/buttcoin)

	New()
		..()
		if (src.dir in ordinal)
			src.layer = FLY_LAYER+1
		max_uses = rand(0, 2) // Losing things in a couch is hard.
		spawn_chance = rand(1, 20)

		if (prob(10)) //time to flail
			items.Add(/obj/critter/meatslinky)

		if (prob(1))
			desc = "A vague feeling of loss emanates from this couch, as if it is missing a part of itself. A global list of couches, perhaps."

	disposing()
		..()

	proc/damage(severity)
		if(severity > 1 && damaged < 2)
			damaged += 2
			overlays += image('icons/obj/objects.dmi', "couch-tear")
		else if(damaged < 1)
			damaged += 1
			overlays += image('icons/obj/objects.dmi', "couch-rip")

	attack_hand(mob/user)
		if (!user) return
		if (damaged || buckled_guy) return ..()

		user.lastattacked = get_weakref(src)

		playsound(src.loc, "rustle", 66, 1, -5) // todo: find a better sound.

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))

			var/something = pick(items)

			if (ispath(something))
				var/thing = new something(src.loc)
				user.put_in_hand_or_drop(thing)
				if (istype(thing, /obj/critter/meatslinky)) //slink slink
					user.emote("scream")
					random_brute_damage(user, 10)
					user.visible_message(SPAN_NOTICE("<b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls [his_or_her(user)] hand out in pain! \An [thing] slithers out of \the [src]!"),\
					SPAN_NOTICE("You rummage through the seams and behind the cushions of [src] and your hand gets bit by \an [thing]!"))
				else
					user.visible_message(SPAN_NOTICE("<b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls \an [thing] out of it!"),\
					SPAN_NOTICE("You rummage through the seams and behind the cushions of [src] and you find \an [thing]!"))
				last_use = world.time
				max_uses--

		else if (max_uses <= 0)
			user.visible_message(SPAN_NOTICE("<b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls out absolutely nothing!"),\
			SPAN_NOTICE("You rummage through the seams and behind the cushions of [src] and pull out absolutely nothing!"))
		else
			user.visible_message(SPAN_NOTICE("<b>[user.name]</b> rummages through the seams and behind the cushions of [src]!"),\
			SPAN_NOTICE("You rummage through the seams and behind the cushions of [src]!"))

	blue
		name = "comfy blue couch"
		icon_state = "chair_couch-blue"

	red
		name = "comfy red couch"
		icon_state = "chair_couch-red"

	green
		name = "comfy green couch"
		icon_state = "chair_couch-green"

	yellow
		name = "comfy yellow couch"
		icon_state = "chair_couch-yellow"

	purple
		name = "comfy purple couch"
		icon_state = "chair_couch-purple"

/* ======================================================= */
/* -------------------- Office Chairs -------------------- */
/* ======================================================= */

/obj/stool/chair/office
	name = "office chair"
	desc = "Hey, you remember spinning around on one of these things as a kid!"
	icon_state = "office_chair"
	comfort_value = 4
	foldable = 0
	anchored = UNANCHORED
	buckle_move_delay = 3
	//deconstructable = 0
	parts_type = /obj/item/furniture_parts/office_chair
	scoot_sounds = list( 'sound/misc/chair/office/scoot1.ogg', 'sound/misc/chair/office/scoot2.ogg', 'sound/misc/chair/office/scoot3.ogg', 'sound/misc/chair/office/scoot4.ogg', 'sound/misc/chair/office/scoot5.ogg' )

	red
		icon_state = "office_chair_red"
		parts_type = /obj/item/furniture_parts/office_chair/red

	green
		icon_state = "office_chair_green"
		parts_type = /obj/item/furniture_parts/office_chair/green

	blue
		icon_state = "office_chair_blue"
		parts_type = /obj/item/furniture_parts/office_chair/blue

	yellow
		icon_state = "office_chair_yellow"
		parts_type = /obj/item/furniture_parts/office_chair/yellow

	purple
		icon_state = "office_chair_purple"
		parts_type = /obj/item/furniture_parts/office_chair/purple

	syndie
		icon_state = "syndiechair"
		parts_type = null

	toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the castors of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
		src.anchored = !(src.anchored)
		return

/* ========================================================= */
/* ---------------------- Pool Chairs ---------------------- */
/* ========================================================= */
/obj/stool/chair/pool
	name = "pool chair"
	desc = "This chair is perfect for lounging at the side of a pool."
	icon_state = "chair_pool"
	rotatable = FALSE
	foldable = FALSE
