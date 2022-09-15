note
	description: "Summary description for {PYLON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PYLON
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
			content := 'P'
			max_health := 300
			h_r := 0
			armour := 0
			vision := 5
			health := max_health
			Precursor(i, r, c)
			create {PLATINUM} orb.make
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
					create {PROJ_E} p.make (0-model.projs.count-1, 0, 70, pos.first, pos.second - 1, 0, -2)
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
					across model.enemies is e loop
					--The Pylon heals <enemy name>(id:<id>) at location [X,Y] for 10 damage."
						if e.active and in_vision (e.pos.first, e.pos.second) then
							e.heal(10)
							m.append ("      The Pylon heals " + e.full_name + "(id:"+e.id.out+") at location ")
							m.append ("[" + model.rows[e.pos.first].out + "," + (e.pos.second).out+ "] for 10 damage.%N")
						end
					end
				end

			end
				model.update_enemies_act (m)
		end

	in_vision(r, c:INTEGER):BOOLEAN
		do
			Result := (pos.first - r).abs + (pos.second - c).abs <= vision
		end

	preemptive_action
		do
			m.wipe_out
		end
end
