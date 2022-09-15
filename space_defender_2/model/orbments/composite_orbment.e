note
	description: "Summary description for {COMPOSITE_ORBMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	COMPOSITE_ORBMENT
inherit
	ORBMENT
	COMPOSITE[ORBMENT]
feature
	value:INTEGER
		do
			across children is o loop Result := Result + o.value  end
		end

	add (o: ORBMENT)
		do
			if children.count /= 0 and then attached {ENEMY_FOCUS} children[children.count] as f and then f.available then
				f.add (o)
			else
				children.extend (o)
			end
		end
end
