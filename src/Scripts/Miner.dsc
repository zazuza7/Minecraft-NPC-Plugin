#Diamond summons an NPC named Mr. Slave
SpawnNPC:
    type: world
    events:
        on player right clicks with bread:
            - create player Mr.Slave <player.location>

#Opens target entity's inventory
ChecksTargetsInventory:
    type: world
    events:
        on player right clicks with apple:
            - inventory open d:<player.target.inventory>

#NPC mines 6 blocks in front and receives them to its inventory
Mine6Blocks:
    type: world
    events:
        on player right clicks with diamonds:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>

            - note <player.cursor_on> as:target
            - run MiningSubScript def:<[NPC]>
            - wait 1.1s

            - repeat 2:
                - note <location[target].sub[0,-1,0]> as:target
                - run MiningSubScript def:<[NPC]>
                - wait 1.1s
                - note <location[target].sub[1,1,0]> as:target
                - run MiningSubScript def:<[NPC]>
                - wait 1.1s

            - note <location[target].sub[0,-1,0]> as:target
            - run MiningSubScript def:<[NPC]>
            - wait 1.1s

#NPC moves towards target block and simulates mining it, while receiving drops to its inventory
#Only starts mining after coming close
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>

        - walk <[NPC].flag[CurrentBlockMined]> <[NPC]>
        - narrate <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]>
        - while <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - narrate <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]>
            - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
            - wait 0.5s
        - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
        - wait 0.3s
        - animate <[NPC]> ARM_SWING
        - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
        - look <[NPC]> <[NPC].flag[CurrentBlockMined]>
        - animate <[NPC]> ARM_SWING
        - give <location[target].drops.get[1]> to:<[NPC].inventory>
        - modifyblock <[NPC].flag[CurrentBlockMined]> air
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:0

#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - walk <player.cursor_on> <server.spawned_npcs_flagged[miner].get[1]>

#A script, which returns assigns a chest to an NPC or tells the NPC to return there
NpcChest:
    type: world
    events:
        on player right clicks with chest:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - if  !<[NPC].has_flag[ChestLocation]>:
                - note <[NPC].location.find.blocks[chest].within[10].get[1]> as:Chest
                - flag <[NPC]> ChestLocation:<[NPC].location.find.blocks[chest].within[10].get[1]>
            - else:
                - walk <[NPC]> <[NPC].flag[ChestLocation]>
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


UpdatedDig:
    type: world
    events:
        on player right clicks with wheat:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
            - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
            - define temp <[NPC].flag[CurrentBlockMined]>
            - narrate <[temp]>
            - flag <[NPC]> CurrentBlockMined:<location[temp]>
            - narrate <[NPC].flag[CurrentBlockMined]>
#{            - ~run MiningSubScript def:<[NPC]>



            - if <player.cursor_on.relative[1,0,0].material.name> == water:
                - narrate "water check successful"

TEST:
    type: world
    events:
        on player right clicks with emerald:
            - narrate <player.target.id>
            - note <player.target.location> as:NPCs<player.target.id>Direction
            - narrate <location[9]>

TEST2:
    type: world
    events:
        on player right clicks with bucket:
            - teleport <player> <location[NPCs9Direction]>

#{            - narrate <player.eye_location.precise_impact_normal>
#{           - note remove as:direction

#Should implement the final version of mining alhorithm
#Pseudo Code

#   WHILE lava/water is NOT above/to the side of target block OR air not in front
#   Dig front
#   If
#   Air nearby(not from dig sides)
#   Or if Lava/water below
#       Put a block (not a wanted one) there
#
# Should implement distance checks
# Should implement torch planting

#Flood, ellipsoid function will help



