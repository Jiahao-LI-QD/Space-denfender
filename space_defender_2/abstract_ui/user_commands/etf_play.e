note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PLAY
inherit
	ETF_PLAY_INTERFACE
create
	make
feature -- command
	play(row: INTEGER_32 ; column: INTEGER_32 ; g_threshold: INTEGER_32 ; f_threshold: INTEGER_32 ; c_threshold: INTEGER_32 ; i_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		require else
			play_precond(row, column, g_threshold, f_threshold, c_threshold, i_threshold, p_threshold)
    	do
			-- perform some update on the model state
			if model.started and not model.in_game then
				model.error.handler ("  Already in setup mode.")
			elseif model.in_game then
				model.error.handler ("  Already in a game. Please abort to start a new one.")
			elseif not non_decreasing(g_threshold, f_threshold, c_threshold, i_threshold, p_threshold) then
				model.error.handler ("  Threshold values are not non-decreasing.")
			else
				model.play (row, column, g_threshold, f_threshold, c_threshold, i_threshold, p_threshold)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

	non_decreasing(t1,t2, t3, t4, t5: INTEGER):BOOLEAN
		do
			Result := t1 <= t2 and t2 <= t3 and t3 <= t4 and t4 <= t5
		end
end
