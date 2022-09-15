note
	description: "Summary description for {GRUNT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GRUNT
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
			content := 'G'
			max_health := 100
			h_r := 1
			armour := 1
			vision := 5
			health := max_health
			Precursor(i, r, c)
			create {SLIVER} orb.make
		end

	preemptive_action
		do
--    A Grunt(id:1) gains 20 total health.
			m.wipe_out
			if model.action_type = 1 then
				max_health:= max_health + 10
				health := health + 10
				model.update_enemies_act ("    A Grunt(id:" + id.out + ") gains 10 total health.%N")
			elseif model.action_type = 4 then
				max_health:= max_health + 20
				health := health + 20
				model.update_enemies_act ("    A Grunt(id:" + id.out + ") gains 20 total health.%N")
			end
		end

	action
		local
			p: PROJECTILE
		do
			m.wipe_out
			regeneration
			if can_see_starfighter then
--      A enemy projectile(id:-1) spawns at location [A,27].
				move_to (pos.first, pos.second - 4)
				if active then
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 15, pos.first, pos.second - 1, 0, -4)
					model.projs.extend (p)

					m.append ("      A enemy projectile(id:-" + model.projs.count.out + ") spawns at location ")
					if p.in_board then
						m.append ("[" + model.rows[pos.first].out + "," + (pos.second - 1).out+ "].%N")
					else
						m.append ("out of board.%N")
					end
					m.append(p.m)
				end
			else
				move_to (pos.first, pos.second - 2)
				if active then
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 15, pos.first, pos.second - 1, 0, -4)
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
end
