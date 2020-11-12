#Config is loaded
OnServerStart:
    type: world
    events:
        on server start:
            - yaml load:minion_plugin_config.yml id:MinionConfig

#Carrot tells NPC to walk to a clicked location
#Maximum distance between torches which prevents hostile mob spawning is 12 blocks
#Less if advanced mining
PutTorch:
    type: world
    events:
        after player right clicks with bread:
            - narrate <player.cursor_on.material.name>
            - if <player.cursor_on.material.name> == diamond_ore:
                - modifyblock <player.cursor_on> air

NPCRemove:
    type: world
    events:
        on player right clicks with diamond_sword:
            - remove <player.target>

NPCLoadYaml:
    type: world
    events:
        on player right clicks with diamond_pickaxe:
            - yaml load:minion_plugin_config.yml id:MinionConfig
            - repeat 20:
                - if <[value].mod[<yaml[MinionConfig].read[TorchDistance]>]> == 0:
                    - narrate <[value].mod[<yaml[MinionConfig].read[TorchDistance]>]>
                - else:
                    - narrate <[value]>


GoBackToChestCarrot:
    type: world
    events:
        on player right clicks with carrot:
            - define NPC <player.flag[Selected].as_npc>
            - define Target <player.cursor_on>
            - ~run LongWalk def:<[NPC]>|<[Target]>

# Enables to command NPCs to walk distances further than ~64 blocks
LongWalk:
    type: task
    script:
        - define NPC <[1]>
        - define Target <[2]>
        - narrate <[NPC].location.distance[<[Target]>]>

        - while <[NPC].location.distance[<[Target]>]> > 50:
            - narrate <[NPC].location.distance[<[Target]>]>
            - ~walk <[NPC]> <[Target]> auto_range speed:2

        - if <[NPC].location.distance[<[Target]>]> <= 50:
            - narrate "Shits close yo"
            - ~walk <[NPC]> <[Target]> auto_range speed:2
            - stop
        - else:
            - narrate "Shits Gone??? Chunk not loaded mb?"
            - stop

#Deposits all items in .yml config file to a chest
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
#Check if TargetInventory can fit items.
            - if <[TargetInventory].can_fit[<[item]>].quantity[<[NPC].inventory.quantity.material[<[item]>]>]>:
                - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<[TargetInventory]>
                - take material:<[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
            - else:
                - give <[item]> quantity:<[TargetInventory].can_fit[<[item]>].count> to:<[TargetInventory]>
                - take material:<[item]> quantity:<[TargetInventory].can_fit[<[item]>].count> from:<[NPC].inventory>
                - narrate "My chest's inventory is full :( My current location is - <[NPC].location.round.simple>"
                - flag <[NPC]> Status:Wait
                - stop
            - wait 0.3s
