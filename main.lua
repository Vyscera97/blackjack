function love.load()
    deck = {}
    for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
        for rank = 1, 13 do
            table.insert(deck, {suit = suit, rank = rank})
        end
    end

    function takeCard(hand)
        table.insert(hand, table.remove(deck, love.math.random(#deck)))
    end

    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)

    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)

    roundOver = false
end

function love.keypressed(key)
    if not roundOver then
        if key == 'h' then
            takeCard(playerHand)
            if getTotal(playerHand) >= 21 then
                roundOver = true
            end
        elseif key == 's' then
            roundOver = true
        end
    else
        love.load()
    end
end

function love.draw()
    function getTotal(hand)
        local total = 0
        hasAce = false

        for cardIndex, card in ipairs(hand) do
            if card.rank > 10 then
                total = total + 10
            else
                total = total + card.rank
            end

            if card.rank == 1 then 
                hasAce = true
            end
        end

        if hasAce and total < 12 then
            total = total + 10
        end

        return total
    end

    local output = {}

    table.insert(output, 'Player Hand:')
    for cardIndex, card in ipairs(playerHand) do
        table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total: '..getTotal(playerHand))

    table.insert(output, '')

    table.insert(output, 'Dealer Hand:')
    for cardIndex, card in ipairs(dealerHand) do
        if not roundOver and cardIndex == 1 then
            table.insert(output, '(Card hidden)')
        else
            table.insert(output, 'suit: '..card.suit..', rank: '..card.rank)
        end        
    end
    table.insert(output, 'Total: '..getTotal(dealerHand))       

    if roundOver then
        while getTotal(dealerHand) <= 17 do
            if getTotal(dealerHand) == 17 and not hasAce then
                break
            else
                takeCard(dealerHand)
            end
        end

        table.insert(output, '')

        local function hasThisHandWon(thisHand, otherHand)
            return getTotal(thisHand) <= 21 and
            (getTotal(otherHand) > 21 or getTotal(otherHand) < getTotal(thisHand))
        end

        if hasThisHandWon(playerHand, dealerHand) then
            table.insert(output, 'Player Wins!')
        elseif hasThisHandWon(dealerHand, playerHand) then
            table.insert(output, 'Dealer Wins!')
        else 
            table.insert(output, "Draw!")
        end
    end

        love.graphics.print(table.concat(output, '\n'), 15, 15)
end