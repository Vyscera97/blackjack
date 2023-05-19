function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    
    Images = {}
    for nameIndex, name in ipairs({
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        'pip_heart', 'pip_diamond', 'pip_club', 'pip_spade',
        'mini_heart', 'mini_diamond', 'mini_club', 'mini_spade',
        'card', 'card_face_down',
        'face_jack', 'face_queen', 'face_king',
    }) do
        Images[name] = love.graphics.newImage('images/'..name..'.png.')
    end
    
    Deck = {}
    DeckCount = 4
    for i=1,DeckCount do
        for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
            for rank = 1, 13 do
                table.insert(Deck, {suit = suit, rank = rank})
            end
        end
    end

    function TakeCard(hand)
        table.insert(hand, table.remove(Deck, love.math.random(#Deck)))
    end

    function HasAce(hand)
        for cardIndex, card in ipairs(hand) do
            if card.rank == 1 then
                return true
            end
        end 
        return false
    end

    print(#Deck)

    PlayerHand = {}
    TakeCard(PlayerHand)
    TakeCard(PlayerHand)

    DealerHand = {}
    TakeCard(DealerHand)
    TakeCard(DealerHand)

    RoundOver = false
end

function love.keypressed(key)
    if not RoundOver then
        if key == 'h' then
            TakeCard(PlayerHand)
            if GetTotal(PlayerHand) >= 21 then
                RoundOver = true
            end
        elseif key == 's' then
            RoundOver = true
        end
    else
        love.load()
    end
end

function love.draw()
    function GetTotal(hand)
        local total = 0
        local highAce = false

        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            elseif card.rank == 1 then
                if total < 11 then
                    total = total + 11
                    highAce = true
                else
                    total = total + 1
                end
            else
                total = total + card.rank
            end
        end

        if total > 21 and highAce then
            total = total - 10
            highAce = false
        end

        return total
    end

    local output = {}

    table.insert(output, 'Player Hand:')
    for cardIndex, card in ipairs(PlayerHand) do
        table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total: '..GetTotal(PlayerHand))

    table.insert(output, '')

    table.insert(output, 'Dealer Hand:')
    for cardIndex, card in ipairs(DealerHand) do
        if not RoundOver and cardIndex == 1 then
            table.insert(output, '(Card hidden)')
        else
            table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
        end        
    end       

    if RoundOver then
        table.insert(output, 'Total: '..GetTotal(DealerHand))
        while GetTotal(DealerHand) <= 17 and GetTotal(PlayerHand) < 21 do
            if GetTotal(DealerHand) == 17 and not HasAce(DealerHand) then
                break
            else
                TakeCard(DealerHand)
            end
        end

        table.insert(output, '')

        local function hasThisHandWon(thisHand, otherHand)
            return GetTotal(thisHand) <= 21 and
            (GetTotal(otherHand) > 21 or GetTotal(otherHand) < GetTotal(thisHand))
        end

        if hasThisHandWon(PlayerHand, DealerHand) then
            table.insert(output, 'Player Wins!')
        elseif hasThisHandWon(DealerHand, PlayerHand) then
            table.insert(output, 'Dealer Wins!')
        else 
            table.insert(output, "Draw!")
        end
    else
        table.insert(output, 'Total: ')
    end

    local function displayCard(card, x, y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Images.card, x, y)

        love.graphics.setColor(0, 0, 0)
        local cardWidth = 53
        local cardHeight = 73
        local numberOffsetX = 3
        local numberOffsetY = 4

        love.graphics.draw(
            Images[card.rank],
            x + numberOffsetX,
            y + numberOffsetY
        )
        love.graphics.draw(
            Images[card.rank],
            x + cardWidth - numberOffsetX,
            y + cardHeight - numberOffsetY,
            0,
            -1
        )
    end

    local testHand1 = {
        {suit = 'club', rank = 1},
        {suit = 'diamond', rank = 2},
        {suit = 'heart', rank = 3},
        {suit = 'spade', rank = 4},
        {suit = 'club', rank = 5},
        {suit = 'diamond', rank = 6},
        {suit = 'heart', rank = 7}
    }

    for cardIndex, card in ipairs(testHand1) do
        displayCard(card, (cardIndex - 1) * 60, 0)
    end

    local testHand2 = {
        {suit = 'spade', rank = 8},
        {suit = 'club', rank = 9},
        {suit = 'diamond', rank = 10},
        {suit = 'heart', rank = 11},
        {suit = 'spade', rank = 12},
        {suit = 'club', rank = 13},
    }

    for cardIndex, card in ipairs(testHand2) do
        displayCard(card, (cardIndex - 1) * 60, 80)
    end

end