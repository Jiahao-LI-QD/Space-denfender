# Background
Many years have passed since the first battle between the creatures of the Void and humankind. Time changes
everything. With the research branch at work, the current iteration of Starfighter feature customizable parts for
weapons, armour and engine, allowing for specialization based on the battlefield. In addition, salvaged parts (orbment
and focus) from the enemy units have allowed for development of special abilities for Starfighters. The countless
engagements with the enemy monsters allowed for a better understanding of them. So far, five different types of
enemy units have been discovered. First is the generic Grunt. Next is the improved version of a Grunt, the Fighter.
We have the large Carrier which releases a torrent of drones known as Interceptor. The Interceptor’s goal is to simply
absorb projectile damage, serving as a shield to other units. Finally, a massive structure called Pylon which heals
surrounding units. The enemy units appear to behave differently based on how the Starfighter acts and whether
they see the Starfighter or not. Your goal is to update the simulation made in the previous lab to accommodate the
new technologies and information. Unfortunately, time travelling is not one of the special abilities developed for the
Starfighter hence there is no need to keep the undo/redo from the previous simulation.

# Vocabulary 
-- Orbment: Can be either a singular orb or a container (focus). Enemies drop orbments when they are destroyed,
and orbment has a different value (score).

–- Focus: A container for orbments. Starfighter has one focus with an unlimited capacity. On the other hand,
the focus an enemy drops has a limited capacity, and its score is amplified when filled (see Section 6.15 for how
scoring works).

# Symbols:
Below are a list of symbols that may appear on the board.
–- ?: This symbol only shows up in normal mode. It represents the fog of war meaning from the perspective of the
Starfighter, the location is too far away for the Starfighter to see what entity is in that location.
–- : This symbol means the location is not occupied by any entity.
–- G : This symbol means the location is occupied by a Grunt.
-– F : This symbol means the location is occupied by a Fighter.
-– C : This symbol means the location is occupied by a Carrier.
–- I : This symbol means the location is occupied by a Interceptor.
-– P : This symbol means the location is occupied by a Pylon.
–- < : This symbol means the location is occupied by an enemy projectile (fired by some kinds of enemies).
-– S : This symbol means the location is occupied by the Starfighter (which fires friendly projectiles).
–- * : This symbol means the location is occupied by a friendly projectile.
–- X : This symbol means the location is where the Starfighter was destroyed. This symbol is only present when
the game is over due to destruction of the Starfighter.

# Operations
refer to Instruction 6.5-6.14
