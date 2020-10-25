#Diamond summons an NPC
SpawnNPC:
    type: world
    events:
        on player right clicks:
        - if <player.item_in_hand.material.name> == bread:
            - create player Mr.Slave <player.location>

ChecksTargetsInventory:
    type: world
    events:
        on player right clicks:
        - if <player.item_in_hand.material.name> == apple:
            - inventory open d:<player.target.inventory>

#NPC mines 6 blocks in front and receives them to its inventory
Mine6Blocks:
    type: world
    events:
        on player right clicks:
        - if <player.item_in_hand.material.name> == diamonds:
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

        - walk <location[target]> <[NPC]>
        - narrate <[NPC].location.distance[<location[target]>]>
        - while <[NPC].location.distance[<location[target]>]> > 3.5:
            - narrate <[NPC].location.distance[<location[target]>]>
            - look <[NPC]> <location[target]>
            - wait 0.5s
        - look <[NPC]> <location[target]>
        - wait 0.3s
        - animate <[NPC]> ARM_SWING
        - look <[NPC]> <location[target]>
        - blockcrack <location[target]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
        - look <[NPC]> <location[target]>
        - animate <[NPC]> ARM_SWING
        - give <location[target].drops.get[1]> to:<[NPC].inventory>
        - modifyblock <location[target]> air
        - blockcrack <location[target]> progress:0

#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks:
        - if <player.item_in_hand.material.name> == carrot:
            - walk <player.cursor_on> <server.spawned_npcs_flagged[miner].get[1]>

#A script, which going to return the npc to itsd starter chest and deposit its items there
#Cant manage to implement distance checks
NpcChest:
    type: world
    events:
        on player right clicks:
        - define NPC <server.spawned_npcs_flagged[miner].get[1]>
        - if <player.item_in_hand.material.name> == chest:
            - if <location[Chest]||invalid> == invalid:
                - note <[NPC].location.find.blocks[chest].within[10].get[1]> as:Chest
            - else:
                - walk <[NPC]> <location[Chest]>
                - animatechest <location[Chest]>
                - look <[NPC]> <location[Chest]>
                - wait 3s
                - animatechest <location[Chest]> close



#Deposits all items in a.yml config file to a chest WORKS

Narrate:
    type: world
    events:
        on player right clicks:
        - define NPC <server.spawned_npcs_flagged[miner].get[1]>
        - if <player.item_in_hand.material.name> == cooked_beef:
            - foreach <yaml[a].read[items]> as:item:
                - narrate <[NPC].inventory.quantity.material[<[item]>]>
                - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<location[Chest].inventory>
                - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
                - narrate <[item]>
                - wait 1s
#Notation of direction doesnt work, worked before trying to define/note it. Need more iq to solve this
UpdatedDig:
    type: world
    events:
        on player right clicks:
        - if <player.item_in_hand.material.name> == wheat:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - note <player.eye_location.precise_impact_normal> as:direction
            - note <player.cursor_on> as:target
            - ~run MiningSubScript def:<[NPC]>
            - repeat 2:
                - narrate <location[direction]>
                - note <location[target].add[0,1,0]> as:target
                - ~run MiningSubScript def:<[NPC]>
                - note <location[target].sub[location[direction]].sub[0,1,0]> as:target
                - ~run MiningSubScript def:<[NPC]>
            
            - note <location[target].add[0,1,0]> as:target
            - ~run MiningSubScript def:<[NPC]>


            - if <player.cursor_on.relative[1,0,0].material.name> == water:
                - narrate "water check successful"

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



