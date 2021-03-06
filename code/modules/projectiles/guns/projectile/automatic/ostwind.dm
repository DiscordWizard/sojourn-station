/obj/item/weapon/gun/projectile/automatic/ostwind
	name = "\"Ostwind\" assault rifle"
	desc = "An \"Ostwind\" high-end police-grade assault rifle manufactured by Seinemetall Defense. Primarily used by law enforcement, counter-terror units, and private security. Uses .208 Rifle rounds."
	icon = 'icons/obj/guns/projectile/ostwind.dmi'
	icon_state = "ostwind"
	item_state = "ostwind"
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	caliber = CAL_SRIFLE
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1)
	slot_flags = SLOT_BACK
	load_method = MAGAZINE
	mag_well = MAG_WELL_STANMAG
	auto_eject = 1
	matter = list(MATERIAL_PLASTEEL = 20, MATERIAL_STEEL = 20, MATERIAL_PLASTIC = 10)
	price_tag = 4000
	fire_sound = 'sound/weapons/guns/fire/ltrifle_fire.ogg'
	auto_eject_sound = 'sound/weapons/smg_empty_alarm.ogg'
	unload_sound 	= 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/ltrifle_magin.ogg'
	cocked_sound 	= 'sound/weapons/guns/interact/ltrifle_cock.ogg'
	zoom_factor = 0.4
	recoil_buildup = 7
	one_hand_penalty = 15 //automatic rifle level

	firemodes = list(
		FULL_AUTO_400,
		SEMI_AUTO_NODELAY,
		BURST_3_ROUND
		)

/obj/item/weapon/gun/projectile/automatic/ostwind/update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (ammo_magazine)
		iconstring += "[ammo_magazine? "_mag[ammo_magazine.max_ammo]": ""]"

	if (!ammo_magazine || !length(ammo_magazine.stored_ammo))
		iconstring += "_slide"

	icon_state = iconstring
	set_item_state(itemstring)

/obj/item/weapon/gun/projectile/automatic/ostwind/Initialize()
	. = ..()
	update_icon()