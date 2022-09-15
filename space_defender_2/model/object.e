note
	description: "Summary description for {OBJECT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OBJECT
inherit
	ANY
		redefine
			out
		end
create
	make

feature
	id: INTEGER
	occupied: BOOLEAN
	content: CHARACTER
	active: BOOLEAN
feature
	make
		do
			occupied:= false
			content:= '_'
		end

	inactive
		do
			active := false
		end

	out: STRING
		do
			create Result.make_empty
			Result.append (content.out)
		end
end
