#Item which spawns and controls NPCs
Whip:
    type: item
    material: book--
    display name: Whip
    lore:
        - "An item Rolandas the Great created to rule the universe"
        - "An item left behind by the gods who have created our universe "

#Spawns a NPC or selects one if aimed at
OnLeftClickWhip:
    type: world
    events:
        on player left clicks with Whip:
            - if <player.target.has_flag[Role]>:
                - flag <player> Selected:<player.target>
            - else:
                - create player Mr.Slave <player.location>
                - flag <player.target> miner
                - flag <player.target> Role:Undefined
                - flag <player.target> Owner:<player>
                - flag <player> Selected:<player.target>

#If aimed at NPC, opens its inventory
#Else if aimed at chest, links it with currently selected NPC
#Else if aimed at a block, starts mining
OnRightClickWhip:
    type: world
    events:
        on player right clicks with Whip:
            - define NPC <player.flag[Selected].as_npc>
            - if <player.target.has_flag[role]>:
                - inventory open d:<player.target.inventory>
            - else if <player.location.distance[<[NPC].location>]> <= 25:

                - if <player.cursor_on.has_inventory> || <player.cursor_on.material.name> == ender_chest:

                    - if  !<[NPC].has_flag[ChestLocation]> || !<[NPC].flag[ChestLocation].as_location.has_inventory>:
                        - flag <[NPC]> ChestLocation:<player.cursor_on>
                        - narrate "Chest Linked succesfully"
                        - ~walk <[NPC]> <[NPC].flag[ChestLocation]>
                        - run Deposit def:<[NPC]>
#{ Is this necessary? Don't rly see a point
                    - else:
                        - narrate "NPC already linked"
                        - walk <[NPC]> <[NPC].flag[ChestLocation]>
#{ If NPC is miner type
                - else if <[NPC].inventory.slot[36].material.name> == wooden_pickaxe:
                    - run MiningTask def:<[NPC]>
                    - narrate "Lets go work"
            - else:
                - narrate "No selected NPCs found nearby"