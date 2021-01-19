#Configuratory file is loaded on server start
OnServerStart:
    type: world
    events:
        on server start:
            - if <server.has_file[MinionConfig.yml]>:
                - yaml load:MinionConfig.yml id:MinionConfig
            - else:
                - debug error "MinionConfig.yml not found in plugins/Denizen folder"

InitialMessage:
    type: world
    events:
        on player join:
            - narrate "Welcome! This server seems to be using a Minion plug-in."
            - narrate "Naming a signed book 'MinionControl' will give it an ability to create and control minion NPCs"
            - narrate "Right click while holding a 'MinionControl' book in your off-hand to learn more!"

#Makes the NPC jump 1 block and places a block underneath
#{TestJump:
#{    type: world
#{    events:
#{        on player right clicks with bread:
#{            - define Start <player.target.location>
#{            - adjust <player.target> velocity:0,0.38,0
#{            - wait 0.3s
#{            - modifyblock <[Start]> dirt

#If a player signs a book and names it 'MinionControl'(not case sensitive) it gets transformed to a book specified in MinionControlBook script.
Book_Signing:
    type: world
    events:
        on player signs book:
            - if <context.title> = MinionControl:
                - determine MinionControlBook

OnNPCDeath:
    type: world
    events:
        on npc death:
            - if <context.entity.has_flag[Owner]>:
#determine doesn't work
                - determine passively <context.entity.inventory.list_contents>
                - narrate "I died!!! My chests location is: <context.entity.flag[ChestLocation].as_location.simple||null>"
                - remove <context.entity>

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
                            #Checks if monster has line-of-sight to NPC
                            - if <[Monster].is_monster> && <[Monster].can_see[<[NPC]>]>:
                                #If monster is not on exception list - it attacks NPC
                                - if <yaml[MinionConfig].read[Hostile_Monster_Exceptions].find[<[Monster].entity_type>]> == -1:
                                    - attack <[Monster]> target:<[NPC]>
                                    #Stops attacking if NPC is no longer spawned or distance between them is more than 20 blocks or monster loses line of sight to NPC
                                    - waituntil rate:1s !<[NPC].is_spawned> || <[Monster].location.distance[<[NPC].location>]> > 20 || !<[Monster].can_see[<[NPC]>]>
                                    - attack <[Monster]> cancel

#Checks if NewLocation is a part of the same cave as one of the old connections.
#In other words, it checks whether there is an air route connecting old and new locations
#Flags the NPC if unable
BlockConnectionCheck:
    type: task
    script:
        - define NPC <[1]>
        - define NewLocation <[2]>
        - define OldLocations <[3]>
        - define FloodFillDistance 6

        #Removes Old locations which are too far to be found in the 2nd loop
        - foreach <[OldLocations]> as:OldLocation:
            - if <[OldLocation]||null> == null:
                - define OldLocations:<-:<[OldLocation]>
            - else if <[OldLocation].distance[<[NewLocation]>]> > <[FloodFillDistance]>:
                - define OldLocations:<-:<[OldLocation]>

        - foreach <[OldLocations]> as:OldLocation:
            - foreach <[NewLocation].flood_fill[<[FloodFillDistance]>].types[air|cave_air|torch]> as:Location:
                - if <[OldLocation].simple> == <[Location].simple>:
                    - stop
        - flag <[NPC]> StopMiningBlock:1

#Using this instead of built-in -walk command because -walk seems to time out rather quickly. NPC can only move ~64 blocks at normal speed until -walk times out.
#Could use chunkload to make sure walking is succesful?
LongWalk:
    type: task
    script:
        - define NPC <[1]>
        - define Target <[2]>
        - define Speed <yaml[MinionConfig].read[Movement_Speed]>
        - if <[NPC].is_Spawned>:
            - while <[NPC].location.distance[<[Target]>]> > 50 && <[NPC].is_Spawned>:
                - ~walk <[NPC]> <[Target]> auto_range speed:<[Speed]>
            - if <[NPC].location.distance[<[Target]>]> <= 50:
                - ~walk <[NPC]> <[Target]> auto_range speed:<[Speed]>
                - stop
            - else:
                - narrate "Long walk error, target location is unclear"
                - stop
        - else:
            - narrate "Can't use LongWalk command on an unspawned NPC. Is the NPC too far?"

#Deposits all items in .yml config file's "items" list into a chest
Deposit:
    type: task
    script:
        - define NPC <[1]>
        - define TargetInventory <[2]>

        - foreach <yaml[MinionConfig].read[Items]> as:item:
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
        - define PrefferedTorchAmount <yaml[MinionConfig].read[Preffered_Torch_Amount]>
        #If torch placement and torch placement from inventory are enabled
        - if <yaml[MinionConfig].read[Place_Torches]> && <yaml[MinionConfig].read[Place_Torches_from_Inventory]>:
            #If currently NPC has less torches than specified
            - if <[NPC].inventory.quantity[torch]> < <[PrefferedTorchAmount]>:
                - if <[NPC].inventory.quantity[torch].add[<[ChestInventory].quantity[torch]>]> <= <[PrefferedTorchAmount]>:
                    - give torch quantity:<[ChestInventory].quantity[torch]> to:<[NPC].inventory>
                    - take material:torch quantity:<[ChestInventory].quantity[torch]> from:<[ChestInventory]>
                - else:
                    - define AmountNeeded <[PrefferedTorchAmount].sub[<[NPC].inventory.quantity[torch]>]>
                    - give torch quantity:<[AmountNeeded]> to:<[NPC].inventory>
                    - take material:torch quantity:<[AmountNeeded]> from:<[ChestInventory]>

#Clears NPCs inventory of all items except ones specified in configuratory file's 'Items_Not_To_Remove' list
ClearInventory:
    type: task
    script:
        - define NPC <[1]>
        - define ChestInventory <[2]>
        - define flag false
        #If NPCs chest is not full.
        - if <[ChestInventory].first_empty> != -1:
            - foreach <[NPC].inventory.list_contents> as:slot:
                - foreach <yaml[MinionConfig].read[Items_Not_To_Remove]> as:item:
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
