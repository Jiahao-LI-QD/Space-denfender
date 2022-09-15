note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
create
	make
feature -- command
	fire
    	do
			-- perform some update on the model state
			if not model.in_game then
				model.error.handler ("  Command can only be used in game.")
			elseif not available then
				model.error.handler ("  Not enough resources to fire.")
			else
				model.fire
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

	available:BOOLEAN
		do
			if model.star.fire_cost.second then
				Result := (model.star.energy + model.star.e_r) >= model.star.fire_cost.first
			else
				Result := (model.star.health + model.star.h_r) > model.star.fire_cost.first
			end
		end
end
