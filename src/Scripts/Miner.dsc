#Should create subscripts for easier readability/editability
MiningTask:
    type: task
    script:
        - define NPC <[1]>
#Stops the script if the direction is vertical
        - if <player.eye_location.precise_impact_normal.x> == 0 && <player.eye_location.precise_impact_normal.z> == 0:
            - stop
        - ~flag <[NPC]> CurrentBlockMined:!
        - ~flag <[NPC]> StripStartingPosition:!
        - flag <[NPC]> Direction:<player.eye_location.precise_impact_normal>
        - flag <[NPC]> CurrentBlockMined:<player.cursor_on>
        - flag <[NPC]> InitialBlockMined:<player.cursor_on>
#How many strips is the NPC going to mine
        - repeat 1:

            - if <[value]> != 1:
                - if !<[NPC].has_flag[StripStartingPosition]>:
                    - stop
                - ~walk <[NPC].flag[InitialBlockMined].as_location> <[NPC]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[StripStartingPosition].as_location.add[<[NPC].flag[Direction].as_location>]>
                - flag <[NPC]> Direction:<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>
                - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>]>

                - repeat <yaml[MinionConfig].read[StripMineDistance]>:

                    - ~run CheckingSubScript def:<[NPC]>|Top
                    - if <[NPC].has_flag[CurrentBlockMined]>:
                        - ~run MiningSubScript def:<[NPC]>
                    - if <[NPC].has_flag[CurrentBlockMined]>:
                        - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>
                        - ~run CheckingSubScript def:<[NPC]>|Bottom

                    - if <[NPC].has_flag[CurrentBlockMined]>:
                        - ~run MiningSubScript def:<[NPC]>
                    - if <[NPC].has_flag[CurrentBlockMined]>:
                        - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>
                    - if !<[NPC].has_flag[CurrentBlockMined]>:
                        - repeat stop

                - flag <[NPC]> Direction:<[NPC].flag[Direction].as_location.rotate_around_y[1.5708].round_to_precision[1]>

            - run SetStripStartingPosition def:<[NPC]>|<[value]>
            - flag <[NPC]> CurrentBlockMined:<[NPC].flag[StripStartingPosition].as_location>
#How long the strips will be
            - repeat 1000:
                - ~run CheckingSubScript def:<[NPC]>|Top
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - ~run MiningSubScript def:<[NPC]>
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.below>
                    - ~run CheckingSubScript def:<[NPC]>|Bottom

                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - ~run MiningSubScript def:<[NPC]>
#Torch placement, can modify its rate in minion_plugin_config.yml
                    - if <[value].mod[<yaml[MinionConfig].read[TorchDistance]>]> == 0 && <yaml[MinionConfig].read[Place_Torches]>:
                        - run PlaceTorch def:<[NPC]>
                - if <[NPC].has_flag[CurrentBlockMined]>:
                    - flag <[NPC]> CurrentBlockMined:<[NPC].flag[CurrentBlockMined].as_location.sub[<[NPC].flag[Direction].as_location>].above>
                - if !<[NPC].has_flag[CurrentBlockMined]>:
                    - repeat stop
            - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation]>
            - if <[NPC].location.distance[<[NPC].flag[ChestLocation].as_location>]> > 3.5:
                - narrate "Can't reach my linked chest :( My current location is - <[NPC].location.round.simple>"
                - stop
            - ~run Collect&Deposit&Clear def:<[NPC]>
        - flag <[NPC]> StripStartingPosition:!

#Places a torch at a target spot if enabled in config.
PlaceTorch:
    type: task
    script:
        - define NPC <[1]>
        - define TargetBlock <[NPC].flag[CurrentBlockMined].as_location>
        - narrate <[TargetBlock].below.material.is_solid>
        - if <[TargetBlock].below.material.is_solid>:
            - if <yaml[MinionConfig].read[Place_Torches_from_Inventory]>:
                - if <[NPC].inventory.contains.material[torch]>:
                    - take material:torch from:<[NPC].inventory>
                    - modifyblock <[TargetBlock]> torch

                - else:
                    - flag <[NPC]> CurrentBlockMined:!
                    - flag <[NPC]> StripStartingPosition:!
                    - narrate "I'm' out of torches :( My current location is - <[NPC].location.round.simple>"
            - else:
                - modifyblock <[TargetBlock]> torch

#Flags position from which the NPC will start mining a new strip
SetStripStartingPosition:
    type: task
    script:
        - define NPC <[1]>
        - define Strip# <[2]>
        - if <[NPC].has_flag[StripStartingPosition]>:
            - repeat <yaml[MinionConfig].read[StripMineDistance]>:
                - flag <[NPC]> StripStartingPosition:<[NPC].flag[StripStartingPosition].as_location.sub[<[NPC].flag[Direction].as_location.rotate_around_y[-1.5708].round_to_precision[1]>]>
#{            - modifyblock <[NPC].flag[StripStartingPosition]> dirt
            - narrate "Setting <[Strip#]> pos"
        - else if <[Strip#]> == 1:
            - flag <[NPC]> StripStartingPosition:<player.cursor_on>
            - narrate "Setting 1st pos"


#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MiningSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[NPC].flag[CurrentBlockMined].as_location>

        - if <[NPC].location.distance[<[CurrentBlockMined]>]> > 3.5:
            - walk <[CurrentBlockMined].add[<[NPC].flag[Direction].as_location>]> <[NPC]> auto_range
        - run DistanceCheck def:<[NPC]>|<[NPC].flag[CurrentBlockMined]>
        - waituntil !<[NPC].has_flag[CurrentBlockMined]> || <[NPC].location.distance[<[CurrentBlockMined]>]> < 3.5
        - if <[NPC].has_flag[CurrentBlockMined]>:
            - if !<[CurrentBlockMined].material.is_transparent>:
#{                - wait 0.15
                - animate <[NPC]> ARM_SWING
                - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
#{                - wait 0.25s
                - animate <[NPC]> ARM_SWING
                - give <[CurrentBlockMined].drops.get[1]> to:<[NPC].inventory>
                - modifyblock <[CurrentBlockMined]> air
                - blockcrack <[CurrentBlockMined]> progress:0
        - else:
            - narrate "Can't reach a block I'm trying to mine :( My current location is - <[NPC].location.round.simple>"

#Checks whether there is danger while mining and changes status of NPC if necessary
CheckingSubScript:
    type: task
    script:
        - define NPC <[1]>
        - define Target <[NPC].flag[CurrentBlockMined].as_location>
        - define Direction <[NPC].flag[Direction].as_location>
        - define StripStartingPosition <[NPC].flag[StripStartingPosition].as_location>

        - if !<[NPC].has_flag[CurrentBlockMined]>:
            - stop
        - else if <[Target].sub[<[Direction]>].material.is_transparent>:
            - ~run BlockConnectionCheck def:<[NPC]>|<[Target].sub[<[Direction]>]>|<list_single[<[StripStartingPosition].add[<[Direction]>]>|<[Target].add[<[Direction]>]>|<[Target].add[<[Direction]>].above>]>
            - if !<[NPC].has_flag[CurrentBlockMined]>:
                - narrate "Air in front detected, stopping mining <[2]>"
        - if <[Target].sub[<[Direction]>].is_liquid>:
            - narrate "Lava/Water in front detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].above.material.is_transparent> && <[2]> == Top:
            - ~run BlockConnectionCheck def:<[NPC]>|<[Target].above>|<list_single[<[StripStartingPosition].add[<[Direction]>]>|<[Target].add[<[Direction]>]>|<[Target].add[<[Direction]>].above>]>
            - if !<[NPC].has_flag[CurrentBlockMined]>:
                - narrate "Air above detected, stopping mining"
        - if <[Target].above.is_liquid> && <[2]> == Top:
            - narrate "Lava/Water above detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].below.material.is_transparent> && <[2]> == Bottom:
            - narrate "Air below detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].below.is_liquid> && <[2]> == Bottom:
            - narrate "Lava/Water below detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1]>].material.is_transparent>:
            - ~run BlockConnectionCheck def:<[NPC]>|<[Target].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1]>]>|<list_single[<[StripStartingPosition].add[<[Direction]>]>|<[Target].add[<[Direction]>]>|<[Target].add[<[Direction]>].above>]>
            - if !<[NPC].has_flag[CurrentBlockMined]>:
                - narrate "Right-side Air detected, stopping mining"
        - if <[Target].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Right-side Lava/Water detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!
        - else if <[Target].add[<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>].material.is_transparent>:
            - ~run BlockConnectionCheck def:<[NPC]>|<[Target].add[<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>]>|<list_single[<[StripStartingPosition].add[<[Direction]>]>|<[Target].add[<[Direction]>]>|<[Target].add[<[Direction]>].above>]>
            - if !<[NPC].has_flag[CurrentBlockMined]>:
                - narrate "Left-side Air detected, stopping mining"
        - if <[Target].add[<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>].is_liquid>:
            - narrate "Left-side Lava/Water detected, stopping mining"
            - flag <[NPC]> CurrentBlockMined:!


#If NPC is too far to reach the target block after 20s it stops trying to reach it
DistanceCheck:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - chunkload <[CurrentBlockMined].chunk> duration:11s
        - define Location <[NPC].location>
        - wait 3s
#Should I add cave air here?
        - while <[CurrentBlockMined].material.name> != air && <[CurrentBlockMined].material.name> != torch:
            - narrate <[Location].simple>
            - narrate "<[NPC].location.simple> sviezias"
            - if <[Location].simple> == <[NPC].location.simple>:
                - narrate "Rekt after 20s"
                - flag <[NPC]> CurrentBlockMined:!
                - stop
            - define Location <[NPC].location>
            - wait 3s
