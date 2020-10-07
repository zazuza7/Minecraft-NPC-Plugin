#Diamond summons an NPC
SpawnNPC:
    type: world
    events:
        on player right clicks air:
        - if <player.item_in_hand.material.name> == bread:
            - create player Mr.Slave <player.location>

#Apple Checks targets Inventory:
    type: world
    events:
        on player right clicks air:
        - if <player.item_in_hand.material.name> == apple:
            - inventory open d:<player.target.inventory>

#Wheat tells NPC to break 8 blocks in front
MarkExcavationSite:
    type: world
    events:
        on player right clicks air:
        - if <player.item_in_hand.material.name> == wheat:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>

            - note <player.cursor_on> as:target
            - walk <location[target]> <[NPC]>
            - wait 1s
            - look <[NPC]> <location[target]>
            - animate <[NPC]> <ARM_SWING>
            - give <location[target].drops.get[1]> to:<[NPC].inventory>
            - modifyblock <location[target]> <air>

            - repeat 2:
                - note <location[target].sub[0,-1,0]> as:target
                - walk <location[target]> <[NPC]>
                - wait 1s
                - look <[NPC]> <location[target]>
                - animate <[NPC]> <ARM_SWING>
                - give <location[target].drops.get[1]> to:<[NPC].inventory>
                - modifyblock <location[target]> <air>
                
                - note <location[target].sub[1,1,0]> as:target
                - walk <location[target]> <[NPC]>
                - wait 1s
                - look <[NPC]> <location[target]>
                - animate <[NPC]> <ARM_SWING>
                - give <location[target].drops.get[1]> to:<[NPC].inventory>
                - modifyblock <location[target]> <air>

            - note <location[target].sub[0,-1,0]> as:target
            - walk <location[target]> <[NPC]>
            - wait 1s
            - look <[NPC]> <location[target]>
            - animate <[NPC]> <ARM_SWING>
            - give <location[target].drops.get[1]> to:<[NPC].inventory>
            - modifyblock <location[target]> <air>

#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks air:
        - if <player.item_in_hand.material.name> == carrot:
            - walk <player.cursor_on> <server.spawned_npcs_flagged[miner].get[1]>

#Pseudo code of mining an infinite path forward
# Break the first block
# while true
# Break above
# Break forward below