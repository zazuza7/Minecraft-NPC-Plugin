#Config is loaded
OnServerStart:
    type: world
    events:
        on server start:
            - yaml load:minion_plugin_config.yml id:MinionConfig

#Carrot tells NPC to walk to a clicked location
#Maximum distance between torches which prevents hostile mob spawning is 12 blocks
#Less if advanced mining
Test00:
    type: world
    events:
        after player left clicks with bread:
            - flag <player> temp:<player.cursor_on>

Test01:
    type: world
    events:
        after player right clicks with carrot:
            - ~run LongWalk def:<player.flag[Selected].as_npc>|<player.cursor_on.above>

#Checks if 2 positions are connected by 10 block radius or less.
BlockConnectionCheck:
    type: task
    script:
        - define NPC <[1]>
        - define NewLocation <[2]>
        - define OldLocations <[3]>

        - foreach <[NewLocation].flood_fill[10]> as:Location:
            - narrate <[loop_index]>
            - foreach <[OldLocations]> as:OldLocation:
                - if <[OldLocation].simple> == <[Location].simple>:
                    - stop
#{        - narrate <[NewLocation].material.name>
        - flag <[NPC]> CurrentBlockMined:!

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
        - define Chest <[NPC].flag[ChestLocation].as_location>
#Checks if NPC can put items in a flagged block
        - if !<[Chest].has_inventory> && <[Chest].material.name> != ender_chest:
            - narrate "I don't have a linked chest :(   My current location is - <[NPC].location.round.simple>"
            - stop
        - else if <[Chest].has_inventory>:
            - define TargetInventory <[Chest].inventory>
        - else if <[Chest].material.name> == ender_chest:
            - define TargetInventory <[NPC].Owner.as_player.enderchest>

        - foreach <yaml[MinionConfig].read[items]> as:item:
#If Items can fit into chest
            - if <[TargetInventory].can_fit[<[item]>].quantity[<[NPC].inventory.quantity.material[<[item]>]>]>:
                - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<[TargetInventory]>
                - take material:<[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
            - else:
                - give <[item]> quantity:<[TargetInventory].can_fit[<[item]>].count> to:<[TargetInventory]>
                - take material:<[item]> quantity:<[TargetInventory].can_fit[<[item]>].count> from:<[NPC].inventory>
                - narrate "My chest's inventory is full :( My current location is - <[NPC].location.round.simple>"
                - flag <[NPC]> StripStartingPosition:!
                - stop
            - wait 0.3s

#Collects torches from Chests inventory until it reaches Preffered Torch Amount, which is defined in .yml config file
Collect:
    type: task
    script:
        - define NPC <[1]>
        - define ChestInventory <[NPC].flag[ChestLocation].as_location.inventory>
#Minimum amount of torches NPC will try to have in its inventory
        - define PrefferedTorchAmount <yaml[MinionConfig].read[PrefferedTorchAmount]>
        - if <yaml[MinionConfig].read[Place_Torches]>:
            - if <yaml[MinionConfig].read[Place_Torches_from_Inventory]>:
                - if <[NPC].inventory.quantity[torch]> < <[PrefferedTorchAmount]>:
                    - if <[NPC].inventory.quantity[torch].add[<[ChestInventory].quantity[torch]>]> <= <[PrefferedTorchAmount]>:
                        - give torch quantity:<[ChestInventory].quantity[torch]> to:<[NPC].inventory>
                        - take material:torch quantity:<[ChestInventory].quantity[torch]> from:<[ChestInventory]>
                    - else:
                        - define AmountNeeded <[PrefferedTorchAmount].sub[<[NPC].inventory.quantity[torch]>]>
                        - give torch quantity:<[AmountNeeded]> to:<[NPC].inventory>
                        - take material:torch quantity:<[AmountNeeded]> from:<[ChestInventory]>

Collect&Deposit:
    type: task
    script:
        - ~run Collect def:<[1]>
        - ~run Deposit def:<[1]>
