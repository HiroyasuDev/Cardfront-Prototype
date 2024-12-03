-- game constants
grid_size = 3
cell_size = 24
hand_card_size = 20
hand_cursor = 1

-- state constants
state_title = 0
state_main_menu = 1
state_playing = 2
state_game_over = 3

-- menu items
menu_items = {"single mode", "versus mode", "stats", "options"}
menu_cursor = 1

-- game state variables
grid = {}
current_player = 0
selected_card = nil
ai_delay = 0
card_selected = false
game_state = state_title
winner = ""
player_wins = 0
opponent_wins = 0
draws = 0
draw_count = 0

-- cursor position on grid
cursor_x = 1
cursor_y = 1

-- score variables
player_score = 0
opponent_score = 0

-- overlay for scoring feedback
score_overlays = {}

-- animation variables for floating effect
turn_indicator_y = 105
turn_indicator_float = 0
float_timer = 0

-- faster animation variables for captured card effects
capture_animations = {}

-- turn indicator text
turn_text = "player's turn"

-- table to store confetti particles
confetti_particles = {}

-- initialize the game state and confetti
function _init()
    game_state = state_title
    player_wins = 0
    opponent_wins = 0
    init_confetti()
end

-- create a card
function create_card(top, right, bottom, left, owner)
    return { top = top, right = right, bottom = bottom, left = left, owner = owner }
end

-- shuffle the cards in a given deck
function shuffle_cards(deck)
    for i = #deck, 2, -1 do
        local j = flr(rnd(i)) + 1
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- reset cards for both players with shuffle
function reset_cards()
    player_cards = {
        create_card(5, 3, 2, 6, 0),
        create_card(4, 4, 6, 2, 0),
        create_card(3, 5, 4, 3, 0),
        create_card(2, 7, 2, 4, 0),
        create_card(6, 3, 5, 6, 0)
    }
    shuffle_cards(player_cards)
    
    opponent_cards = {
        create_card(4, 6, 3, 1, 1),
        create_card(6, 2, 5, 4, 1),
        create_card(2, 5, 3, 6, 1),
        create_card(7, 3, 6, 2, 1),
        create_card(5, 6, 4, 3, 1)
    }
    shuffle_cards(opponent_cards)
end

-- initialize the grid
function init_grid()
    grid = {}
    for x = 1, grid_size do
        grid[x] = {}
        for y = 1, grid_size do
            grid[x][y] = nil
        end
    end
end

-- reset the entire game
function reset_game()
    init_grid()
    reset_cards()
    player_score = 0
    opponent_score = 0
    current_player = 0
    selected_card = nil
    card_selected = false
    ai_delay = 0
    hand_cursor = 1
    turn_text = "player's turn"
    winner = ""
    cursor_x = 1
    cursor_y = 1
    score_overlays = {}
    capture_animations = {}
end

-- title screen logic
function draw_title_screen()
    cls()
    print("cardfront: prototype", 20, 40, 7)
    print("press ❎ to start", 40, 60, 7)
end

-- main menu screen logic
function draw_main_menu()
    cls()
    print("main menu", 40, 20, 7)
    for i, item in ipairs(menu_items) do
        local color = (i == menu_cursor) and 12 or 7
        print(item, 40, 30 + i * 10, color)
    end
end

-- handle main menu input
function handle_menu_input()
    if btnp(2) then
        menu_cursor = max(1, menu_cursor - 1)
    elseif btnp(3) then
        menu_cursor = min(#menu_items, menu_cursor + 1)
    elseif btnp(4) then
        if menu_cursor == 1 or menu_cursor == 2 then
            reset_game()
            game_state = state_playing
        elseif menu_cursor == 3 or menu_cursor == 4 then
            game_state = state_title
        end
    end
end

-- rest of the code follows...

-- check if the grid is full
function is_grid_full()
    for x = 1, grid_size do
        for y = 1, grid_size do
            if grid[x][y] == nil then
                return false
            end
        end
    end
    return true
end

-- count card ownership
function count_ownership()
    local player_count = 0
    local opponent_count = 0
    for x = 1, grid_size do
        for y = 1, grid_size do
            local card = grid[x][y]
            if card ~= nil then
                if card.owner == 0 then
                    player_count += 1
                elseif card.owner == 1 then
                    opponent_count += 1
                end
            end
        end
    end
    return player_count, opponent_count
end

-- update scores and start capture animation
function update_scores(flip_positions, capturing_owner)
    player_score, opponent_score = count_ownership()
    for _, pos in ipairs(flip_positions) do
        start_capture_animation(pos.x, pos.y, capturing_owner, pos.direction)
    end
end

-- start capture animation
function start_capture_animation(grid_x, grid_y, new_owner, direction)
    local grid_offset_x = 29
    local grid_offset_y = 20
    local screen_x = grid_offset_x + (grid_x - 1) * cell_size
    local screen_y = grid_offset_y + (grid_y - 1) * cell_size

    add(capture_animations, {
        x = screen_x,
        y = screen_y,
        timer = 10,
        scale_x = 1,
        scale_y = 1,
        direction = direction,
        new_owner = new_owner
    })
end

-- update capture animations
function update_capture_animations()
    for i = #capture_animations, 1, -1 do
        local anim = capture_animations[i]
        anim.timer -= 1
        if anim.direction == "horizontal" then
            if anim.timer > 5 then
                anim.scale_x -= 0.25
            else
                anim.scale_x += 0.25
            end
        elseif anim.direction == "vertical" then
            if anim.timer > 5 then
                anim.scale_y -= 0.25
            else
                anim.scale_y += 0.25
            end
        end
        if anim.timer <= 0 then
            deli(capture_animations, i)
        end
    end
end

-- show score overlay
function show_score_overlay(text, grid_x, grid_y, color)
    local grid_offset_x = 29
    local grid_offset_y = 20
    local screen_x = grid_offset_x + (grid_x - 1) * cell_size
    local screen_y = grid_offset_y + (grid_y - 1) * cell_size - 8
    add(score_overlays, {text = text, x = screen_x, y = screen_y, timer = 60, color = color or 10})
end

-- update overlays
function update_overlay()
    update_capture_animations()
    for i = #score_overlays, 1, -1 do
        local overlay = score_overlays[i]
        overlay.timer -= 1
        overlay.y -= 0.25
        if overlay.timer <= 0 then
            deli(score_overlays, i)
        end
    end
end

-- draw capture animations
function draw_capture_animations()
    for anim in all(capture_animations) do
        local color = anim.new_owner == 0 and 8 or 9
        local size_x = cell_size * anim.scale_x
        local size_y = cell_size * anim.scale_y
        rectfill(anim.x, anim.y, anim.x + cell_size - 1, anim.y + cell_size - 1, 5)
        rect(anim.x, anim.y, anim.x + cell_size - 1, anim.y + cell_size - 1, 7)
        if anim.scale_x > 0.1 and anim.scale_y > 0.1 then
            local offset_x = (cell_size - size_x) / 2
            local offset_y = (cell_size - size_y) / 2
            rectfill(anim.x + offset_x, anim.y + offset_y, anim.x + size_x + offset_x - 1, anim.y + size_y + offset_y - 1, color)
        end
    end
end

-- initialize confetti particles
function init_confetti()
    confetti_particles = {}
    for i = 1, 50 do
        add(confetti_particles, {
            x = rnd(128),
            y = rnd(-64, -16),
            speed = rnd(2) + 1,
            color = flr(rnd(8)) + 8
        })
    end
end

-- update confetti particles
function update_confetti()
    for particle in all(confetti_particles) do
        particle.y += particle.speed
        if particle.y > 128 then
            particle.y = rnd(-20, -5)
            particle.x = rnd(128)
        end
    end
end

-- draw confetti particles
function draw_confetti()
    for particle in all(confetti_particles) do
        rectfill(particle.x, particle.y, particle.x + 1, particle.y + 1, particle.color)
    end
end

-- check for game over
function check_game_over()
    if is_grid_full() then
        update_scores({}, current_player)
        if player_score > opponent_score then
            winner = "player wins!"
            player_wins += 1
            init_confetti()
        elseif opponent_score > player_score then
            winner = "opponent wins!"
            opponent_wins += 1
        else
            winner = "it's a draw!"
            draw_count += 1
        end
        game_state = state_game_over
    end
end

-- ai opponent logic
function ai_turn()
    if ai_delay > 0 then
        ai_delay -= 1
        return
    end
    turn_text = "opponent's turn"
    if is_grid_full() then
        check_game_over()
        return
    end
    local best_card, best_x, best_y, best_score = nil, nil, nil, -9999
    for i, card in pairs(opponent_cards) do
        if card ~= nil then
            for x = 1, grid_size do
                for y = 1, grid_size do
                    if grid[x][y] == nil then
                        local score = evaluate_move(card, x, y)
                        if score > best_score then
                            best_score = score
                            best_card, best_x, best_y = card, x, y
                        end
                    end
                end
            end
        end
    end
    if best_card ~= nil then
        place_card(best_card, best_x, best_y)
        for i, card in pairs(opponent_cards) do
            if card == best_card then
                opponent_cards[i] = nil
                break
            end
        end
    end
    if is_grid_full() then
        check_game_over()
    end
end

-- evaluate a potential move
function evaluate_move(card, x, y)
    local score = 0
    if (x == 2 and y == 2) then
        score += 3
    elseif (x == 1 or x == 3) and (y == 1 or y == 3) then
        score += 2
    else
        score += 1
    end
    score += evaluate_adjacent_flips(card, x, y)
    return score
end

-- evaluate adjacent flips
function evaluate_adjacent_flips(card, x, y)
    local flip_score = 0
    if x > 1 and grid[x-1][y] ~= nil and grid[x-1][y].owner ~= card.owner and card.left > grid[x-1][y].right then
        flip_score += 3
    end
    if y < grid_size and grid[x][y+1] ~= nil and grid[x][y+1].owner ~= card.owner and card.bottom > grid[x][y+1].top then
        flip_score += 3
    end
    if x < grid_size and grid[x+1][y] ~= nil and grid[x+1][y].owner ~= card.owner and card.right > grid[x+1][y].left then
        flip_score += 3
    end
    if y > 1 and grid[x][y-1] ~= nil and grid[x][y-1].owner ~= card.owner and card.top > grid[x][y-1].bottom then
        flip_score += 3
    end
    return flip_score
end

-- place a card on the grid
function place_card(card, x, y)
    if x >= 1 and x <= grid_size and y >= 1 and y <= grid_size and grid[x][y] == nil then
        grid[x][y] = card
        check_and_flip(card, x, y)
        switch_turn()
        check_game_over()
    end
end

-- check and flip adjacent cards
function check_and_flip(card, x, y)
    local flip_positions = {}
    if x > 1 and grid[x-1][y] ~= nil and grid[x-1][y].owner ~= card.owner and card.left > grid[x-1][y].right then
        grid[x-1][y].owner = card.owner
        add(flip_positions, {x = x-1, y = y, direction = "horizontal"})
    end
    if y < grid_size and grid[x][y+1] ~= nil and grid[x][y+1].owner ~= card.owner and card.bottom > grid[x][y+1].top then
        grid[x][y+1].owner = card.owner
        add(flip_positions, {x = x, y = y+1, direction = "vertical"})
    end
    if x < grid_size and grid[x+1][y] ~= nil and grid[x+1][y].owner ~= card.owner and card.right > grid[x+1][y].left then
        grid[x+1][y].owner = card.owner
        add(flip_positions, {x = x+1, y = y, direction = "horizontal"})
    end
    if y > 1 and grid[x][y-1] ~= nil and grid[x][y-1].owner ~= card.owner and card.top > grid[x][y-1].bottom then
        grid[x][y-1].owner = card.owner
        add(flip_positions, {x = x, y = y-1, direction = "vertical"})
    end
    if #flip_positions > 0 then
        update_scores(flip_positions, card.owner)
    end
end

-- switch turns
function switch_turn()
    current_player = 1 - current_player
    if current_player == 0 then
        turn_text = "player's turn"
        ai_delay = 0
        card_selected = false
        auto_select_card()
    else
        turn_text = "opponent is thinking..."
        ai_delay = 60
    end
end

-- automatically select the first available card
function auto_select_card()
    hand_cursor = 1
    while player_cards[hand_cursor] == nil and hand_cursor < #player_cards do
        hand_cursor += 1
    end
end

-- draw the game grid
function draw_grid()
    local grid_offset_x = 29
    local grid_offset_y = 20
    for x = 1, grid_size do
        for y = 1, grid_size do
            local x_pos = grid_offset_x + (x - 1) * cell_size
            local y_pos = grid_offset_y + (y - 1) * cell_size
            rect(x_pos, y_pos, x_pos + cell_size - 1, y_pos + cell_size - 1, 7)
            local card = grid[x][y]
            if card ~= nil then
                draw_card(card, x_pos, y_pos, cell_size)
            end
        end
    end
    if card_selected then
        local cursor_x_pos = grid_offset_x + (cursor_x - 1) * cell_size
        local cursor_y_pos = grid_offset_y + (cursor_y - 1) * cell_size
        rect(cursor_x_pos, cursor_y_pos, cursor_x_pos + cell_size - 1, cursor_y_pos + cell_size - 1, 12)
    end
    draw_capture_animations()
end

-- draw a card
function draw_card(card, x, y, size)
    local color = card.owner == 0 and 8 or 9
    rectfill(x, y, x + size - 1, y + size - 1, color)
    local top_offset_y = 2
    local bottom_offset_y = size - 8
    local left_offset_x = 2
    local right_offset_x = size - 6
    local center_x = x + flr(size / 2)
    local center_y = y + flr(size / 2)
    print(card.top, center_x - 2, y + top_offset_y, 7)
    print(card.right, x + right_offset_x, center_y - 2, 7)
    print(card.bottom, center_x - 2, y + bottom_offset_y, 7)
    print(card.left, x + left_offset_x, center_y - 2, 7)
end

-- draw hands
function draw_hands()
    -- draw player hand
    for i = 1, 5 do
        local card = player_cards[i]
        if card ~= nil then
            local x_pos = 2
            local y_pos = (i - 1) * (hand_card_size + 2) + 10
            -- always draw the selection indicator when `hand_cursor` is at this card
            if i == hand_cursor and not card_selected and current_player == 0 then
                rect(x_pos - 2, y_pos - 2, x_pos + hand_card_size + 1, y_pos + hand_card_size + 1, 12) -- yellow outline
            end
            draw_card(card, x_pos, y_pos, hand_card_size)
        end
    end

    -- draw opponent hand
    for i = 1, 5 do
        local card = opponent_cards[i]
        if card ~= nil then
            local x_pos = 128 - hand_card_size
            local y_pos = (i - 1) * (hand_card_size + 2) + 10
            draw_card(card, x_pos, y_pos, hand_card_size)
        end
    end
end

-- update the floating animation for the turn indicator
function update_turn_indicator()
    float_timer += 1
    turn_indicator_float = sin(float_timer / 15) * 2
end

-- draw the animated turn indicator below the grid
function draw_turn_indicator()
    local x = 40
    local y = turn_indicator_y + turn_indicator_float

    if turn_text == "opponent is thinking..." then
        -- display "opponent" and "is thinking..." on separate lines
        print("opponent", x, y - 4, 7)
        print("is thinking...", x, y + 4, 7)
    else
        -- display single-line turn text for the player
        print(turn_text, x, y, 7)
    end
end

-- draw score display
function draw_score()
    print("player: " .. player_score, 2, 2, 7)
    print("opponent: " .. opponent_score, 85, 2, 7)
end

-- draw score overlays
function draw_overlay()
    for overlay in all(score_overlays) do
        print(overlay.text, overlay.x, overlay.y, overlay.color)
    end
end

-- handle player input
function handle_input()
    if not card_selected then
        local available_slots = {}
        for i = 1, #player_cards do
            if player_cards[i] ~= nil then
                add(available_slots, i)
            end
        end
        local cursor_index = 0
        for i = 1, #available_slots do
            if available_slots[i] == hand_cursor then
                cursor_index = i
                break
            end
        end
        if btnp(2) or btnp(0) then
            cursor_index = (cursor_index - 2) % #available_slots + 1
            hand_cursor = available_slots[cursor_index]
        elseif btnp(3) or btnp(1) then
            cursor_index = (cursor_index) % #available_slots + 1
            hand_cursor = available_slots[cursor_index]
        end
        if btnp(4) and player_cards[hand_cursor] ~= nil then
            selected_card = player_cards[hand_cursor]
            card_selected = true
        end
    else
        if btnp(2) then cursor_y = max(1, cursor_y - 1) end
        if btnp(3) then cursor_y = min(grid_size, cursor_y + 1) end
        if btnp(0) then cursor_x = max(1, cursor_x - 1) end
        if btnp(1) then cursor_x = min(grid_size, cursor_x + 1) end
        if btnp(5) and grid[cursor_x][cursor_y] == nil then
            place_card(selected_card, cursor_x, cursor_y)
            player_cards[hand_cursor] = nil
            card_selected = false
            selected_card = nil
        end
    end
end

-- handle input on end game screen
function handle_end_game_input()
    if btnp(4) then
        reset_game()
        game_state = state_playing
        init_confetti()
    elseif btnp(5) then
        reset_game()
        player_score = 0
        opponent_score = 0
        game_state = state_main_menu
    end
end

-- draw the end game screen
function draw_end_game_screen()
    cls()
    print(winner, 40, 8, 7)
    print("cards captured:", 10, 24, 7)
    print("player: " .. player_score, 10, 34, 7)
    print("opponent: " .. opponent_score, 10, 44, 7)
    print("matches:", 10, 60, 7)
    print("wins: " .. player_wins, 10, 70, 7)
    print("losses: " .. opponent_wins, 10, 80, 7)
    print("draws: " .. draw_count, 10, 90, 7)
    print("press ❎ to rematch", 40, 105, 7)
    print("press 🅾️ to main menu", 40, 115, 7)
end

-- main update loop
function _update()
    if game_state == state_title then
        if btnp(4) then
            game_state = state_main_menu
        end
    elseif game_state == state_main_menu then
        handle_menu_input()
    elseif game_state == state_playing then
        if current_player == 1 then
            ai_turn()
        else
            handle_input()
        end
        update_turn_indicator()
        update_overlay()
        if is_grid_full() and game_state ~= state_game_over then
            check_game_over()
        end
    elseif game_state == state_game_over then
        if winner == "player wins!" then
            update_confetti()
        end
        handle_end_game_input()
    end
end

-- main draw loop
function _draw()
    cls()
    if game_state == state_title then
        draw_title_screen()
    elseif game_state == state_main_menu then
        draw_main_menu()
    elseif game_state == state_playing then
        draw_grid()
        draw_hands()
        draw_score()
        draw_turn_indicator()
        draw_overlay()
    elseif game_state == state_game_over then
        if winner == "player wins!" then
            draw_confetti()
        end
        draw_end_game_screen()
    end
end
