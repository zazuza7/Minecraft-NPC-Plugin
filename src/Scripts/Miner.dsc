
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

#{ FLAGINT PRADINY BLOKA        - flag <[NPC]> 
        - repeat 2:

            - run SetFlag def:<[NPC]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[StripStartingPosition]>

            - repeat 2:
                - run CheckingSubScript def:<[NPC]>|Top
                - if <[NPC].flag[Status]> != Mine:
                        - repeat stop
                - ~run MiningSubScript def:<[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>

                - run CheckingSubScript def:<[NPC]>|Bottom
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
        - flag <[NPC]> StripStartingPosition:!

#Flags position from which the NPC will start mining a new strip
SetFlag:
    type: task
    script:
        - define NPC <[1]>
        - if <[NPC].has_flag[StripStartingPosition]>:
            - repeat 2:
                - flag <[NPC]> StripStartingPosition:<[NPC].flag[StripStartingPosition].as_location.sub[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>]>
            - modifyblock <[NPC].flag[StripStartingPosition]> dirt
            - narrate "Setting 2nd pos"
        - else:
            - flag <[NPC]> StripStartingPosition:<player.cursor_on>
            - narrate "Setting 1st pos"


#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[NPC].flag[CurrentBlockMined]>

        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - walk <[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location>]> <[NPC]> auto_range
        - run DistanceCheck def:<[NPC]>|<[NPC].flag[CurrentBlockMined].as_location>
        - while <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - wait 0.5s
            - if <[NPC].flag[Status]> == Stop:
                - narrate "Can't reach a block I'm trying to mine :( My current location is - <[NPC].location.round.simple>"
                - stop
#{        - wait 0.3s
        - animate <[NPC]> ARM_SWING
        - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
#{        - wait 0.5s
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
            - narrate "Air in front detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].is_liquid>:
            - narrate "Lava/Water in front detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.material.is_transparent> && <[2]> == Top:
            - narrate "Air above detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.above.is_liquid> && <[2]> == Top:
            - narrate "Lava/Water above detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.below.material.is_transparent> && <[2]> == Bottom:
            - narrate "Air below detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.below.is_liquid> && <[2]> == Bottom:
            - narrate "Lava/Water below detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].material.is_transparent>:
            - narrate "Right-side Air detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Right-side Lava/Water detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].material.is_transparent>:
            - narrate "Left-side Air detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop
        - else if <[NPC].flag[CurrentBlockMined].as_location.add[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Left-side Lava/Water detected, stopping mining"
            - flag <[NPC]> Status:Stop
            - stop

#If NPC is too far to reach the target block after 20s it stops trying to reach it
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - wait 20s
        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5 && <[CurrentBlockMined].material.name> != air:
            - flag <[NPC]> Status:Stop

