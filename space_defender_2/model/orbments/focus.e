note
	description: "Summary description for {FOCUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FOCUS
inherit
	COMPOSITE_ORBMENT

create
	make

feature

	make
		do
			create {LINKED_LIST[ORBMENT]} children.make
		end

end
