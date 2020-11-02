#Bread summons an NPC named Mr. Slave
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



#Digs forward until it encounters an obstacle
UpdatedDig:
    type: world
    events:
        on player right clicks with cooked_beef:
#Stops the script if the direction is vertical
#{
            - if <player.eye_location.precise_impact_normal.x> == 0 && <player.eye_location.precise_impact_normal.z> == 0:
                - stop

            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
            - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
            - flag <[NPC]> Status:Mine

            - repeat 5:

                - run CheckingSubScript def:<[NPC]>
                - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
                - ~run MiningSubScript def:<[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>

                - run CheckingSubScript def:<[NPC]>
                - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
                - ~run MiningSubScript def:<[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>

            - narrate "I'm done sir"



#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - if <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - walk <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location>]> <[NPC]>
        - run DistanceCheck
        - while <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - wait 0.5s
        - wait 0.3s
        - animate <[NPC]> ARM_SWING
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
        - wait 0.5s
        - animate <[NPC]> ARM_SWING
        - give <[NPC].flag[CurrentBlockMined].as_location.drops.get[1]> to:<[NPC].inventory>
        - modifyblock <[NPC].flag[CurrentBlockMined]> air
        - blockcrack <[NPC].flag[CurrentBlockMined]> progress:0

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

#Checks whether NPC is far away from it's goal and changes it's status if necessary
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - wait 10s
        - if <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - narrate "NPC too far from mining block"
            - flag <[NPC]> Status:Stop

#The events item should be able to perform
#Spawn NPC                  Left Click
#Set NPC working direction  Right Click WORKS ON FRESHEST
#Set NPC Chest              Right Click WORKS ON FRESHEST
#Access NPCs inventory      Left/Right? WORKS ON ALL


OnLeftClickWhip:
    type: world
    events:
        on player left clicks with Whip:
#If target mob is our NPC
            - if <player.target.has_flag[Role]>:
                - flag <player> Selected:<player.target>
            - else:
                - create player Mr.Slave <player.location>
                - flag <player.target> miner
                - flag <player.target> Role:Undefined
                - flag <player> Selected:<player.target>


#Should stand up before giving commands
#Shouldnt work on removed/despawned NPCs
OnRightClickWhip:
    type: world
    events:
        on player right clicks with Whip:
            - define NPC <player.flag[Selected].as_npc>

            - if <player.location.distance[<[NPC].location>]> <= 25:

                - if <player.cursor_on.material.name> == chest:

                    - if  !<[NPC].has_flag[ChestLocation]> || !<[NPC].flag[ChestLocation].as_location.has_inventory>:
                        - flag <[NPC]> ChestLocation:<player.cursor_on>
                        - narrate "Chest Linked succesfully"
                        - ~walk <[NPC]> <[NPC].flag[ChestLocation]>
                        - run Deposit def:<[NPC]>
                    - else:
                        - narrate "NPC already linked"
                        - walk <[NPC]> <[NPC].flag[ChestLocation]>

                - else:
                    - if <player.target.has_flag[role]>:
                        - inventory open d:<player.target.inventory>

                        

                    - else:
                        - run UpdatedDigTask def:<[NPC]>
                        - narrate "Lets go work"
            - else:
                - narrate "No selected NPCs found nearby"
#Script should repeat itself
UpdatedDigTask:
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
            - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
            - ~run MiningSubScript def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>

            - run CheckingSubScript def:<[NPC]>
            - if <[NPC].flag[Status]> == Stop:
                    - repeat stop
            - ~run MiningSubScript def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>
        - ~walk <[NPC]> <[NPC].flag[ChestLocation]> auto_range
        - run deposit def:<[NPC]>
        - narrate "I'm done sir"

#Deposits all items in a.yml config file to a chest
Deposit:
    type: task
    script:
        - define NPC <[1]>
        - define Chest <[NPC].flag[ChestLocation]>
        - if !<[NPC].flag[ChestLocation].as_location.has_inventory>:
            - narrate "I don't have a linked chest :(   My current location is - <[NPC].location.round.simple>"
            - stop
        - foreach <yaml[MinionConfig].read[items]> as:item:
            - narrate <[NPC].inventory.quantity.material[<[item]>]>
            - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<[NPC].flag[ChestLocation].as_location.inventory>
            - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
            - narrate <[item]>
            - wait 1s

#Item which spawns and (is going to) control NPCs
Whip:
    type: item
    material: wooden_sword
    display name: Whip
    lore:
        - "An item Rolandas the Great created to rule the universe"
        - "An item left behind by the gods who have created our universe "


