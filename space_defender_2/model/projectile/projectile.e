note
	description: "Summary description for {PROJECTILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PROJECTILE

inherit
	OBJECT
		rename
			make as make_empty
		end

feature
	damage: INTEGER
	model: GAME
	m: STRING
	type : INTEGER
	pos: PAIR[INTEGER,INTEGER]
	move_method: PAIR[INTEGER,INTEGER]
feature
	make(i, t ,d, r, c, a, b: INTEGER)
		local
			ga: GAME_ACCESS
		do
			create m.make_empty
			id := i
			occupied := true
			active := true
			damage:= d
			create pos.make(r,c)
			create move_method.make(a,b)
			model:= ga.m
			type := t

		end

	change_damage(d:INTEGER)
		do
			damage := damage + d
		end

	move
		deferred
		end

	collide(o:OBJECT):BOOLEAN
		deferred
		end

	in_board: BOOLEAN
		local
			r, c:INTEGER
		do
			r:= pos.first
			c:= pos.second
			if r < 1 or r > model.max_r or c < 1 or c > model.max_c then
				Result := false
			else
				Result := true
			end
		end

	display:STRING
		do
			create Result.make_empty
			Result.append ("    [" + id.out + "," + content.out + "]->")
			Result.append ("damage:" + damage.out + ", ")
			Result.append ("move:" + move_method.second.abs.out + ", ")
			Result.append ("location:[" + model.rows[pos.first].out + "," + pos.second.out+ "]%N")

		end
end
