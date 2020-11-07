#Config is loaded
OnServerStart:
    type: world
    events:
        on server start:
            - yaml load:minion_plugin_config.yml id:MinionConfig

#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - walk <player.cursor_on.above> <player.flag[Selected].as_npc> auto_range

NPCRemove:
    type: world
    events:
        on player right clicks with diamond_sword:
            - remove <player.target>

#Deposits all items in a.yml config file to a chest
Deposit:
    type: task
    script:
        - define NPC <[1]>
        - define Chest <[NPC].flag[ChestLocation]>
#Checks if NPC can put items in a flagged block
        - if !<[Chest].as_location.has_inventory> && <[Chest].as_location.material.name> != ender_chest:
            - narrate "I don't have a linked chest :(   My current location is - <[NPC].location.round.simple>"
            - stop
        - else if <[Chest].as_location.has_inventory>:
            - define TargetInventory <[Chest].as_location.inventory>
        - else if <[Chest].as_location.material.name> == ender_chest:
            - define TargetInventory <[NPC].Owner.as_player.enderchest>

        - foreach <yaml[MinionConfig].read[items]> as:item:
            - define Count <[TargetInventory].quantity.material[<[item]>]>
            - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<[TargetInventory]>
#Check if TargetInventory can fit items
            - if <[TargetInventory].quantity.material[<[item]>].sub[<[NPC].inventory.quantity.material[<[item]>]>]> != <[Count]>:
                - narrate "My chest's inventory is full :( My current location is - <[NPC].location.round.simple>"
                - flag <[NPC]> Status:Wait
                - take material:<[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
                - stop
            - take material:<[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
            - wait 0.5s
