note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ABORT
inherit
	ETF_ABORT_INTERFACE
create
	make
feature -- command
	abort
    	do
			-- perform some update on the model state
			if not model.started then
				model.error.handler ("  Command can only be used in setup mode or in game.")
			else
				model.abort
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
