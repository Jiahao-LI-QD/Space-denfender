note
	description: "Summary description for {INTERCEPTOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INTERCEPTOR
inherit
	ENEMY
		redefine
			make
		end

create
	make

feature
	make(i, r, c:INTEGER)
		do
			content := 'I'
			max_health :=50
			h_r := 0
			armour := 0
			vision := 5
			health := max_health
			Precursor(i, r, c)
			create {BRONZE} orb.make
		end

	action
		do
			m.wipe_out
			regeneration

			move_to (pos.first, pos.second - 3)
			model.update_enemies_act (m)

		end


	preemptive_action
		local
			o_pos : like pos
			i: INTEGER
			stop: BOOLEAN
		do
			m.wipe_out
			create o_pos.make_from_tuple (pos)
			if model.action_type = 2 then

			model.board.put (create {OBJECT}.make, o_pos.first, o_pos.second)
			ready := false
			from
				i := o_pos.first
			until
				i = model.star.pos.first  or not active or stop
			loop
				if model.star.pos.first < o_pos.first then
					i := i - 1
				else
					i := i + 1
				end
				if model.board[i, pos.second].id > 0 then
					stop := true
				else
					pos.make (i, pos.second)
					if model.board[pos.first, pos.second].occupied then
						if model.board[pos.first, pos.second].id < 0 and then attached {PROJECTILE} model.board[pos.first, pos.second] as p then
							collide(p)
							if p.type = 0 then
								m.append ("      The " + full_name + " collides with enemy projectile(id:" + p.id.out +") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], healing "+p.damage.out +" damage.%N")
							else
								m.append ("      The " + full_name + " collides with friendly projectile(id:" + p.id.out +") at location ")
								m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], taking "+(p.damage - armour).out +" damage.%N")

							end
						else
							inactive
							m.append ("      The " + full_name + " collides with Starfighter(id:0) at location ")
							m.append ("[" + model.rows[pos.first].out + "," + pos.second.out+ "], trading "+ health.out +" damage.%N")
							model.star.collide_e (current)
						end

					end
				end
			end

				model.update_enemies_act ("    A " + full_name + "(id:" + id.out + ") ")
				if o_pos.first = pos.first and o_pos.second = pos.second then
					model.update_enemies_act ("stays at: [" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "]%N")
				else
					model.update_enemies_act ("moves: [" + model.rows[o_pos.first].out + "," + o_pos.second.out+ "] -> ")
					model.update_enemies_act ("[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")
				end

				if not active then
					m.append ("      The " + full_name + " at location ["+ model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
				else
					model.board.put (current, pos.first, pos.second)
				end

				if model.star.destroyed then
					m.append ("      The Starfighter at location [" + model.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
				end
				model.update_enemies_act (m)
			end
		end

end
