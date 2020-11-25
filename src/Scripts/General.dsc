#Config is loaded
OnServerStart:
    type: world
    events:
        on server start:
            - yaml load:minion_plugin_config.yml id:MinionConfig

#Removes a target entity
NPCRemove:
    type: world
    events:
        on player right clicks with diamond_sword:
            - remove <server.npcs_named[Mr.Slave]>

NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - run LongWalk def:<player.flag[selected].as_npc>|<player.cursor_on>

#If a hostile mob is closer than 10 tiles and can see the NPC, it starts attacking it.
NPCGetAttacked:
    type: world
    events:
        on delta time secondly every:2:
            - foreach <server.npcs_named[Mr.Slave]> as:NPC:
                - if <[NPC].is_spawned>:
                    - foreach <[NPC].location.find.living_entities.within[10]> as:Monster:
                        - if <[Monster].is_monster> && <[Monster].can_see[<[NPC]>]>:
                            - if <[Monster].entity_type> == ENDERMAN:
                                - narrate yay
                            - else:
                                - attack <[Monster]> target:<[NPC]>
                                - waituntil rate:1s !<[NPC].is_spawned> || <[Monster].location.distance[<[NPC].location>]> > 10
                                - attack <[Monster]> cancel

TestCuboidFromList:
    type: task
    script:
        - define Blocks <[1]>
        - foreach <[Blocks]> as:Block:
            - if <[loop_index]> != 1:
                #{update mins and maxes
                - define MinX <[MinX].min[<[Block].x>]>
                - define MaxX <[MinX].max[<[Block].x>]>
                - define MinY <[MinX].min[<[Block].y>]>
                - define MaxY <[MinX].max[<[Block].y>]>
                - define MinZ <[MinX].min[<[Block].z>]>
                - define MaxZ <[MinX].max[<[Block].z>]>
            - if <[loop_index]> == 1:
                #{define all the mins and maxes
                - define MinX <[Block].x>
                - define MaxX <[Block].x>
                - define MinY <[Block].y>
                - define MaxY <[Block].y>
                - define MinZ <[Block].z>
                - define MaxZ <[Block].z>
        #Create cuboid <LocationTag.to_cuboid[<location>]>
        #Add 2 height cuboid
        #UNION to perfect the shape

Test:
    type: world
    events:
        on npc death:
            - if <context.entity.has_flag[Owner]>:
                - determine passively <context.entity.inventory.list_contents>
                - narrate <context.entity.inventory.list_contents> targets:<context.entity.flag[Owner]>
                - remove <context.entity>

#Loads config file and reloads scripts
NPCLoadYaml:
    type: world
    events:
        on player right clicks with diamond_pickaxe:
            - yaml load:minion_plugin_config.yml id:MinionConfig
            - reload

#Checks if 2 positions are connected by the same block type in 10 block radius or less.
BlockConnectionCheck:
    type: task
    script:
        - define NPC <[1]>
        - define NewLocation <[2]>
        - define OldLocations <[3]>

        - foreach <[NewLocation].flood_fill[10].types[air|cave_air|torch]> as:Location:
            - foreach <[OldLocations]> as:OldLocation:
                - if <[OldLocation].simple> == <[Location].simple>:
                    - stop
        - flag <[NPC]> CurrentBlockMined:!

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
            - narrate "Long walk error, Location is unclear"
            - stop

#Deposits all items in .yml config file to a chest
Deposit:
    type: task
    script:
        - define NPC <[1]>
        - define TargetInventory <[2]>

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
        - define ChestInventory <[2]>
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

#Clears NPCs inventory of all items except ones specified in configuratory files
ClearInventory:
    type: task
    script:
        - define NPC <[1]>
        - define ChestInventory <[2]>
        - define flag false
#If NPCs chest is not full
        - if <[ChestInventory].first_empty> != -1:
            - foreach <[NPC].inventory.list_contents> as:slot:
                - foreach <yaml[MinionConfig].read[ItemsNotToRemove]> as:item:
                    - if <[slot].material.name> == <[item]>:
                        - narrate <[slot].material.name>
                        - narrate <[item]>
                        - define flag true
                        - foreach stop
                - if <[flag]> != true:
                    - take material:<[slot].material> from:<[NPC].inventory> quantity:<[NPC].inventory.quantity.material[<[slot].material>]>
                - define flag false

#Runs Collect, deposit and ClearInventory scripts
Collect&Deposit&Clear:
    type: task
    script:
        - define NPC <[1]>
        - define Chest <[NPC].flag[ChestLocation].as_location>
#Checks if NPC can put items in a flagged block
        - if !<[Chest].has_inventory> && <[Chest].material.name> != ender_chest:
            - narrate "I don't have a linked chest :(   My current location is - <[NPC].location.round.simple>"
            - stop
        - else if <[Chest].has_inventory>:
            - define ChestInventory <[Chest].inventory>
        - else if <[Chest].material.name> == ender_chest:
            - define ChestInventory <[NPC].Owner.as_player.enderchest>

        - ~run Collect def:<[NPC]>|<[ChestInventory]>
        - ~run Deposit def:<[NPC]>|<[ChestInventory]>
        - ~run ClearInventory def:<[NPC]>|<[ChestInventory]>
