note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_NEXT
inherit
	ETF_SETUP_NEXT_INTERFACE
create
	make
feature -- command
	setup_next(state: INTEGER_32)
		require else
			setup_next_precond(state)
    	do
			-- perform some update on the model state
			if not model.started or model.in_game then
				model.error.handler ("  Command can only be used in setup mode.")
			else
				model.state.state_forth (state)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
