SMODS.Challenge {
    key = "joker_poker",

    rules = {
        custom = {
            {id = 'jopo_joker_poker', value = 69},
        },
        modifiers = {}
    },
    restrictions = {
        banned_cards = {
        },
        banned_tags = {
        },
        banned_other = {
            {id = 'bl_final_leaf', type = 'blind'},
        }
    },
}


--- Remove all current jokers, fill up joker slots with random jokers
--- @param run_start any
local function joker_poker_jokers(run_start)
    if not args.challenge or args.challenge.id ~= "c_jopo_joker_poker" then
        return
    end

    -- Must be blocking so that new jokers only generate after old ones are dissolved (and no longer "block")
    local blocking = not run_start
    local _first_dissolve = false

    local negatives = 0
    G.E_MANAGER:add_event(Event {blocking = blocking, trigger = 'before', delay = 0.75, func = function()
        for k, v in ipairs(G.jokers.cards) do
            if v.edition and v.edition.negative then
                negatives = negatives + 1
            end
            v:start_dissolve(nil, _first_dissolve)
            _first_dissolve = true
        end
        return true end } )

    local all_legendary = pseudorandom("joker_poker_all_legendary") < 0.01

    G.E_MANAGER:add_event(Event {blocking = blocking, trigger = 'before', delay = 0.4, func = function()
        local card_limit = G.jokers.config.card_limit

        for i = 1, card_limit - negatives do
            local legendary = all_legendary or pseudorandom("joker_poker_legendary") < 0.01

            local card = SMODS.create_card {
                key_append = "joker_poker",
                set = "Joker", 
                stickers = {"eternal"},
                force_stickers = true,
                rarity = legendary and "Legendary" or nil
            }
            card:start_materialize()
            card:add_to_deck()
            G.jokers:emplace(card)
        end
        return true end } )
end


--#region Hooks

local game_start = Game.start_run

function Game:start_run(args)
    game_start(self, args)

    if args.savetext then
        return
    end

    joker_poker_jokers(true)
end


local round_end = G.FUNCS.cash_out

G.FUNCS.cash_out = function(e)
    round_end(e)

    joker_poker_jokers(false)
end

--#endregion Hooks