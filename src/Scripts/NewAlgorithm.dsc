TopFunction:
    type: task
    script:
    - define Width <yaml[MinionConfig].read[Strip_Width]>
    - define Height <yaml[MinionConfig].read[Strip_Height]>
    - define StripMineDistance <yaml[MinionConfig].read[StripMineDistance]>
#Should expose this variable to .yml?
    - define Depth 2
    - define NPC <[1]>
    - define InitialLocation <[2]>
    - define Direction <[3]>
    - flag <[NPC]> StopMining:!
    - define NextInitialLocationVector <[Direction].rotate_around_y[-1.5708].round_to_precision[1].mul[<[StripMineDistance].add[<[Width].sub[1]>]>]>

    - while !<[NPC].has_flag[StopMining]>  && <[NPC].is_spawned>:
        - ~run SingleStripMining def:<[NPC]>|<[InitialLocation]>|<[Direction]>|<[Depth]>
        - define InitialLocation:<[InitialLocation].add[<[NextInitialLocationVector]>]>
        - if <[NPC].has_flag[ChestLocation]>:
            - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation]>
            - ~run Collect&Deposit&Clear def:<[NPC]>
        - else:
            - narrate "I don't have a linked chest :( My current location is - <[NPC].location.round.simple>"
            - flag <[NPC]> StopMining:1
#Changes direction and mines until reaching next strip
        - ~run SingleStripMining def:<[NPC]>|<[InitialLocation].sub[<[Direction]>].add[<[Direction].rotate_around_y[1.5708].round_to_precision[1].mul[<[StripMineDistance]>]>]>|<[Direction].rotate_around_y[-1.5708].round_to_precision[1]>|<[StripMineDistance].add[<[Width]>]>
        - if <[NPC].has_flag[StopMiningStrip]>:
            - flag <[NPC]> StopMining:1
    - narrate "Can't mine any further :( My current location is - <[NPC].location.round.simple> "
    - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation]>
    - ~run Collect&Deposit&Clear def:<[NPC]>



SingleStripMining:
    type: task
    script:
    - define Width <yaml[MinionConfig].read[Strip_Width]>
    - define Height <yaml[MinionConfig].read[Strip_Height]>
    - define NPC <[1]>
    - define InitialLocation <[2]>
    - define Direction <[3]>
    - define Depth <[4]>
    - define CurrentLocation <[InitialLocation]>
    - define InvalidBlockCounter:0
    - define SavedLoopIndex:0

    - flag <[NPC]> StopMiningStrip:!

    - define LocationsNotToMine:->:1
    - define LocationsNotToMine:<-:1
#Vectors of length 1 with directions relative to mining direction
    - define Left <[Direction].rotate_around_y[1.5708].round_to_precision[1]>
    - define Right <[Direction].rotate_around_y[-1.5708].round_to_precision[1]>
    - define Front <[Direction]>
    - define Back <[Direction].rotate_around_y[-1.5708].rotate_around_y[-1.5708].round_to_precision[1]>
    - define Top <location[0,1,0]>
    - define Bottom <location[0,-1,0]>
#Width*Height
    - define H*W <[Width].mul[<[Height]>]>

    - define NewDepthVector <[Front].add[<[Top].mul[<[Height].sub[1]>]>]>
    - define NewDepthVector <[NewDepthVector].add[<[Left].mul[<[Width].sub[1]>]>]>

    - define NewVerticalLineVector <[Right].add[<[Top].mul[<[Height].sub[1]>]>]>
    - while <[SavedLoopIndex]> < <[H*W].mul[<[Depth]>]> && !<[NPC].has_flag[StopMiningStrip]> && !<[NPC].has_flag[StopMining]> && <[NPC].is_spawned>:
        - define SavedLoopIndex <[loop_index]>
        - flag <[NPC]> StopMiningBlock:!
#Check front block for hazards
#If same location gets added to the list more than once - it could clog it up. Should test that out.
        - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Front]>]>|<[InitialLocation].add[<[Back]>]>
        - if <[NPC].has_flag[StopMiningBlock]>:
            - define HazardousLocation:<[CurrentLocation].add[<[Front]>]>
            - define LocationsNotToMine:->:<[HazardousLocation]>
            - define LocationsNotToMine:->:<[HazardousLocation].add[<[Front]>]>
            - define LocationsNotToMine:->:<[HazardousLocation].sub[<[Front]>]>
    #Current block is not on the left side of the strip
            - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> >= <[Height]>:
                - define LocationsNotToMine:->:<[HazardousLocation].add[<[Left]>]>
    #Current block is not on the right side of the strip
            - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> < <[H*W].sub[<[Height]>]>:
                - define LocationsNotToMine:->:<[HazardousLocation].add[<[Right]>]>
    #Current block is not on the top side of the strip
            - if <[SavedLoopIndex].mod[<[Height]>]> != 1 && <[Height]> != 1:
                - define LocationsNotToMine:->:<[HazardousLocation].above>
    #Current block is not on the bottom side of the strip
            - if <[SavedLoopIndex].mod[<[Height]>]> != 0:
                - define LocationsNotToMine:->:<[HazardousLocation].below>


#If there is a new block revealed on left side - check it
        - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> < <[Height]>:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Left]>]>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on right side - check it
        - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> >= <[H*W].sub[<[Height]>]>:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].add[<[Right]>]>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on top side - check it
        - if <[SavedLoopIndex].mod[<[Height]>]> == 1 || <[Height]> == 1:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].above>|<[InitialLocation].add[<[Back]>]>
#If there is a new block revealed on Bottom side - check it
        - if <[SavedLoopIndex].mod[<[Height]>]> == 0:
            - run CheckNewBlock def:<[NPC]>|<[CurrentLocation].below>|<[InitialLocation].add[<[Back]>]>

#Checks if current location is not supposed to be mined
        - foreach <[LocationsNotToMine]> as:Location:
            - if <[Location]> == <[CurrentLocation]>:
                - define LocationsNotToMine:<-:<[Location]>
                - flag <[NPC]> StopMiningBlock:1
                - foreach stop
#Mine current block
        - if !<[NPC].has_flag[StopMiningBlock]>:
            - ~run MineSingleBlock def:<[NPC]>|<[CurrentLocation]>|<[Direction]>
            - if !<[NPC].has_flag[StopMiningBlock]>:
                - define InvalidBlockCounter:0
            - else:
                - define InvalidBlockCounter:++
        - else:
            - define InvalidBlockCounter:++

#Places a torch
#If Placing torches is enabled in config
        - if <yaml[MinionConfig].read[Place_Torches]>:
    #If current block mined is in the bottom row
            - if <[SavedLoopIndex].mod[<[Height]>]> == 0:
        #If the block mined is in the middle column
                - if <[SavedLoopIndex].sub[1].mod[<[H*W]>]> >= <[Width].div[2].round_down.mul[<[Height]>]> && <[SavedLoopIndex].sub[1].mod[<[H*W]>]> < <[Width].div[2].round_down.mul[<[Height]>].add[<[Height]>]>:
            #If should place torch at current depth
                    - if <[SavedLoopIndex].sub[1].div[<[H*W]>].round_down.add[1].mod[<yaml[MinionConfig].read[TorchDistance]>]> == 1:
                #If NPC mined the block previously there
                        - if !<[NPC].has_flag[StopMiningBlock]>:
                            - ~run PlaceTorch def:<[NPC]>|<[CurrentLocation]>

#Find next block to mine
        - if <[SavedLoopIndex].mod[<[H*W]>]> == 0:
            - define CurrentLocation <[CurrentLocation].add[<[NewDepthVector]>]>
        - else if <[SavedLoopIndex].mod[<[Height]>]> == 0:
            - define CurrentLocation <[CurrentLocation].add[<[NewVerticalLineVector]>]>
        - else:
            - define CurrentLocation <[CurrentLocation].below>
#Check whether NPC should stop mining
    #If NPC no longer has a pickaxe
        - if <[NPC].inventory.slot[1].material.name> != iron_pickaxe && <[NPC].inventory.slot[1].material.name> != diamond_pickaxe:
            - flag <[NPC]> StopMining:1
    #This line is Greedy, mining could fail earlier than that. Should be changed if I'll have time
        - else if <[InvalidBlockCounter]> > <[H*W].sub[2]>:
            - flag <[NPC]> StopMiningStrip:1
            - narrate "Too many block errors"

CheckNewBlock:
    type: task
    script:
    - define NPC <[1]>
    - define Location <[2]>
    - define InitialLocation <[3]>
    - if <[Location].material.name> == air || <[Location].material.name> == cave_air:
        - ~run BlockConnectionCheck def:<[NPC]>|<[Location]>|<list_single[<[NPC].location>|<[InitialLocation]>]>
    - else if <[Location].is_liquid>:
        - flag <[NPC]> StopMiningBlock:1
#{        - narrate StopMiningLiquid



#NPC moves towards a single target block and simulates mining it, while receiving drops to its inventory
MineSingleBlock:
    type: task
    script:
        - define NPC <[1]>
        - define CurrentBlockMined <[2]>
        - define Direction <[3]>
        - define DistanceOfMining <yaml[MinionConfig].read[Mining_Range]>
        - if <[NPC].is_spawned>:
            - if <[NPC].location.distance[<[CurrentBlockMined]>]> > <[DistanceOfMining]>:
    #Should change this to a long-walk
                - ~walk <[CurrentBlockMined].sub[<[Direction]>]> <[NPC]> auto_range
            - if <[NPC].location.distance[<[CurrentBlockMined]>]> <= <[DistanceOfMining]>:
                - if !<[CurrentBlockMined].material.is_transparent>:
#{                    - wait 0.1
                    - ~animate <[NPC]> ARM_SWING
                    - blockcrack <[CurrentBlockMined]> progress:<util.random.int[4].to[7]>
#{                    - wait 0.4s
                    - ~animate <[NPC]> ARM_SWING
                    - give <[CurrentBlockMined].drops.get[1]> to:<[NPC].inventory>
                    - modifyblock <[CurrentBlockMined]> air
                    - blockcrack <[CurrentBlockMined]> progress:0
                - else:
                    - narrate "Block I'm trying to mine is transparent :( My current location is - <[NPC].location.round.simple>"
            - else:
                    - narrate "Can't reach target block"
                    - flag <[NPC]> StopMiningBlock:1

#Places a torch at a target spot if enabled in config.
PlaceTorch:
    type: task
    script:
        - define NPC <[1]>
        - define TargetBlock <[2]>
        - if <[TargetBlock].below.material.is_solid>:
            - if <yaml[MinionConfig].read[Place_Torches_from_Inventory]>:
                - if <[NPC].inventory.contains.material[torch]>:
                    - take material:torch from:<[NPC].inventory>
                - else:
                    - flag <[NPC]> StopMining:1
                    - narrate "I'm out of torches :( My current location is - <[NPC].location.round.simple>"
                    - stop
            - wait 1s
            - modifyblock <[TargetBlock]> torch