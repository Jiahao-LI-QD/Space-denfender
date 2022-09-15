note
	description: "Summary description for {PROJ_F}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PROJ_F

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
			content:= '*'
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
		do
			m.wipe_out
			create o_pos.make_from_tuple (pos)
			model.board.put (create {OBJECT}.make, pos.first, pos.second)
------------standard
			if type = 1 then

				across
					pos.second |..| (pos.second + move_method.second) is i
				loop
					if i /= pos.second and active then

						pos.make (pos.first, i)
						if not in_board then
							inactive
						end
						if active and then collide(model.board[pos.first,i]) then

						end
					end
				end
------------spread
			elseif type = 2 then
				pos.make (pos.first + move_method.first, pos.second + move_method.second)

				if not in_board then
					inactive
				end
				if active and then collide(model.board[pos.first,pos.second]) then

				end
			elseif type = 3 then

				pos.make (pos.first + move_method.first, pos.second + move_method.second)

				if not in_board then
					inactive
				end
				if active and then collide(model.board[pos.first,pos.second]) then

				end

			elseif type = 4 then
				across
					pos.second |..| (pos.second + move_method.second) is i
				loop
					if i /= pos.second and active then

						pos.make (pos.first, i)
						if not in_board then
							inactive
						end
						if active and then collide(model.board[pos.first,i]) then

						end
					end
				end
				move_method.make ( move_method.first, 2 * move_method.second)
			end
			if type = 5 then
				model.update_f_act ("    A friendly projectile(id:" + id.out + ") stays at: ")
				model.update_f_act ("[" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "]%N")
			else
				model.update_f_act ("    A friendly projectile(id:" + id.out + ") moves: ")
				model.update_f_act ("[" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "] -> ")
				if in_board then
					model.update_f_act ("[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")
				else
					model.update_f_act ("out of board%N")
				end
			end

			model.update_f_act (m)
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
						--      "The projectile collides with friendly projectile(id:<id>) at location [X,Y], combining damage."
						if p.type /= 0 then
							p.inactive
							damage := damage + p.damage
							model.board.put (create {OBJECT}.make, pos.first, pos.second)
							m.append ("      The projectile collides with friendly projectile(id:" +p.id.out+") at location ")
							m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], combining damage.%N")
						else
							m.append ("      The projectile collides with enemy projectile(id:" +p.id.out+") at location ")
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
					----------------------------The projectile collides with <entity name>(id:<id>) at location [X,Y],
--					dealing <projectile damage - entity armour> damage.

					check attached {ENEMY} o as e then
						e.collide(current)
						m.append ("      The projectile collides with "+e.full_name+"(id:" +e.id.out+") at location ")
						m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], dealing ")
						if damage > e.armour then
							m.append ((damage - e.armour).out +" damage.%N")
						else
							m.append ("0 damage.%N")
						end
						if not e.active then
--The Grunt at location [E,20] has been destroyed.
							m.append ("      The "+ e.full_name +" at location ")
							m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
						end
					end
				else
					model.star.collide_p (current)
					m.append ("      The projectile collides with Starfighter(id:0) at location ")
					m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], dealing "+ (damage - model.star.armour).out +" damage.%N")
				end
			else
				Result := false
			end
		end
end
