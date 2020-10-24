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
        - if <player.item_in_hand.material.name> == wheat:
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

MiningSubScript:
    type: task
    script:
        - walk <location[target]> <[1]>
        - wait 0.5s
        - animate <[1]> ARM_SWING
        - look <[1]> <location[target]>
        - blockcrack <location[target]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
        - look <[1]> <location[target]>
        - animate <[1]> ARM_SWING
        - give <location[target].drops.get[1]> to:<[1].inventory>
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




#Should implement the final version of mining alhorithm
#Pseudo Code

#   WHILE lava/water is NOT above/to the side of target block OR air not in front
#   Dig front
#   If
#   Air nearby(not from dig sides)
#   Or if Lava/water below
#       Put a block (not a wanted one) there
#

# Should implement torch planting






