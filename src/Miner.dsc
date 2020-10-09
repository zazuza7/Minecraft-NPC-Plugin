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
            - note <[NPC].location.find.blocks[chest].within[10].get[1]> as:Chest
            - walk <[NPC]> <location[Chest]>
#Pseudo Code
#Note chest
#Check every slot of chest
#   If you have same item in your inv
#       Transfer it

# Should implement torch planting as well

#Should implement nearby block checking for ore  and for dangers
# ex narrate <player.inventory.contains.material[gold_ore]>
# <inventory.slot[1]>