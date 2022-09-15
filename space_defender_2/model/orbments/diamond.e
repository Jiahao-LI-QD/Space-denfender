note
	description: "Summary description for {DIAMOND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIAMOND
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
			max_n := 4
			multiplier := 3
			children.extend (create {GOLD}.make)
		end
end
