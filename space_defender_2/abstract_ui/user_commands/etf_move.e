note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make
feature -- command
	move(row: INTEGER_32 ; column: INTEGER_32)
		require else
			move_precond(row, column)
		local
			r :INTEGER
    	do
			-- perform some update on the model state
			if row = A then
				r := 1
			elseif row = B then
				r := 2
			elseif row = C then
				r := 3
			elseif row = D then
				r := 4
			elseif row = E then
				r := 5
			elseif row = F then
				r := 6
			elseif row = G then
				r := 7
			elseif row = H then
				r := 8
			elseif row = I then
				r := 9
			elseif row = J then
				r := 10
			end

			if not model.in_game then
				model.error.handler ("  Command can only be used in game.")
			elseif r > model.max_r or column > model.max_c then
				model.error.handler ("  Cannot move outside of board.")
			elseif r = model.star.pos.first and column = model.star.pos.second then
				model.error.handler ("  Already there.")
			elseif (r - model.star.pos.first).abs + (column - model.star.pos.second).abs > model.star.move then
				model.error.handler ("  Out of movement range.")
			elseif not available(r,column) then
				model.error.handler ("  Not enough resources to move.")
			else
				model.move (r, column)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end
	available(r,col:INTEGER):BOOLEAN
		do
			Result := (model.star.energy + model.star.e_r) >= model.star.move_cost (r, col)

		end
end
