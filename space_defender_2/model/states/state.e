note
	description: "Summary description for {STATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STATE

feature -- attributes
	m: STRING -- messages
	ms: ARRAY[STRING]
	answer: INTEGER -- choice for current state
--	model: GAME
feature
	make
--		local
--			g_a: GAME_ACCESS
		do
--			model := g_a.m
			answer:= 1
			create m.make_empty
			create ms.make_empty
		end
	set(a: INTEGER)
		do
			answer:= a
		end

feature -- query
	display:STRING
		deferred
		end

	choice_message: STRING
		deferred
		end

	valid_choice(c:INTEGER): BOOLEAN
		deferred
		end
end
