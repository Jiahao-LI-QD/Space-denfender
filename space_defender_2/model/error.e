note
	description: "Summary description for {ERROR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ERROR

create --{ERROR_ACCESS}
	make

feature
	state: INTEGER
	message: STRING

feature {NONE}
	make
		do
			create message.make_empty
			state := 0
		end
feature
	handler(m: STRING)
		do
			message:= m
			state := state + 1
		end

	display:STRING
		do
			create Result.make_from_string (message)
		end

	debug_mode
		do
			state := state + 1
		end

	reset
		do
			state := 0
		end
end
