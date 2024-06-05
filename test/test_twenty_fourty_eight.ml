open Twenty_fourty_eight
open Batteries

let size = 4

module GameParams : GameParams = struct
    let size = size
    let seed = None
end

module Game = Game(GameParams)

let%test "new_game" = 
    let game = Game.new_game () in
    let assert_cell_list_length = 
        List.length game = 1 in
    let assert_cell_value = 
        Array.exists ((=) (List.hd game).value) [|0;1|] in
    let assert_cell_position = 
        let pos = (List.hd game).position in 
        pos >= 0 && pos < size * size in
    assert_cell_list_length
    && assert_cell_value
    && assert_cell_position
