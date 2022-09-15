note
	description: "Summary description for {PLATINUM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLATINUM
inherit
	ENEMY_FOCUS
	redefine
		make
	end
create
	make
feature
	make
		do
			Precursor
			max_n := 3
			multiplier := 2
			children.extend (create {BRONZE}.make)
		end
end
