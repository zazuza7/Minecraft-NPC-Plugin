
#Diamond spawns NPC
SpawnNPC:
    type: world
    events:
        on player left clicks air:
        - if <player.item_in_hand.material.name> == diamond:
            - create player Slave <player.location>

SetNPCasMiner:
    type: world
    events:
        on click:
            - narrate yay
            - ex npc sel
            - flag npc miner
              
#Wheat tells NPC to break
MarkExcavationSite:
    type: world
    events:
        on player left clicks air:
        - if <player.item_in_hand.material.name> == wheat:
            - break <player.cursor_on> <server.spawned_npcs_flagged[miner].get[1]> radius:4
            - define target <player.cursor_on>
            - while true :
                - wait 2s
                - define target <[target].sub[0,-1,0]>
                - break <[target]> <server.spawned_npcs_flagged[miner].get[1]> radius:4
                - wait 2s
                - define target <[target].sub[1,1,0]>
                - break <[target]> <server.spawned_npcs_flagged[miner].get[1]> radius:4

#Carrot tells NPC to walk
NPCGoBreakShit:
    type: world
    events:
        on player left clicks air:
        - if <player.item_in_hand.material.name> == carrot:
            - walk <player.cursor_on> <server.spawned_npcs_flagged[miner].get[1]>


#Pseudo code of mining an infinite path forward
# Break the first block
# while true
# Break above
# Break forward below
# 




