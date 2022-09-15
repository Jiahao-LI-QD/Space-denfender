note
	description: "Summary description for {PROJ_E}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PROJ_E

inherit
	PROJECTILE
		redefine
			make
		end

create
	make

feature
	make(i, t ,d, r, c, a, b:INTEGER)
		do
			Precursor(i, t ,d, r, c, a, b)
			content:= '<'
			if not in_board then
				inactive
			end
			if active then
				if not collide(model.board[r,c]) then
					model.board.put (current, pos.first, pos.second)
				end
				if active then
					model.board.put (current, pos.first, pos.second)
				end
			end
		end

	move
		local
			o_pos: like pos
			i:INTEGER
		do
			m.wipe_out
			create o_pos.make_from_tuple (pos)
			model.board.put (create {OBJECT}.make, pos.first, pos.second)
--			across
--				pos.second |..| (pos.second + move_method.second) is i
--			loop
			from
				i := o_pos.second
			until
				i = o_pos.second + move_method.second
			loop
				i := i - 1
				if active then

					pos.make (pos.first, i)
					if not in_board then
						inactive
					end
					if active and then collide(model.board[pos.first,i]) then
						if not model.board[pos.first,i].active then
							model.board.put (create {OBJECT}.make, pos.first,i)
						end
					end

				end
			end

--- message
			model.update_e_act ("    A enemy projectile(id:" + id.out + ") moves: ")
			model.update_e_act ("[" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "] -> ")
			if in_board then
				model.update_e_act ("[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")
			else
				model.update_e_act ("out of board%N")
			end
				model.update_e_act (m)

			if active and in_board then
				model.board.put (current, pos.first, pos.second)
			end
		end

	collide(o:OBJECT):BOOLEAN
			do
				if o.occupied then
					Result := true

					if o.id < 0 then
						check attached {PROJECTILE} o as p then
							if p.type = 0 then
								p.inactive
								damage := damage + p.damage
								model.board.put (create {OBJECT}.make, pos.first, pos.second)
								m.append ("      The projectile collides with enemy projectile(id:" +p.id.out+") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], combining damage.%N")
							else
								m.append ("      The projectile collides with friendly projectile(id:" +p.id.out+") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], negating damage.%N")
								if p.damage < damage then
									p.inactive
									damage := damage - p.damage
									model.board.put (create {OBJECT}.make, pos.first, pos.second)
								elseif p.damage > damage then
									inactive
									p.change_damage(0-damage)
								else
									inactive
									p.inactive
									change_damage (0-damage)
									p.change_damage(0-damage)
									model.board.put (create {OBJECT}.make, pos.first, pos.second)
								end
							end
						end
					elseif o.id > 0 then
					----------------------------
						check attached {ENEMY} o as e then
							e.collide(current)
							m.append ("      The projectile collides with "+e.full_name+"(id:" +e.id.out+") at location ")
							m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], healing "+ damage.out +" damage.%N")

						end
					else
--      The projectile collides with Starfighter(id:0) at location [C,1], dealing 98 damage.
--      The Starfighter at location [C,1] has been destroyed.
						model.star.collide_p (current)
						m.append ("      The projectile collides with Starfighter(id:0) at location ")
						m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], dealing ")
						if damage > model.star.armour then
							m.append ((damage - model.star.armour).out +" damage.%N")
						else
							m.append ("0 damage.%N")
						end
						if model.star.destroyed then
							m.append ("      The Starfighter at location [" + model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
						end
					end
				else
					Result := false
				end
			end
end
