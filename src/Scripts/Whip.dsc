#Item which spawns and controls NPCs
Whip:
    type: item
    material: book
    display name: Whip
    lore:
        - "An item Rolandas the Great created to rule the mortals"
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
                - flag <player> Selected:<player.target>
                - adjust <player.target> Owner:<player>
                - adjust <player.target> Teleport_on_Stuck:false
                - vulnerable npc:<player.target>

                

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
            - else if <player.location.distance[<[NPC].location>]> <= 100:

                - if <player.cursor_on.has_inventory> || <player.cursor_on.material.name> == ender_chest:
                    - flag <[NPC]> ChestLocation:<player.cursor_on>
                    - narrate "Chest Linked succesfully"
                    - ~walk <[NPC]> <[NPC].flag[ChestLocation]> auto_range
                    - run Deposit def:<[NPC]>
#{ If NPC is miner type
                - else if <[NPC].inventory.slot[36].material.name> == wooden_pickaxe:
                    - run MiningTask def:<[NPC]>
                - else:
                    - narrate "I lack purpose. Please put a tool in my last slot."
            - else:
                - narrate "No selected NPCs found nearby"