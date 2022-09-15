note
	description: "Summary description for {ENEMY_FOCUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENEMY_FOCUS

inherit
	COMPOSITE_ORBMENT
		redefine
			value
		end
feature
	multiplier:INTEGER
	max_n: INTEGER

	make
		do
			create {LINKED_LIST[ORBMENT]} children.make
		end

	available: BOOLEAN
		do
			Result := children.count < max_n or else (attached {ENEMY_FOCUS} children[children.count] as f and then f.available)
		end

	value:INTEGER
		do
			Result := Precursor
			if is_full then
				Result := Result * multiplier
			end
		end

	is_full:BOOLEAN
		do
			Result := children.count = max_n
		end
end
