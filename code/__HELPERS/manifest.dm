// Generates a simple HTML crew manifest for use in various places

/datum/tgui_module/manifest
	name = "Manifest"
	tgui_id = "CrewManifest"

/datum/tgui_module/manifest/ui_data(mob/user)
	var/list/data = list()

	var/list/dept_data = list(
		list("key" = "heads", "flag" = COMMAND),
		list("key" = "sec", "flag" = SECURITY),
		list("key" = "bls", "flag" = BLACKSHIELD),
		list("key" = "med", "flag" = MEDICAL),
		list("key" = "sci", "flag" = SCIENCE),
		list("key" = "chr", "flag" = CHURCH),
		list("key" = "sup", "flag" = LSS),
		list("key" = "eng", "flag" = ENGINEERING),
		list("key" = "pro", "flag" = PROSPECTORS),
		list("key" = "civ", "flag" = CIVILIAN),
		list("key" = "bot", "flag" = MISC),
		list("key" = "ldg", "flag" = LODGE)
	)

	var/list/manifest = list()
	for(var/datum/computer_file/report/crew_record/CR in GLOB.all_crew_records)
		var/list/crew_data = list()

		var/name = CR.get_name()
		crew_data["name"] = name
		
		var/rank = CR.get_job()
		crew_data["rank"] = rank

		var/datum/job/job = SSjob.occupations_by_name[rank]

		var/list/departments = list()
		if(istype(job))
			for(var/list/department in dept_data)
				if(job.department_flag & department["flag"])
					departments += department["key"]
		crew_data["departments"] = departments

		for(var/datum/mind/M in SSticker.minds)
			if(M.name == name)
				var/status = M.manifest_status(CR)
				if(status)
					crew_data["status"] = status
				break

		manifest += list(crew_data)

	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		manifest += list(list("name" = ai.name, "rank" = "Artificial Intelligence", "departments" = list("bot")))

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue

		manifest += list(list("name" = robot.name, "rank" = "[robot.modtype] [robot.braintype]", "departments" = list("bot")))
	
	data["manifest"] = manifest

	return data

/datum/tgui_module/manifest/ui_state(mob/user)
	return GLOB.always_state

//Intended for open manifest in separate window
/proc/show_manifest(mob/user)
	var/datum/tgui_module/manifest/manifest = new(user)
	manifest.ui_interact(user)

/proc/html_crew_manifest(var/monochrome, var/OOC)
	var/list/dept_data = list(

		list("names" = list(), "header" = "Command Staff", "flag" = COMMAND),
		list("names" = list(), "header" = "Security - Marshals", "flag" = SECURITY),
		list("names" = list(), "header" = "Security - Blackshield", "flag" = BLACKSHIELD),
		list("names" = list(), "header" = "Soteria Medical", "flag" = MEDICAL),
		list("names" = list(), "header" = "Soteria Research", "flag" = SCIENCE),
		list("names" = list(), "header" = "Church of the Absolute", "flag" = CHURCH),
		list("names" = list(), "header" = "Lonestar Shipping Solutions", "flag" = LSS),
		list("names" = list(), "header" = "Artificers Guild", "flag" = ENGINEERING),
		list("names" = list(), "header" = "Prospector", "flag" = PROSPECTORS),
		list("names" = list(), "header" = "Civilian", "flag" = CIVILIAN),
		list("names" = list(), "header" = "Miscellaneous", "flag" = MISC),
		list("names" = list(), "header" = "Silicon"),
		list("names" = list(), "header" = "Lodge", "flag" = LODGE)
	)
	var/list/misc //Special departments for easier access
	var/list/bot
	for(var/list/department in dept_data)
		if(department["flag"] == MISC)
			misc = department["names"]
		if(isnull(department["flag"]))
			bot = department["names"]

	var/list/isactive = new()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;width:100%;}
		.manifest td, th {border:1px solid [monochrome?"black":"[OOC?"black; background-color:#272727; color:white":"#DEF; background-color:white; color:black"]"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: [OOC?"#40628a":"#48C"]; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: [OOC?"#013D3B;":"#488;"]"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: [OOC?"#373737; color:white":"#DEF"]"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Position</th><th>Activity</th></tr>
	"}
	// sort mobs
	for(var/datum/computer_file/report/crew_record/CR in GLOB.all_crew_records)
		var/name = CR.get_name()
		var/rank = CR.get_job()

		var/matched = FALSE
		var/skip = FALSE
		//Minds should never be deleted, so our crew record must be in here somewhere
		for(var/datum/mind/M in SSticker.minds)
			if(M.name == name)
				matched = TRUE
				var/temp = M.manifest_status(CR)
				if (temp)
					isactive[name] = temp
				else
					break
					//skip = TRUE //Disabled so that no matter how afk, someone is still on the manifest.
				break

		if (skip)
			continue

		if (!matched)
			isactive[name] = "Unknown"

		var/datum/job/job = SSjob.occupations_by_name[rank]
		var/found_place = 0
		if(job)
			for(var/list/department in dept_data)
				var/list/names = department["names"]
				if(job.department_flag & department["flag"])
					names[name] = rank
					found_place = 1
		if(!found_place)
			misc[name] = rank

	// Synthetics don't have actual records, so we will pull them from here.
	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		bot[ai.name] = "Artificial Intelligence"

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue

		bot[robot.name] = "[robot.modtype] [robot.braintype]"

	for(var/list/department in dept_data)
		var/list/names = department["names"]
		if(names.len > 0)
			dat += "<tr><th colspan=3>[department["header"]]</th></tr>"
			for(var/name in names)
				dat += "<tr class='candystripe'><td>[name]</td><td>[names[name]]</td><td>[isactive[name]]</td></tr>"

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/proc/silicon_nano_crew_manifest(var/list/filter)
	var/list/filtered_entries = list()

	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		filtered_entries.Add(list(list(
			"name" = ai.name,
			"rank" = "Artificial Intelligence",
			"status" = ""
		)))
	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		if(robot.module && robot.module.hide_on_manifest)
			continue
		filtered_entries.Add(list(list(
			"name" = robot.name,
			"rank" = "[robot.modtype] [robot.braintype]",
			"status" = ""
		)))
	return filtered_entries

/proc/filtered_nano_crew_manifest(var/list/filter, var/blacklist = FALSE)
	var/list/filtered_entries = list()
	for(var/datum/computer_file/report/crew_record/CR in department_crew_manifest(filter, blacklist))
		filtered_entries.Add(list(list(
			"name" = CR.get_name(),
			"rank" = CR.get_job(),
			"status" = CR.get_status()
		)))
	return filtered_entries

/proc/nano_crew_manifest()
	return list(\
		"heads" = filtered_nano_crew_manifest(command_positions),\
		"sci" = filtered_nano_crew_manifest(science_positions),\
		"sec" = filtered_nano_crew_manifest(security_positions),\
		"bls" = filtered_nano_crew_manifest(blackshield_positions),\
		"eng" = filtered_nano_crew_manifest(engineering_positions),\
		"med" = filtered_nano_crew_manifest(medical_positions),\
		"sup" = filtered_nano_crew_manifest(cargo_positions),\
		"chr" = filtered_nano_crew_manifest(church_positions),\
		"pro" = filtered_nano_crew_manifest(prospector_positions),\
		"bot" = silicon_nano_crew_manifest(nonhuman_positions),\
		"civ" = filtered_nano_crew_manifest(civilian_positions),\
		"ldg" = filtered_nano_crew_manifest(lodge_positions)\
		)

/proc/flat_nano_crew_manifest()
	. = list()
	. += filtered_nano_crew_manifest(null, TRUE)
	. += silicon_nano_crew_manifest(nonhuman_positions)
