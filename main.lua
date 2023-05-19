function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    
    -- set up for displaying cards
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
    
    -- creates multiple decks to pull cards from
    Deck = {}
    DeckCount = 4
    for i=1,DeckCount do
        for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
            for rank = 1, 13 do
                table.insert(Deck, {suit = suit, rank = rank})
            end
        end
    end
    local deckReset = Deck

    -- adds card to given hand (player or dealer)
    function TakeCard(hand)
        table.insert(hand, table.remove(Deck, love.math.random(#Deck)))
    end

    function Reset()
        Deck = deckReset
        -- deals two cards to player(s) and dealer
        PlayerHand = {}
        TakeCard(PlayerHand)
        TakeCard(PlayerHand)
    
        DealerHand = {}
        TakeCard(DealerHand)
        TakeCard(DealerHand)
    
        RoundOver = false
    end

    Reset()

    -- returns the total of the card values in given hand
    function GetTotal(hand)
        local total = 0
        local highAce = false

        for cardIndex, card in ipairs(hand) do
            -- face cards always = 10
            if card.rank > 10 then
                total = total + 10
            -- Ace handling
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

        -- more Ace handling
        if total > 21 and highAce then
            total = total - 10
            highAce = false
        end

        return total
    end

    -- used for implementing dealer hitting on soft Ace
    function HasAce(hand)
        for cardIndex, card in ipairs(hand) do
            if card.rank == 1 then
                return true
            end
        end 
        return false
    end

    print(#Deck)

    local buttonY = 230
    local buttonHeight = 25
    local textOffsetY = 6

    ButtonHit = {
        x = 10,
        y = buttonY,
        width = 53,
        height = buttonHeight,
        text = 'Hit!',
        textOffsetX = 16,
        textOffsetY = textOffsetY,
    }

    ButtonStand = {
        x = 70,
        y = buttonY,
        width = 53,
        height = buttonHeight,
        text = 'Stand',
        textOffsetX = 8,
        textOffsetY = textOffsetY,
    }

    ButtonPlayAgain = {
        x = 10,
        y = buttonY,
        width = 113,
        height = buttonHeight,
        text = 'Play again',
        textOffsetX = 24,
        textOffsetY = textOffsetY,
    }

    function IsMouseInButton(button)
        -- Removed: local buttonY = 230
        -- Removed: local buttonHeight = 25

        return love.mouse.getX() >= button.x
        and love.mouse.getX() < button.x + button.width
        and love.mouse.getY() >= button.y
        and love.mouse.getY() < button.y + button.height
    end

end

function love.mousereleased()
    -- player can only hit when round is still going
    if not RoundOver then
        if IsMouseInButton(ButtonHit) then
            TakeCard(PlayerHand)
            if GetTotal(PlayerHand) >= 21 then
                RoundOver = true
            end
        elseif IsMouseInButton(ButtonStand) then
            RoundOver = true
        end

        if RoundOver then
            while GetTotal(DealerHand) < 17 or
            (GetTotal(DealerHand) == 17 and HasAce(DealerHand)) do
                TakeCard(DealerHand)
            end
        end

    elseif IsMouseInButton(ButtonPlayAgain) then
        Reset()
    end
end

function love.draw()
    local function displayCard(card, x, y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Images.card, x, y)

        if card.suit == 'heart' or card.suit == 'diamond' then
            love.graphics.setColor(.89, .06, .39)
        else
            love.graphics.setColor(.2, .2, .2)
        end

        local cardWidth = 53
        local cardHeight = 73

        local function drawCorner(image, offsetX, offsetY)
            love.graphics.draw(
                image,
                x + offsetX,
                y + offsetY
            )
            love.graphics.draw(
                image,
                x + cardWidth - offsetX,
                y + cardHeight - offsetY,
                0,
                -1
            )
        end

        drawCorner(Images[card.rank], 3, 4)
        drawCorner(Images['mini_'..card.suit], 3, 14)

        if card.rank > 10 then
            local faceImage

            if card.rank == 11 then
                faceImage = Images.face_jack
            elseif card.rank == 12 then
                faceImage = Images.face_queen
            elseif card.rank == 13 then
                faceImage = Images.face_king
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(faceImage, x + 12, y + 11)
        else
            local function drawPip(offsetX, offsetY, mirrorX, mirrorY)
                local pipImage = Images['pip_'..card.suit]
                local pipWidth = 11

                love.graphics.draw(
                    pipImage,
                    x + offsetX,
                    y + offsetY
                )
                if mirrorX then
                    love.graphics.draw(
                        pipImage,
                        x + cardWidth - offsetX - pipWidth,
                        y + offsetY
                    )
                end
                if mirrorY then
                    love.graphics.draw(
                        pipImage,
                        x + offsetX + pipWidth,
                        y + cardHeight - offsetY,
                        0,
                        -1
                    )
                end
                if mirrorX and mirrorY then
                    love.graphics.draw(
                        pipImage,
                        x + cardWidth - offsetX,
                        y + cardHeight - offsetY,
                        0,
                        -1
                    )
                end
            end

            local xLeft = 11
            local xMid = 21
            local yTop = 7
            local yThird = 19
            local yQtr = 23
            local yMid = 31

            if card.rank == 1 then
                drawPip(xMid, yMid)

            elseif card.rank == 2 then
                drawPip(xMid, yTop, false, true)

            elseif card.rank == 3 then
                drawPip(xMid, yTop, false, true)
                drawPip(xMid, yMid)

            elseif card.rank == 4 then
                drawPip(xLeft, yTop, true, true)

            elseif card.rank == 5 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xMid, yMid)

            elseif card.rank == 6 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xLeft, yMid, true)

            elseif card.rank == 7 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xLeft, yMid, true)
                drawPip(xMid, yThird)

            elseif card.rank == 8 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xLeft, yMid, true)
                drawPip(xMid, yThird, false, true)

            elseif card.rank == 9 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xLeft, yQtr, true, true)
                drawPip(xMid, yMid)

            elseif card.rank == 10 then
                drawPip(xLeft, yTop, true, true)
                drawPip(xLeft, yQtr, true, true)
                drawPip(xMid, 16, false, true)
            end
        end
    end

    local cardSpacing = 60
    local marginX = 10

    for cardIndex, card in ipairs(DealerHand) do
        local dealerMarginY = 30
        if not RoundOver and cardIndex == 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(Images.card_face_down, marginX, dealerMarginY)
        else
            displayCard(card, ((cardIndex - 1) * cardSpacing) + marginX, 30)            
        end
    end

    for cardIndex, card in ipairs(PlayerHand) do
        displayCard(card, ((cardIndex - 1) * cardSpacing) + marginX, 140)
    end

    love.graphics.setColor(0, 0, 0)

    if RoundOver then
        love.graphics.print('Total: '..GetTotal(DealerHand), marginX, 10)
    else
        love.graphics.print('Total: ?', marginX, 10)
    end

    love.graphics.print('Total: '..GetTotal(PlayerHand), marginX, 120)

    if RoundOver then
        local function hasHandWon(thisHand, otherHand)
            return GetTotal(thisHand) <= 21
            and (
                GetTotal(otherHand) > 21
                or GetTotal(thisHand) > GetTotal(otherHand)
            )
        end

        local function drawWinner(message)
            love.graphics.print(message, marginX, 268)
        end

        if hasHandWon(PlayerHand, DealerHand) then
            drawWinner('Player wins')
        elseif hasHandWon(DealerHand, PlayerHand) then
            drawWinner('Dealer wins')
        else
            drawWinner('Draw')
        end
    end

    local function drawButton(button)
        if IsMouseInButton(button) then
            love.graphics.setColor(1, .8, .3)
        else
            love.graphics.setColor(1, .5, .2)
        end

        love.graphics.rectangle('fill', button.x, button.y, button.width, button.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(button.text, button.x + button.textOffsetX, button.y + button.textOffsetY)
    end

    if not RoundOver then
        drawButton(ButtonHit)
        drawButton(ButtonStand)
    else
        drawButton(ButtonPlayAgain)
    end
end