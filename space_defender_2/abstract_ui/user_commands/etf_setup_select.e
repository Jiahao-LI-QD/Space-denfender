note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_SELECT
inherit
	ETF_SETUP_SELECT_INTERFACE
create
	make
feature -- command
	setup_select(value: INTEGER_32)
		require else
			setup_select_precond(value)
    	do
			-- perform some update on the model state
			if not model.started or model.in_game or model.state.state_cursor = 5 then
				model.error.handler ("  Command can only be used in setup mode (excluding summary in setup).")
			elseif not (1 <= value and value <= model.state.states[model.state.state_cursor].ms.count) then
				model.error.handler ("  Menu option selected out of range.")
			else
				model.state.state_choice (value)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
