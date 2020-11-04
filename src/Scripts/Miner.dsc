#Flags are loaded
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
            - walk <player.cursor_on.above> <player.flag[Selected].as_npc>




MiningTask:
    type: task
    script:
        - define NPC <[1]>
#Stops the script if the direction is vertical
        - if <player.eye_location.precise_impact_normal.x> == 0 && <player.eye_location.precise_impact_normal.z> == 0:
            - stop

        - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
        - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
        - flag <[NPC]> Status:Mine

        - repeat 5:

            - run CheckingSubScript def:<[NPC]>
            - if <[NPC].flag[Status]> != Mine:
                    - repeat stop
            - ~run MiningSubScript def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>

            - run CheckingSubScript def:<[NPC]>
            - if <[NPC].flag[Status]> != Mine:
                    - repeat stop
            - ~run MiningSubScript def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>
            
        - ~walk <[NPC]> <[NPC].flag[ChestLocation]> auto_range
        - if <[NPC].location.distance[<[NPC].flag[ChestLocation].as_location>]> > 3.5:
            - narrate "I'm stuck, can't reach linked chest :( My current location is - <[NPC].location.round.simple>"
            - flag <[NPC]> status:Stop
            - stop
        - run deposit def:<[NPC]>
        - narrate "I'm done sir"

#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[NPC].flag[CurrentBlockMined]>

        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - walk <[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location>]> <[NPC]>
        - run DistanceCheck def:<[NPC]>|<[NPC].flag[CurrentBlockMined].as_location>
        - while <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - wait 0.5s
            - if <[NPC].flag[Status]> == Stop:
                - narrate "Can't reach a block I'm trying to mine :( My current location is - <[NPC].location.round.simple>"
                - stop
        - wait 0.3s
        - animate <[NPC]> ARM_SWING
        - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
        - animate <[NPC]> ARM_SWING
        - give <[CurrentBlockMined].as_location.drops.get[1]> to:<[NPC].inventory>
        - modifyblock <[CurrentBlockMined]> air
        - blockcrack <[CurrentBlockMined]> progress:0

#Checks whether there is danger while mining and changes status of NPC if necessary
CheckingSubScript:
    type: task
    script:
        - define NPC <[1]>
        - if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].material.is_transparent>:
            - narrate "Obstacle #1 detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].is_liquid>:
            - narrate "Obstacle #2 detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.is_liquid>:
            - narrate "Obstacle #3 detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Obstacle #4 detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Obstacle #5 detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop

#If NPC is too far to reach the target block after 20s it stops trying to reach it
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - narrate <[NPC].location.distance[<[CurrentBlockMined]>]>
        - wait 20s
        - narrate <[NPC].location.distance[<[CurrentBlockMined]>]>
        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5 && <[CurrentBlockMined].material.name> != air:
            - flag <[NPC]> Status:Stop

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
            - define TargetInventory <[NPC].flag[Owner].as_player.enderchest>

        - foreach <yaml[MinionConfig].read[items]> as:item:
            - define Count <[TargetInventory].quantity.material[<[item]>]>
            - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<[TargetInventory]>
#Check if TargetInventory can fit items
            - if <[TargetInventory].quantity.material[<[item]>].sub[<[NPC].inventory.quantity.material[<[item]>]>]> != <[Count]>:
                - narrate "My chest's inventory is full :( My current location is - <[NPC].location.round.simple>"
                - flag <[NPC]> Status:Wait
                - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
                - stop
            - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
            - wait 0.5s