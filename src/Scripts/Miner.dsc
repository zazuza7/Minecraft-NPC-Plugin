#Bread summons an NPC named Mr. Slave
SpawnNPC:
    type: world
    events:
        on player right clicks with bread:
            - despawn <player.target>
            - create player Mr.Slave <player.location>
            - flag <player.target> role:miner
            

#Apple opens target entity's inventory
ChecksTargetsInventory:
    type: world
    events:
        on player right clicks with apple:
            - inventory open d:<player.target.inventory>


#Carrot tells NPC to walk to a clicked location
NPCWalk:
    type: world
    events:
        on player right clicks with carrot:
            - walk <player.cursor_on.above> <server.spawned_npcs_flagged[miner].get[1]>

#A script, which returns assigns a chest to an NPC or tells the NPC to return there
NpcChest:
    type: world
    events:
        on player right clicks with chest:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - if  !<[NPC].has_flag[ChestLocation]>:
                - flag <[NPC]> ChestLocation:<[NPC].location.find.blocks[chest].within[10].get[1]>
            - else:
                - narrate <[NPC].flag[ChestLocation]>
                - walk <[NPC].flag[ChestLocation]> <[NPC]>
                - animatechest <[NPC].flag[ChestLocation]>
                - look <[NPC]> <[NPC].flag[ChestLocation]>
                - wait 3s
                - animatechest <[NPC].flag[ChestLocation]> close

#Deposits all items in a.yml config file to a chest
Deposit:
    type: world
    events:
        on player right clicks with cooked_beef:
            - define NPC <server.spawned_npcs_flagged[miner].get[1]>
            - define Chest <[NPC].flag[ChestLocation]>
            - foreach <yaml[a].read[items]> as:item:
                - narrate <[NPC].inventory.quantity.material[<[item]>]>
                - give <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> to:<location[Chest].inventory>
                - take <[item]> quantity:<[NPC].inventory.quantity.material[<[item]>]> from:<[NPC].inventory>
                - narrate <[item]>
                - wait 1s

#Digs forward until it encounters an obstacle
UpdatedDig:
    type: world
    events:
        on player right clicks with wheat:
#Stops the script if the direction is vertical
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



#NPC moves towards target block and simulates mining it, while receiving drops to its inventory
#Only starts mining after coming close
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
            - narrate 1
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].is_liquid>:
            - narrate 2
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.is_liquid>:
            - narrate 3
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].is_liquid>:
            - narrate 4
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].is_liquid>:
            - narrate 5
            - flag <[NPC]> Status:Stop
            - stop

#Checks whether NPC is far away from it's goal and changes it's status if necessary
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - wait 10s
        - if <[NPC].location.distance[<[NPC].flag[CurrentBlockMined]>]> > 3.5:
            - narrate distance
            - flag <[NPC]> Status:Stop

#The events item should be able to perform
#Spawn NPC                  Left Click
#Set NPC working direction  Right Click
#Set NPC Chest              Right Click
#Access NPCs inventory      Left/Right?

OnWhip:
    type: world
    events:
        on player right clicks with Whip:
        - narrate <player.target>
        - if <player.target> == "Player.target":
            - narrate "Target not found"
        - else:
            - inventory open d:<player.target.inventory>
            - narrate "Target located"

#Item which spawns and (is going to) control NPCs
Whip:
    type: item
    material: iron_ore
    display name: Whip
    lore:
        - "An item Rolandas the Great created to rule the universe"
        - "An item left behind by the gods who have created our universe "
    color: <Whip.color.with_red[255]>


