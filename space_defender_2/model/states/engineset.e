note
	description: "Summary description for {ENGINESET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINESET
inherit
	STATE
		redefine
			make
		end
create
	make

feature
	make
		do
			Precursor
			m.append ("  1:Standard%N" +
					"    Health:10, Energy:60, Regen:0/2, Armour:1, Vision:12, Move:8, Move Cost:2%N" +
					"  2:Light%N" +
					"    Health:0, Energy:30, Regen:0/1, Armour:0, Vision:15, Move:10, Move Cost:1%N" +
					"  3:Armoured%N" +
					"    Health:50, Energy:100, Regen:0/3, Armour:3, Vision:6, Move:4, Move Cost:5%N")

			ms.force ("Standard", ms.count + 1)
			ms.force ("Light", ms.count + 1)
			ms.force ("Armoured", ms.count + 1)
		end

	display:STRING
		do
			create Result.make_from_string (m)
			Result.append (choice_message)
		end

	choice_message: STRING
		do
			create Result.make_from_string ("  Engine Selected:" + ms[answer])
		end

	valid_choice(c:INTEGER):BOOLEAN
		do
			Result := c > 0 and c <= ms.count
		end
end
