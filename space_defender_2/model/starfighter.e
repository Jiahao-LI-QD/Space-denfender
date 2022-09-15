note
	description: "Summary description for {STARFIGHTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STARFIGHTER

inherit
	OBJECT
		rename
			make as make_empty
		end

create
	make

feature -- attributes
	max_health: INTEGER
	max_energy: INTEGER
	h_r: INTEGER
	e_r: INTEGER
	armour: INTEGER
	vision: INTEGER
	move: INTEGER
	movecost: INTEGER

	health: INTEGER
	energy: INTEGER
	pos: PAIR[INTEGER, INTEGER]
	destroyed: BOOLEAN
	focus: FOCUS
feature -- information
	weapons: ARRAY[STRING]

feature -- setment routines
	make(r:INTEGER; c:INTEGER)
		do
			id := 0
			occupied := true
			active:= true
			content:= 'S'
			create pos.make(r,c)
			create weapons.make_empty
			create {FOCUS} focus.make
			weapons.force ("Standard, Projectile Damage:70, Projectile Cost:5 (energy)", 1)
			weapons.force ("Spread, Projectile Damage:50, Projectile Cost:10 (energy)", 2)
			weapons.force ("Snipe, Projectile Damage:1000, Projectile Cost:20 (energy)", 3)
			weapons.force ("Rocket, Projectile Damage:100, Projectile Cost:10 (health)", 4)
			weapons.force ("Splitter, Projectile Damage:150, Projectile Cost:70 (energy)", 5)
		end

	set_position(r:INTEGER; c:INTEGER)
		do
			pos.make(r,c)
		end

	add_all(h, e, hr, er, a, v, m, mc:INTEGER)
		do
			max_health:= max_health + h
			max_energy:= max_energy + e
			h_r:= h_r + hr
			e_r:= e_r + er
			armour:= armour + a
			vision:= vision + v
			move:= move + m
			movecost:= movecost + mc
		end

	move_cost(r,c:INTEGER):INTEGER
		do
			Result := ((pos.first - r).abs + (pos.second - c).abs) * movecost
		end

	affordable(e:INTEGER): BOOLEAN
		do
			Result := energy >= e
		end

	spend(e:INTEGER)
		do
			energy := energy - e
		end

	charge(e:INTEGER)
		do
			energy := energy + e
		end

	damage(d:INTEGER)
		do
			health := health - d
		end

	heal(d:INTEGER)
		do
			health := health + d
		end

	collide_p(p:PROJECTILE)
		do
-------------------------------------
			p.inactive
			if p.damage > armour then
				health := health - p.damage + armour
			end
			if health <= 0 then
				star_over
			end
		end

	collide_e(e:ENEMY)
		do
-----------------------------------
			health := health - e.health
			e.enemy_over
			if health <= 0 then
				star_over
			end
		end

	star_over
		do
			content:= 'X'
			health := 0
			destroyed:= true
		end

	fire_cost:PAIR[INTEGER, BOOLEAN]
	-- number of cost, true is the energy cost, false is the health cost
		local
			ga: GAME_ACCESS
			g: GAME
			t : INTEGER
		do
			create Result.make(0,false)
			g := ga.m
			t := g.state.states[1].answer
			if t = 1 then
				Result.make (5, true)
			elseif t = 2 then
				Result.make (10, true)
			elseif t = 3 then
				Result.make (20, true)
			elseif t = 4 then
				Result.make (10, false)
			elseif t = 5 then
				Result.make (70, true)
			end
		end

	special_cost: PAIR[INTEGER, BOOLEAN]
	-- number of cost, true is the energy cost, false is the health cost
		local
			ga: GAME_ACCESS
			g: GAME
			t : INTEGER
		do
			create Result.make(0,false)
			g := ga.m
			t := g.state.states[4].answer
--  1:Recall (50 energy): Teleport back to spawn.
--  2:Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.
--  3:Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.
--  4:Deploy Drones (100 energy): Clear all projectiles.
--  5:Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.
			if t = 1 then
				Result.make (50, true)
			elseif t = 2 then
				Result.make (50, true)
			elseif t = 3 then
				if health > 50 then
					Result.make (50, false)
				else
					Result.make (health - 1, false)
				end
			elseif t = 4 then
				Result.make (100, true)
			elseif t = 5 then
				Result.make (100, true)
			end
		end

feature -- command
	regeneration
		do
			if health < max_health then
				heal(h_r)
				if health > max_health then
					health_to_max
				end
			end

			if energy < max_energy then
				charge(e_r)
				if energy > max_energy then
					energy_to_max
				end
			end
		end

	pass
		local
			ga: GAME_ACCESS
			g: GAME
		do
			g := ga.m
			regeneration
			regeneration
			g.update_star_act ("    The Starfighter(id:" + id.out + ") passes at ")
			g.update_star_act ("location [" + g.rows[pos.first].out + "," + pos.second.out+ "], doubling regen rate.%N")
		end

	fire
		local
			ga: GAME_ACCESS
			g: GAME
			t : INTEGER
			p: PROJECTILE
		do
			regeneration
			g := ga.m
			t := g.state.states[1].answer
			g.update_star_act ("    The Starfighter(id:" + id.out + ") fires at location ")
			g.update_star_act ("[" + g.rows[pos.first].out + "," + pos.second.out+ "].%N")
			if t = 1 then
				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 70, pos.first, pos.second + 1, 0, 5)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.projs.extend (p)
				g.update_star_act (p.m)
				spend(fire_cost.first)
			elseif t = 2 then
				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 50, pos.first - 1, pos.second + 1, -1, 1)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first - 1].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act (p.m)

				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 50, pos.first, pos.second + 1, 0, 1)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act (p.m)

				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 50, pos.first + 1, pos.second + 1, 1, 1)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first + 1].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act (p.m)

				spend(fire_cost.first)
			elseif t = 3 then
				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t,1000, pos.first, pos.second + 1, 0, 8)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act(p.m)
				spend(fire_cost.first)
			elseif t = 4 then

				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 100, pos.first - 1, pos.second - 1, 0, 1)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first - 1].out + "," + (pos.second - 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act(p.m)


				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 100, pos.first + 1, pos.second - 1, 0, 1)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first + 1].out + "," + (pos.second - 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act(p.m)

				damage(fire_cost.first)
			elseif t = 5 then
				g.update_star_act ("      A friendly projectile(id:-" + (g.projs.count + 1).out + ") spawns at location ")
				create {PROJ_F} p.make (0 - g.projs.count - 1, t, 150, pos.first, pos.second + 1, 0, 0)
				g.projs.extend (p)
				if p.in_board then
					g.update_star_act ("[" + g.rows[pos.first].out + "," + (pos.second + 1).out+ "].%N")
				else
					g.update_star_act ("out of board.%N")
				end
				g.update_star_act (p.m)
				spend(fire_cost.first)
			end

		end

	move_to(r, c: INTEGER)
		local
			ga: GAME_ACCESS
			g: GAME
			i :INTEGER
			m: STRING
			old_pos: like pos
		do
			regeneration
			g := ga.m
			create old_pos.make_from_tuple (pos)
			create m.make_empty
			g.board.put (create {OBJECT}.make, pos.first, pos.second)
			from
				i := old_pos.first
			until
				i = r or destroyed
			loop
				if old_pos.first > r then
					i := i - 1
				else
					i := i + 1
				end
				if attached g.board[i,pos.second] as o then

					pos.make (i, old_pos.second)
					if o.occupied then
						if o.id < 0 and then attached {PROJECTILE} o as p then
							collide_p (p)
							-- The Starfighter collides with enemy projectile(id:-3) at location [A,1], taking 14 damage.
							m.append("      The Starfighter collides with ")
							if p.type = 0 then
								m.append ("enemy ")
							else
								m.append ("friendly ")
							end
							m.append ("projectile(id:" + p.id.out + ") at location ")
							m.append ("[" + g.rows[pos.first].out + "," + pos.second.out+ "], taking " + (p.damage - armour).out + " damage.%N")
						elseif attached {ENEMY} o as e then
							-- The Starfighter collides with <enemy name>(id:<id>) at location [X,Y], trading <enemy current health> damage.
							m.append ("      The Starfighter collides with " + e.full_name)
							m.append ("(id:" + e.id.out + ") at location ")
							m.append ("[" + g.rows[pos.first].out + "," + pos.second.out+ "], trading " + e.health.out + " damage.%N")
							m.append ("      The " + e.full_name + " at location ["+ g.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
							collide_e (e)
						end
						if health <= 0 then
							m.append ("      The Starfighter at location [" + g.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
						end
						g.board.put (create {OBJECT}.make, i, old_pos.second)
					end

				end
			end

			from
				i := old_pos.second
			until
				i = c or destroyed
			loop
				if old_pos.second > c then
					i := i - 1
				else
					i := i + 1
				end

				if attached g.board[r,i] as o then

					pos.make (r, i)
					if o.occupied then
						if o.id < 0 and then attached {PROJECTILE} o as p then
							collide_p (p)
							-- The Starfighter collides with enemy projectile(id:-3) at location [A,1], taking 14 damage.
							m.append("      The Starfighter collides with ")
							if p.type = 0 then
								m.append ("enemy ")
							else
								m.append ("friendly ")
							end
							m.append ("projectile(id:" + p.id.out + ") at location ")
							m.append ("[" + g.rows[pos.first].out + "," + pos.second.out+ "], taking " + (p.damage - armour).out + " damage.%N")
						elseif attached {ENEMY} o as e then
							-- The Starfighter collides with <enemy name>(id:<id>) at location [X,Y], trading <enemy current health> damage.
							m.append ("      The Starfighter collides with " + e.full_name)
							m.append ("(id:" + e.id.out + ") at location ")
							m.append ("[" + g.rows[pos.first].out + "," + pos.second.out+ "], trading " + e.health.out + " damage.%N")
							-- The Grunt at location [A,6] has been destroyed.
							m.append ("      The " + e.full_name + " at location ["+ g.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
							collide_e (e)
						end
						if health <= 0 then
							m.append ("      The Starfighter at location [" + g.rows[pos.first].out + "," + pos.second.out+ "] has been destroyed.%N")
						end
						g.board.put (create {OBJECT}.make, r, i)
					end
				end
			end
			g.board.put (current, pos.first, pos.second)
			spend(move_cost(old_pos.first,old_pos.second))
			--The Starfighter(id:0) moves: [A,1] -> [C,5]
			g.update_star_act ("    The Starfighter(id:" + id.out + ") moves: ")
			g.update_star_act ("[" + g.rows[old_pos.first].out + "," + old_pos.second.out+ "] -> ")
			g.update_star_act ("[" + g.rows[pos.first].out + "," + pos.second.out+ "]%N")
			g.update_star_act (m)
		end

	special
		local
			ga: GAME_ACCESS
			g: GAME
			t : INTEGER
		do
			regeneration
			g := ga.m
			t := g.state.states[4].answer
--  1:Recall (50 energy): Teleport back to spawn.
--  2:Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.
--  3:Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.
--  4:Deploy Drones (100 energy): Clear all projectiles.
--  5:Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.
--The Starfighter(id:0) uses special,
			g.update_star_act ("    The Starfighter(id:" + id.out + ") uses special, ")
			if t = 1 then
				g.board.put (create {OBJECT}.make, pos.first, pos.second)
				if g.board[g.max_r // 2 + g.max_r \\ 2 , 1].occupied then
					if g.board[g.max_r // 2 + g.max_r \\ 2, 1].id < 0 and then attached {PROJECTILE} g.board[g.max_r // 2 + g.max_r \\ 2, 1] as p then
						collide_p (p)
					elseif attached {ENEMY} g.board[g.max_r // 2 + g.max_r \\ 2, 1] as e then
						collide_e (e)
					end
				end
				set_position (g.max_r // 2 + g.max_r \\ 2, 1)
				g.board.put (current, pos.first, pos.second)
				spend(special_cost.first)
				g.update_star_act ("teleporting to: [" + g.rows[pos.first].out + "," + pos.second.out+ "]%N")
			elseif t = 2 then
				heal (50)
				spend(special_cost.first)
				g.update_star_act ("gaining 50 health.%N")
			elseif t = 3 then
				g.update_star_act ("gaining "+ (special_cost.first*2).out +" energy at the expense of "+ special_cost.first.out +" health.%N")
				charge(2 * special_cost.first)
				damage(special_cost.first)
			elseif t = 4 then
				g.update_star_act ("clearing projectiles with drones.%N")
				across g.projs is p loop
					if p.active then
						g.board.put (create {OBJECT}.make, p.pos.first, p.pos.second)
						g.update_star_act ("      A projectile(id:" + p.id.out + ") at location ")
						g.update_star_act ("[" + g.rows[p.pos.first].out + "," + p.pos.second.out+ "] has been neutralized.%N")
						p.inactive
					end
				end
				spend(special_cost.first)
			elseif t = 5 then
				g.update_star_act ("unleashing a wave of energy.%N")
				across g.enemies is e loop
					if e.active then
						e.damage(100 - e.armour)
						--A Grunt(id:1) at location [A,26] takes 99 damage.
						g.update_star_act ("      A " + e.full_name)
						g.update_star_act ("(id:" + e.id.out + ") at location ")
						g.update_star_act ("[" + g.rows[e.pos.first].out + "," + e.pos.second.out+ "] takes "+(100 - e.armour).out+" damage.%N")
						if e.health <= 0 then
							e.enemy_over
							--The Interceptor at location [A,27] has been destroyed.
							g.update_star_act ("      The " + e.full_name)
							g.update_star_act (" at location ")
							g.update_star_act ("[" + g.rows[e.pos.first].out + "," + e.pos.second.out+ "] has been destroyed.%N")
							g.board.put (create {OBJECT}.make, e.pos.first, e.pos.second)
						end
					end
				end
				spend(special_cost.first)
			end
		end

	reset
		do
			max_health:= 0
			max_energy:= 0
			h_r:= 0
			e_r:= 0
			armour:= 0
			vision:= 0
			move:= 0
			movecost:= 0
			destroyed := false
			create {FOCUS} focus.make
			content:= 'S'
		end

	health_to_max
		do
			health := max_health
		end

	energy_to_max
		do
			energy := max_energy
		end

	equip
		local
			ga: GAME_ACCESS
			g: GAME
		do
			g:= ga.m
			set_position (g.max_r // 2 + g.max_r \\ 2, 1)
			if attached g.state.states[1].answer as a then
				if a = 1 then
					-- Health:10, Energy:10, Regen:0/1, Armour:0, Vision:1, Move:1, Move Cost:1
					add_all (10, 10, 0, 1, 0, 1, 1, 1)
				elseif a = 2 then
					-- Health:0, Energy:60, Regen:0/2, Armour:1, Vision:0, Move:0, Move Cost:2
					add_all (0, 60, 0, 2, 1, 0, 0, 2)
				elseif a = 3 then
					-- Health:0, Energy:100, Regen:0/5, Armour:0, Vision:10, Move:3, Move Cost:0
					add_all (0, 100, 0, 5, 0, 10, 3, 0)
				elseif a = 4 then
					-- Health:10, Energy:0, Regen:10/0, Armour:2, Vision:2, Move:0, Move Cost:3
					add_all (10, 0, 10, 0, 2, 2, 0, 3)
				elseif a = 5 then
					-- Health:0, Energy:100, Regen:0/10, Armour:0, Vision:0, Move:0, Move Cost:5
					add_all (0, 100, 0, 10, 0, 0, 0, 5)
				end
			end

			if attached g.state.states[2].answer as a then
				if a = 1 then
					-- Health:50, Energy:0, Regen:1/0, Armour:0, Vision:0, Move:1, Move Cost:0
					add_all (50, 0, 1, 0, 0, 0, 1, 0)
				elseif a = 2 then
					-- Health:75, Energy:0, Regen:2/0, Armour:3, Vision:0, Move:0, Move Cost:1
					add_all (75, 0, 2, 0, 3, 0, 0, 1)
				elseif a = 3 then
					-- Health:100, Energy:0, Regen:3/0, Armour:5, Vision:0, Move:0, Move Cost:3
					add_all (100, 0, 3, 0, 5, 0, 0, 3)
				elseif a = 4 then
					-- Health:200, Energy:0, Regen:4/0, Armour:10, Vision:0, Move:-1, Move Cost:5
					add_all (200, 0, 4, 0, 10, 0, -1, 5)
				end
			end

			if attached g.state.states[3].answer as a then
				if a = 1 then
					-- Health:10, Energy:60, Regen:0/2, Armour:1, Vision:12, Move:8, Move Cost:2
					add_all (10, 60, 0, 2, 1, 12, 8, 2)
				elseif a = 2 then
					-- Health:0, Energy:30, Regen:0/1, Armour:0, Vision:15, Move:10, Move Cost:1
					add_all (0, 30, 0, 1, 0, 15, 10, 1)
				elseif a = 3 then
					-- Health:50, Energy:100, Regen:0/3, Armour:3, Vision:6, Move:4, Move Cost:5
					add_all (50, 100, 0, 3, 3, 6, 4, 5)
				end
			end
			health_to_max
			energy_to_max
		end

feature -- query

	in_vision(r, c:INTEGER):BOOLEAN
		do
			Result := (pos.first - r).abs + (pos.second - c).abs <= vision
		end

	score: INTEGER
		do
			RESULT := focus.value
		end

	display: STRING
		local
			ga: GAME_ACCESS
			g: GAME
		do
		--	health:70/70, energy:70/70, Regen:1/3, Armour:1,
		--	Vision:13, Move:10, Move Cost:3, location:[E,1]
			g := ga.m
			create Result.make_from_string ("  Starfighter:%N")
			Result.append ("    [0,S]->")
			Result.append ("health:" + health.out + "/" + max_health.out + ", ")
			Result.append ("energy:" + energy.out + "/" + max_energy.out + ", ")
			Result.append ("Regen:" +h_r.out + "/" + e_r.out + ", ")
			Result.append ("Armour:" + armour.out + ", ")
			Result.append ("Vision:" + vision.out + ", ")
			Result.append ("Move:" + move.out + ", ")
			Result.append ("Move Cost:" + movecost.out + ", ")
			Result.append ("location:[" + g.rows[pos.first].out + "," + pos.second.out+ "]%N")

			Result.append ("      Projectile Pattern:" + weapons[g.state.states[1].answer] + "%N")
			Result.append ("      Power:" + g.state.states[4].ms[g.state.states[4].answer] + "%N")
			Result.append ("      score:" + score.out + "%N")
		end
end
