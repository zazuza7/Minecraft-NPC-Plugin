#Config is loaded
OnServerStart:
    type: world
    events:
        on server start:
            - yaml load:minion_plugin_config.yml id:MinionConfig

#Removes all minions
NPCRemove:
    type: world
    events:
        on player right clicks with diamond_sword:
            - remove <server.npcs_named[Minion]>

NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - run LongWalk def:<player.flag[selected].as_npc>|<player.cursor_on>

#Makes the NPC jump 1 block and places a block underneath
TestJump:
    type: world
    events:
        on player right clicks with bread:
            - define Start <player.target.location>
            - adjust <player.target> velocity:0,0.38,0
            - wait 0.3s
            - modifyblock <[Start]> dirt

TestBook_Show:
    type: world
    events:
        on player right clicks with diamond:
            - adjust <player> show_book:<player.inventory.slot[1]>

Test_Book_Signing:
    type: world
    events:
        on player signs book:
            - if <context.title> == MinionControl:
                - determine Book_Script_Name
#{                - adjust <player> show_book:<player.inventory.slot[1]>

TestCuboid:
    type: world
    events:
        on player right clicks with bone:
            - run TestCuboidFromList def:<list_single[<player.cursor_on.flood_fill[4]>]>

#Will be used for advanced mining. Might not have time to implement? :(
TestCuboidFromList:
    type: task
    script:
        - define Blocks <[1]>
        - foreach <[Blocks]> as:Block:
            - if <[loop_index]> == 1:
                #{define all the mins and maxes
                - define MinX <[Block].x>
                - define MaxX <[Block].x>
                - define MinY <[Block].y>
                - define MaxY <[Block].y>
                - define MinZ <[Block].z>
                - define MaxZ <[Block].z>
            - else:
                #{update mins and maxes
                - narrate <[Block]> targets:<server.players>
                - define MinX <[MinX].min[<[Block].x>]>
                - define MaxX <[MaxX].max[<[Block].x>]>
                - define MinY <[MinY].min[<[Block].y>]>
                - define MaxY <[MaxY].max[<[Block].y>]>
                - define MinZ <[MinZ].min[<[Block].z>]>
                - define MaxZ <[MaxZ].max[<[Block].z>]>
        - define Cuboid1 <location[<[MinX]>,<[MinY]>,<[MinZ]>].to_cuboid[<[MaxX]>,<[MaxY]>,<[MaxZ]>]>
#{        - define Cuboid1 <[<[MinX]>,<[MinY]>,<[MinZ]>].location.to_cuboid[<[MaxX]>,<[MaxY]>,<[MaxZ]>]>
        #Create cuboid <LocationTag.to_cuboid[<location>]>
#{        - modifyblock <[Cuboid1]> glass
        - modifyblock <cuboid[<[MinX]>,<[MinY]>,<[MinZ]>,world|<[MaxX]>,<[MaxY]>,<[MaxZ]>,world]> glass
        #UNION to perfect the shape

#Narrates NPCs inventory contents after its death. Finally works properly(?)
Test:
    type: world
    events:
        on npc death:
            - if <context.entity.has_flag[Owner]>:
#determine doesn't work
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

#If a hostile mob is closer than 10 tiles and can see the NPC, it starts attacking it.
NPCGetAttacked:
    type: world
    events:
        on delta time secondly every:2:
            - if <yaml[MinionConfig].read[Monster_Hostility]>:
                - foreach <server.npcs_named[Minion]> as:NPC:
                    - if <[NPC].is_spawned>:
#Loop through all monsters within 10 tiles of NPC
                        - foreach <[NPC].location.find.living_entities.within[10]> as:Monster:
#Check if monster has line-of-sight to NPC
                            - if <[Monster].is_monster> && <[Monster].can_see[<[NPC]>]>:
#If monster is not on exception list - attack NPC
                                - if <yaml[MinionConfig].read[Hostile_Monster_Exceptions].find[<[Monster].entity_type>]> == -1:
                                    - attack <[Monster]> target:<[NPC]>
                                    - waituntil rate:1s !<[NPC].is_spawned> || <[Monster].location.distance[<[NPC].location>]> > 20 || !<[Monster].can_see[<[NPC]>]>
                                    - attack <[Monster]> cancel

#Checks if NewLocation can find one of the old locations by using flood_fill tag
#Flags the NPC if unable
BlockConnectionCheck:
    type: task
    script:
        - define NPC <[1]>
        - define NewLocation <[2]>
        - define OldLocations <[3]>
        - define FloodFillDistance 6

#Removes Old locations which are too far to be found in the 2nd foreach
        - foreach <[OldLocations]> as:OldLocation:
            - if <[OldLocation].distance[<[NewLocation]>]> > <[FloodFillDistance]>:
               - define OldLocations:<-:<[OldLocation]>

        - foreach <[OldLocations]> as:OldLocation:
            - foreach <[NewLocation].flood_fill[<[FloodFillDistance]>].types[air|cave_air|torch]> as:Location:
                - if <[OldLocation].simple> == <[Location].simple>:
                    - stop
        - flag <[NPC]> StopMiningBlock:1
        - narrate StopMiningFloodFill

# Enables to command NPCs to walk distances further than ~64 blocks
#Should use chunkload to make sure walking is succesful?
LongWalk:
    type: task
    script:
        - define NPC <[1]>
        - define Target <[2]>
#{        - narrate <[NPC].location.distance[<[Target]>]>
        - if <[NPC].is_Spawned>:
            - while <[NPC].location.distance[<[Target]>]> > 50 && <[NPC].is_Spawned>:
                - ~walk <[NPC]> <[Target]> auto_range speed:1

            - if <[NPC].location.distance[<[Target]>]> <= 50:
                - ~walk <[NPC]> <[Target]> auto_range speed:1
                - stop
            - else:
                - narrate "Long walk error, target location is unclear"
                - stop
        - else:
            - narrate "Can't use LongWalk command on an unspawned NPC. Is the NPC too far?"

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
            - flag <[NPC]> StopMining:1
            - stop
        - else if <[Chest].has_inventory>:
            - define ChestInventory <[Chest].inventory>
        - else if <[Chest].material.name> == ender_chest:
            - define ChestInventory <[NPC].Owner.as_player.enderchest>

        - ~run Collect def:<[NPC]>|<[ChestInventory]>
        - ~run Deposit def:<[NPC]>|<[ChestInventory]>
        - ~run ClearInventory def:<[NPC]>|<[ChestInventory]>
