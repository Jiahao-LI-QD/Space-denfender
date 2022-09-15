note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SPECIAL
inherit
	ETF_SPECIAL_INTERFACE
create
	make
feature -- command
	special
    	do
			-- perform some update on the model state
			if not model.in_game then
				model.error.handler ("  Command can only be used in game.")
			elseif not available then
				model.error.handler ("  Not enough resources to use special.")
			else
				model.special
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

	available:BOOLEAN
		do
			if model.star.special_cost.second then
				Result := (model.star.energy + model.star.e_r) >= model.star.special_cost.first
			else
				Result := true
			end
		end
end
