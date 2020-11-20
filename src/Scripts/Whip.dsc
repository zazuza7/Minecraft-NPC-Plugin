OnBookClick:
    type: world
    events:
        on player clicks block with:written_book:
            - if <context.item.book_title> == Romeo:
                - ratelimit <player> 1t
                - determine passively cancelled
#If aimed at NPC, opens its inventory
#Else if aimed at chest, links it with currently selected NPC
#Else if aimed at a block, starts mining
                - if <context.click_type>  == RIGHT_CLICK_AIR || <context.click_type>  == RIGHT_CLICK_BLOCK:
                    - define NPC <player.flag[Selected].as_npc>
                    - if <player.target.has_flag[role]>:
                        - inventory open d:<player.target.inventory>
                    - else if <player.location.distance[<[NPC].location>]> <= 200:

                        - if <player.cursor_on.has_inventory> || <player.cursor_on.material.name> == ender_chest:
                            - flag <[NPC]> ChestLocation:<player.cursor_on>
                            - narrate "Chest Linked succesfully"
# NPC has to be able to jump on top of chest
                            - ~run LongWalk def:<[NPC]>|<[NPC].flag[ChestLocation].as_location.above>
                            - ~run Collect&Deposit&Clear def:<[NPC]>
# If NPC is miner type
                        - else if <[NPC].inventory.slot[36].material.name> == wooden_pickaxe:
                            - run MiningTask def:<[NPC]>
                        - else:
                            - narrate "I lack purpose. Please put a tool in my last slot."
                    - else:
                        - narrate "No selected NPCs found nearby"
#Spawns a NPC and sets its parameters or selects one if aimed at
                - else if <context.click_type>  == LEFT_CLICK_AIR || <context.click_type>  == LEFT_CLICK_BLOCK:
                    - if <player.target.has_flag[Role]>:
                        - flag <player> Selected:<player.target>
                    - else:
                        - create player Mr.Slave <player.location>
                        - flag <player.target> Role:Undefined
                        - flag <player> Selected:<player.target>
                        - adjust <player.target> Owner:<player>
                        - adjust <player.target> Teleport_on_Stuck:false
                        - vulnerable npc:<player.target>
                        - health <player.target> state:true
                        - adjust <player.target> max_health:4
                        - adjust <player.target> skin:Slave
