#Diamond summons an NPC named Mr. Slave
SpawnNPC:
    type: world
    events:
        on player right clicks with bread:
            - despawn <player.target>
            - create player Mr.Slave <player.location>
            - flag <player.target> miner
            

#Opens target entity's inventory
ChecksTargetsInventory:
    type: world
    events:
        on player right clicks with apple:
            - inventory open d:<player.target.inventory>


#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - walk <player.cursor_on.above> <server.spawned_npcs_flagged[miner].get[1]>

#A script, which returns assigns a chest to an NPC or tells the NPC to return there
# <[NPC].location.find.blocks[chest].within[10].get[1]> works differently than <player.cursor_on>
# This causes issues.....
NpcChest:
    type: world
    events:
        on player right clicks with chest:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - if  !<[NPC].has_flag[ChestLocation]>:
                - flag <[NPC]> ChestLocation:<[NPC].location.find.blocks[chest].within[10].get[1]>
            - else:
                - narrate <[NPC].flag[ChestLocation]>
                - walk <[NPC].flag[ChestLocation]> <[NPC]>
                - animatechest <[NPC].flag[ChestLocation]>
                - look <[NPC]> <[NPC].flag[ChestLocation]>
                - wait 3s
                - animatechest <[NPC].flag[ChestLocation]> close



#Deposits all items in a.yml config file to a chest
Narrate:
    type: world
    events:
        on player right clicks with cooked_beef:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - define Chest <[NPC].flag[ChestLocation]>
            - foreach <yaml[a].read[items]> as:item:
                - narrate <[NPC].inventory.quantity.material[<[item]>]>
                - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<location[Chest].inventory>
                - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
                - narrate <[item]>
                - wait 1s

#.as_location returns a location from an element type
UpdatedDig:
    type: world
    events:
        on player right clicks with wheat:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
            - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
            - flag <[NPC]> Status:Mine

            - repeat 10:

                - run CheckingSubScript def:<[NPC]>
                - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
                - ~run MiningSubScript def:<[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>

                - run CheckingSubScript def:<[NPC]>
                - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
                - ~run MiningSubScript def:<[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>

            - narrate "I'm done sir"

#{            - walk <[NPC]> <[NPC].flag[ChestLocation]>

#NPC moves towards target block and simulates mining it, while receiving drops to its inventory
#Only starts mining after coming close
#Should check for distance and stop
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - if <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - walk <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location>]> <[NPC]>
        - run DistanceCheck
        - while <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - wait 1s
        - look <[NPC]> <[NPC].flag[CurrentBlockMined]> duration:1s
        - wait 0.3s
#{        - animate <[NPC]> ARM_SWING
#{        - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
#{        - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
#{        - animate <[NPC]> ARM_SWING
#{        - give <[NPC].flag[CurrentBlockMined].as_location.drops.get[1]> to:<[NPC].inventory>
        - modifyblock <[NPC].flag[CurrentBlockMined]> air
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:0

#Checks whether there is danger while mining and changes status of NPC if necessary
#Doesnt work
CheckingSubScript:
    type: task
    script:
        - define NPC <[1]>
        - narrate <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>]>
        - if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].material.name> == air: 
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].material.name> == lava:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].material.name> == water:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.material.name> == lava:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.material.name> == water:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].material.name> == lava:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].material.name> == water:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].material.name> == lava:
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].material.name> == water:
            - flag <[NPC]> Status:Stop
            - stop

DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - wait 10s
        - if <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - flag <[NPC]> Status:Stop



#Autorange - range at which npc teleports
#I should look into queues, probably movement issues stem from there!!!
#Should implement torch planting

#Flood, ellipsoid function might help



