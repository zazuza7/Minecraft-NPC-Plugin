OnBookClick:
    type: world
    events:
        on player clicks block with:written_book:
            - if <context.item.book_title> == Romeo:
                - determine passively cancelled
                - ratelimit <player> 1t

                - if <context.click_type>  == RIGHT_CLICK_AIR || <context.click_type>  == RIGHT_CLICK_BLOCK:
#If aimed at NPC, opens its inventory
                    - if <player.target.has_flag[role]||null> != null:
                        - inventory open d:<player.target.inventory>
#If there is a NPC selected
                    - else if <player.flag[Selected].as_npc||null> != null:
                        - define NPC <player.flag[Selected].as_npc>
                        - if <player.location.distance[<[NPC].location>]> <= 200:
#If aimed at chest, links it with currently selected NPC
                            - if <player.cursor_on.has_inventory> || <player.cursor_on.material.name> == ender_chest:
                                - flag <[NPC]> ChestLocation:<player.cursor_on>
                                - narrate "Chest Linked succesfully"
# NPC has to be able to jump on top of chest
                                - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation].as_location.above>
                                - ~run Collect&Deposit&Clear def:<[NPC]>
# If NPC is miner type and player is aiming at a normal block - starts mining
                            - else if <[NPC].inventory.slot[36].material.name> == wooden_pickaxe:
                                - run MiningTask def:<[NPC]>
                            - else:
                                - narrate "I lack purpose. Please put a tool in my last slot."
                    - else:
                        - narrate "No selected NPCs found nearby"

                - else if <context.click_type>  == LEFT_CLICK_AIR || <context.click_type>  == LEFT_CLICK_BLOCK:
#Sselects a NPC if aimed at one
                    - if <player.target.has_flag[Role]>:
                        - flag <player> Selected:<player.target>
#Or Spawns a NPC and sets its parameters
                    - else:
                        - create player Mr.Slave <player.location>
                        - flag <player.target> Role:Undefined
                        - flag <player.target> Owner:<player>
                        - flag <player> Selected:<player.target>
                        - adjust <player.target> Owner:<player>
                        - adjust <player.target> Teleport_on_Stuck:false
                        - vulnerable npc:<player.target>
                        - health <player.target> state:true
                        - adjust <player.target> max_health:4
                        - adjust <player.target> skin:Slave
