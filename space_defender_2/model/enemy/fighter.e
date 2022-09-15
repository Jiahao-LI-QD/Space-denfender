note
	description: "Summary description for {FIGHTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FIGHTER
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
			content := 'F'
			max_health := 150
			h_r := 5
			armour := 10
			vision := 10
			health := max_health
			Precursor(i, r, c)
			create {GOLD} orb.make
		end

	action
		local
			p: PROJECTILE
		do
			m.wipe_out
			regeneration
			if can_see_starfighter then
--      A enemy projectile(id:-1) spawns at location [A,27].
				move_to (pos.first, pos.second - 1)

				if active then
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 50, pos.first, pos.second - 1, 0, -6)
					model.projs.extend (p)

					m.append ("      A enemy projectile(id:-" + model.projs.count.out + ") spawns at location ")
					if p.in_board then
						m.append ("[" + model.rows[pos.first].out + "," + (pos.second - 1).out+ "].%N")
					else
						m.append ("out of board.%N")
					end
					m.append (p.m)
				end
			else
				move_to (pos.first, pos.second - 3)
				if active then
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 20, pos.first, pos.second - 1, 0, -3)
					model.projs.extend (p)

					m.append ("      A enemy projectile(id:-" + model.projs.count.out + ") spawns at location ")
					if p.in_board then
						m.append ("[" + model.rows[pos.first].out + "," + (pos.second - 1).out+ "].%N")
					else
						m.append ("out of board.%N")
					end
					m.append (p.m)
				end
			end
				model.update_enemies_act (m)
		end

	preemptive_action
		local
			p: PROJECTILE
		do
			m.wipe_out
			if model.action_type = 1 then
				regeneration
				move_to (pos.first, pos.second - 6)
				if active then
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 100, pos.first, pos.second - 1, 0, -10)
					model.projs.extend (p)

					ready := false

					m.append ("      A enemy projectile(id:-" + model.projs.count.out + ") spawns at location ")
					if p.in_board then
						m.append ("[" + model.rows[pos.first].out + "," + (pos.second - 1).out+ "].%N")
					else
						m.append ("out of board.%N")
					end
					m.append (p.m)
				end
			elseif model.action_type = 2 then
				armour := armour + 1
				m.append ("    A "+ full_name + "(id:" + id.out + ") gains 1 armour.%N")
			end
			model.update_enemies_act (m)
		end
end
