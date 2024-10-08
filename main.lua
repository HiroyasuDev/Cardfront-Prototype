grid_size = 3
cell_size = 24  -- slightly reduced to fit better on screen
hand_card_size = 20  -- smaller card size for hands
hand_cursor = 1  -- to track which card in the player's hand is currently selected

-- game state variables
grid = {}
current_player = 0  -- 0 for player, 1 for opponent
selected_card = nil -- the currently selected card
ai_delay = 0        -- delay timer for ai moves
card_selected = false  -- track if a card is selected for placement

-- cursor position on the grid
cursor_x = 1  -- start at the top-left of the grid (1,1)
cursor_y = 1

-- initialize the grid (3x3)
function init_grid()
    for x = 1, grid_size do
        grid[x] = {}
        for y = 1, grid_size do
            grid[x][y] = nil  -- empty cells at start
        end
    end
end

-- function to create a card
function create_card(top, right, bottom, left, owner)
    return { top = top, right = right, bottom = bottom, left = left, owner = owner }
end

-- 10 distinct example cards for player and opponent
player_cards = {
    create_card(5, 3, 2, 6, 0),
    create_card(4, 4, 6, 2, 0),
    create_card(3, 5, 4, 3, 0),
    create_card(2, 7, 2, 4, 0),
    create_card(6, 3, 5, 6, 0),
    create_card(3, 6, 7, 3, 0),
    create_card(4, 5, 5, 4, 0),
    create_card(6, 2, 3, 7, 0),
    create_card(5, 6, 3, 2, 0),
    create_card(7, 3, 6, 4, 0)
}

opponent_cards = {
    create_card(4, 6, 3, 1, 1),
    create_card(6, 2, 5, 4, 1),
    create_card(2, 5, 3, 6, 1),
    create_card(7, 3, 6, 2, 1),
    create_card(5, 6, 4, 3, 1),
    create_card(6, 3, 5, 2, 1),
    create_card(3, 6, 2, 7, 1),
    create_card(4, 7, 6, 3, 1),
    create_card(5, 4, 6, 2, 1),
    create_card(2, 6, 3, 7, 1)
}

-- function to check if the grid is full
function is_grid_full()
    for x = 1, grid_size do
        for y = 1, grid_size do
            if grid[x][y] == nil then
                return false  -- found an empty space
            end
        end
    end
    return true  -- no empty spaces
end

-- ai opponent logic to place a card after a delay
function ai_turn()
    if ai_delay > 0 then
        ai_delay = ai_delay - 1
        return  -- wait for the delay to finish
    end

    -- check if the grid is full before the ai places a card
    if is_grid_full() then
        print("game over - no more moves!")
        return  -- stop ai turn if the grid is full
    end

    -- pick the first available card in opponent's hand
    for i, card in pairs(opponent_cards) do
        if card ~= nil then
            -- find the first empty spot on the grid
            for x = 1, grid_size do
                for y = 1, grid_size do
                    if grid[x][y] == nil then
                        -- place the card
                        place_card(card, x, y)
                        opponent_cards[i] = nil  -- remove the card from the hand after placement
                        return  -- end ai turn
                    end
                end
            end
        end
    end
end

-- place a card on the grid at position (x, y)
function place_card(card, x, y)
    if x >= 1 and x <= grid_size and y >= 1 and y <= grid_size then
        if grid[x][y] == nil then
            grid[x][y] = card
            check_and_flip(card, x, y)  -- flip adjacent cards if possible
            switch_turn()  -- move to the next player's or ai's turn
        end
    else
        print("out of bounds: x=" .. x .. ", y=" .. y)
    end
end

-- check and flip adjacent cards
function check_and_flip(card, x, y)
    if x > 1 and grid[x-1][y] ~= nil then
        local adj_card = grid[x-1][y]
        if card.top > adj_card.bottom then
            adj_card.owner = card.owner
        end
    end
    if y < grid_size and grid[x][y+1] ~= nil then
        local adj_card = grid[x][y+1]
        if card.right > adj_card.left then
            adj_card.owner = card.owner
        end
    end
    if x < grid_size and grid[x+1][y] ~= nil then
        local adj_card = grid[x+1][y]
        if card.bottom > adj_card.top then
            adj_card.owner = card.owner
        end
    end
    if y > 1 and grid[x][y-1] ~= nil then
        local adj_card = grid[x][y-1]
        if card.left > adj_card.right then
            adj_card.owner = card.owner
        end
    end
end

-- draw the grid and highlight cursor
function draw_grid()
    -- keep the grid where it is
    local grid_offset_x = 29  -- don't move
    local grid_offset_y = 20  -- vertically aligned

    for x = 1, grid_size do
        for y = 1, grid_size do
            -- adjust x_pos and y_pos to center the grid
            local x_pos = grid_offset_x + (x - 1) * cell_size
            local y_pos = grid_offset_y + (y - 1) * cell_size

            -- draw grid cell
            rect(x_pos, y_pos, x_pos + cell_size - 1, y_pos + cell_size - 1, 7)

            -- draw the card if it's in this cell
            local card = grid[x][y]
            if card ~= nil then
                draw_card(card, x_pos, y_pos, cell_size)  -- drawing with standard grid size
            end
        end
    end

    -- draw turn indicator at the bottom of the grid
    draw_turn_indicator(grid_offset_y + grid_size * cell_size + 8)
    
    -- highlight the cursor position
    local cursor_x_pos = grid_offset_x + (cursor_x - 1) * cell_size
    local cursor_y_pos = grid_offset_y + (cursor_y - 1) * cell_size
    rect(cursor_x_pos, cursor_y_pos, cursor_x_pos + cell_size - 1, cursor_y_pos + cell_size - 1, 12) -- highlight color
end

-- draw a single card with numbers for top, bottom, left, and right
function draw_card(card, x, y, size)
    -- draw the card background based on owner (player or opponent)
    if card.owner == 0 then
        rectfill(x, y, x + size - 1, y + size - 1, 8)  -- player card (blue)
    else
        rectfill(x, y, x + size - 1, y + size - 1, 9)  -- opponent card (red)
    end

    -- draw the numbers on the card
    print(card.top, x + flr(size / 2) - 2, y + 2, 7)
    print(card.right, x + size - 6, y + flr(size / 2) - 2, 7)
    print(card.bottom, x + flr(size / 2) - 2, y + size - 10, 7)
    print(card.left, x + 2, y + flr(size / 2) - 2, 7)
end

-- draw player's and opponent's hands
function draw_hands()
    -- player hand on the left
    for i = 1, 5 do  -- limit to 5 cards
        local card = player_cards[i]
        if card ~= nil then
            local x_pos = 2  -- adjusted left side
            local y_pos = (i - 1) * (hand_card_size + 2) + 10 -- vertically balanced
            if i == hand_cursor and not card_selected then
                rect(x_pos - 2, y_pos - 2, x_pos + hand_card_size + 1, y_pos + hand_card_size + 1, 12)  -- highlight selected card
            end
            draw_card(card, x_pos, y_pos, hand_card_size)
        end
    end

    -- opponent hand on the right (limit to 5 cards)
    for i = 1, 5 do
        local card = opponent_cards[i]
        if card ~= nil then
            local x_pos = 128 - hand_card_size - 0  -- pushed further right to avoid overlap
            local y_pos = (i - 1) * (hand_card_size + 2) + 10  -- vertically balanced
            draw_card(card, x_pos, y_pos, hand_card_size)
        end
    end
end

-- draw turn indicator at the bottom
function draw_turn_indicator(y_offset)
    if current_player == 0 then
        print("player's turn", 50, y_offset, 7)
    else
        print("ai's turn", 50, y_offset, 7)
    end
end

-- handle input for grid movement and card placement in pico-8
function handle_input()
    if current_player == 0 then  -- only handle input for player

        -- if no card is selected, allow hand selection
        if not card_selected then
            if btnp(2) then  -- up
                hand_cursor = max(1, hand_cursor - 1)
            elseif btnp(3) then  -- down
                hand_cursor = min(5, hand_cursor + 1)  -- limit to 5 cards
            end

            -- confirm card selection with z (❎)
            if btnp(4) then
                selected_card = player_cards[hand_cursor]  -- choose the selected card
                card_selected = true  -- flag that a card is selected
            end
        else
            -- once card is selected, move cursor over the grid to place
            if btnp(0) then cursor_x = max(1, cursor_x - 1) end  -- left
            if btnp(1) then cursor_x = min(grid_size, cursor_x + 1) end  -- right
            if btnp(2) then cursor_y = max(1, cursor_y - 1) end  -- up
            if btnp(3) then cursor_y = min(grid_size, cursor_y + 1) end  -- down

            -- place the card with x (🅾️) or x key
            if btnp(5) then
                place_card(selected_card, cursor_x, cursor_y)
                player_cards[hand_cursor] = nil  -- remove from hand after placing
                selected_card = nil  -- reset after placing
                card_selected = false  -- reset selection phase
            end
        end
    end
end

-- switch turns between player and opponent
function switch_turn()
    current_player = 1 - current_player

    -- if it's the ai's turn, set delay and call the ai function
    if current_player == 1 then
        ai_delay = 30  -- set a delay of 30 frames (~0.5 seconds in pico-8)
    end
end

-- initialize the game
function _init()
    init_grid()
end

-- update the game state each frame
function _update()
    if current_player == 1 then
        ai_turn()  -- ai takes its turn with delay
    else
        handle_input()  -- player controls
    end
end

-- draw the game state each frame
function _draw()
    cls()
    draw_grid()
    draw_hands()  -- draw the hands of both players
end
