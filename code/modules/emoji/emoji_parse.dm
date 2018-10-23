/proc/emoji_parse(text)
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon('icons/emoji.dmi'))
	var/static/list/yogmojis = icon_states(icon('yogstation/icons/emoji.dmi')) //YOGS - yogmoji
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos+1)
			if(search)
				emoji = lowertext(copytext(text, pos+1, search))
				var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/goonchat)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					parsed += tag
					pos = search + 1
				else if(emoji in yogmojis) //yogs start -yogmoji
					parsed += icon2html('yogstation/icons/emoji.dmi', world, emoji)
					pos = search + 1 //yogs end - yogmoji
				else if(emoji in baronmojis)//Barony13
					parsed += icon2html('barony13/icons/emoji.dmi', world, emoji)
					pos = search + 1 
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

