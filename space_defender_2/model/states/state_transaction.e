note
	description: "Summary description for {STATE_TRANSACTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STATE_TRANSACTION
create
	make

feature
	states: LIST[STATE]
	state_cursor: INTEGER
	max_cursor:INTEGER
	initial: INTEGER

feature {NONE}
	make
		do
			create {LINKED_LIST[STATE]} states.make
			states.extend (create {WEAPONSET}.make)
			states.extend (create {ARMOURSET}.make)
			states.extend (create {ENGINESET}.make)
			states.extend (create {POWERSET}.make)
			initial:= 1
			state_cursor := initial
			max_cursor:= 5
--			check attached model end
		end

feature
	reset -- (a: ARRAY[INTEGER])
		do
--			across 1 |..| a.count is i loop states[i].set (a[i])  end
			state_cursor := initial
		end

	state_forth(c:INTEGER)
		local
			gm: GAME_ACCESS
		do
			gm.m.error.reset
			state_cursor :=state_cursor + c
			if state_cursor > max_cursor then
				gm.m.toggle_ingame
			end
		end

	state_back(c:INTEGER)
		local
			gm: GAME_ACCESS
		do
			gm.m.error.reset
			state_cursor :=state_cursor - c
			if state_cursor < initial then
				gm.m.toggle_started
			end
		end

	state_choice(c:INTEGER)
		require
			valid_choice (c)
		local
			gm: GAME_ACCESS
		do
			gm.m.error.reset
			states[state_cursor].set (c)
		end

	valid_choice(c:INTEGER):BOOLEAN
		do
			Result := states[state_cursor].valid_choice(c)
		end

	state_display: STRING
		do
			create Result.make_empty
			if state_cursor /= max_cursor then
				Result.append (states[state_cursor].display)
			else
				across
					1 |..| states.count is i
				loop
					if i /= states.count then
						Result.append(states[i].choice_message + "%N")
					else
						Result.append(states[i].choice_message)
					end
				end
			end
		end
end
