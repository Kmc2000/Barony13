/*
This file has the procs and global lists associated with the prettyfilter stuff and the spellfix stuff.

*/

//GLOBAL SHIT
/var/list/pretty_filter_items = list()
/var/list/spellfix_filter_items = list()

//PROCS
/proc/setup_chat_filters(var/pretty_path = "config/pretty_filter.txt",var/spellfix_path = "config/spellfix_filter.txt")
//Handles setting up the pretty & spellfix filters
//Called @code\game\world.dm , at about line 39 or so as of Nov 2018
	var/list/filter_lines = world.file2list(pretty_path)
	for(var/line in filter_lines)
		if(findtextEx(line,"#",1,2) || length(line) == 0)
			continue

		if(!add_filter_line(line,TRUE))
			continue
	filter_lines = world.file2list(spellfix_path)
	for(var/line in filter_lines)
		if(findtextEx(line,"#",1,2) || length(line) == 0)
			continue

		if(!add_filter_line(line,FALSE))
			continue
/proc/add_filter_line(var/line, var/ispretty)// Add a filter pair
//line - the pattern-replacement string freshly picked from the config file, to be parsed
//ispretty - a boolean, to mark whether to dump the resulting shit in the pretty filter list, or the spellfix one
	if(!length(line)) // If there's no line
		return 0//whoops

	if(findtextEx(line,"#",1,2))//If it's a comment
		return 0//Get outta here

	//Split the line at every "="
	var/list/parts = splittext(line, "=")
	if(!parts.len)//If it's shittily formatted
		return 0//Fuck you

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return 0

	//replacement follows the first "="
	var/replacement = ""
	if(parts.len >= 2)
		var/index = 2
		for(index = 2; index <= parts.len; index++)
			replacement += parts[index]
			if(index < parts.len)
				replacement += "="

	if(!replacement)
		return 0

	if(ispretty)
		pretty_filter_items.Add(line)
	else
		spellfix_filter_items.Add(line)
	return 1

// List all filters that have been loaded
/client/proc/list_chat_filters()
	set category = "Special Verbs"
	set name = "Chat Filters - List"

	to_chat(usr, "<font size='3'><b>Pretty filters list</b></font>")
	for(var/line in pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		to_chat(usr, "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>")
	to_chat(usr, "<font size='3'><b>Spellfix filters list</b></font>")
	for(var/line in spellfix_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="
					
		to_chat(usr, "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>")
	to_chat(usr, "<font size='3'><b>--------------</b></font>")

//Filter out and replace unwanted words, prettify sentences
/proc/pretty_filter(var/text)
	for(var/line in pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		var/regex/R = new(pattern, "ig")
		text = R.Replace(text, replacement)

	return text
/proc/spellfix_filter(var/text)
	for(var/line in spellfix_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		var/regex/R = new(pattern, "g")
		text = R.Replace(text, replacement)

	return text
/proc/isnotpretty(var/text) // A simpler version of pretty_filter(), where all it returns is whether it had to replace something or not.
	//Useful for the "You fumble your words..." business.
	for(var/line in pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/regex/R = new(pattern, "ig")
		if(R.Find(text)) //If found
			return TRUE // Yes, it isn't pretty.
	return FALSE // No, it is pretty.
