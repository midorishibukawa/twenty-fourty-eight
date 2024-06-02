open Twenty_fourty_eight
open Batteries

module GameParams : GameParams = struct
    let size = 4
    let seed = None
end;;

module Game = Game(GameParams);;

let top_row = Fun.id;;
let bottom_row i = GameParams.size * (GameParams.size - 1) + i;;
let right_col i = GameParams.size * (i + 1) - 1;;
let left_col = ( * ) GameParams.size;;

let map2cell value position = Game.({ value ; position });;


let test_move dir starting_f expected_f =
    let positions = List.init GameParams.size starting_f in
    let expected = List.init GameParams.size expected_f |> IntSet.of_list in
    let values = List.make GameParams.size 0 in
    let element_qty = List.length positions in
    let game : Game.t = List.map2 map2cell values positions in
    let game' = Game.move dir game in
    let assert_length = List.length game' = element_qty + 1 in
    let check_val : Game.cell -> bool = fun { value ; _ } -> value = 0 || value = 1 in 
    let assert_values = List.for_all check_val game' in
    let assert_positions =
        let get_pos Game.({ position ; _ }) = position in
        let actual = game' |> List.map get_pos |> IntSet.of_list in
        IntSet.subset expected actual in
    assert_length
    && assert_values
    && assert_positions;;


let%test "new_game" = 
    let game = Game.new_game () in
    let assert_cell_list_length = 
        List.length game = 1 in
    let assert_cell_value = 
        Array.exists ((=) (List.hd game).value) [|0;1|] in
    let assert_cell_position = 
        let pos = (List.hd game).position in 
        pos >= 0 && pos < GameParams.size * GameParams.size in
    assert_cell_list_length
    && assert_cell_value
    && assert_cell_position;;

let%test "move up" = test_move Game.Up bottom_row top_row;;
let%test "move up no move" = test_move Game.Up top_row top_row;;
let%test "move down" = test_move Game.Down top_row bottom_row;;
let%test "moe down no move" = test_move Game.Down bottom_row bottom_row;;
let%test "move left" = test_move Game.Left right_col left_col;;
let%test "move left no move" = test_move Game.Left left_col left_col;;
let%test "move right" = test_move Game.Right left_col right_col;;
let%test "move right no move" = test_move Game.Right right_col right_col;;

let%test "merge simple" =
    let values = [0 ; 0] in
    let positions = [0 ; 1] in
    let game : Game.t = List.map2 map2cell values positions in
    let game' : Game.t = Game.move Game.Left game in
    let assert_length = List.length game' = 2 in
    assert_length;;

let%test "merge middle" =
    let values = [0 ; 1 ; 1 ; 0] in
    let positions = [0 ; 1 ; 2 ; 3] in
    let game : Game.t = List.map2 map2cell values positions in
    let game'    : Game.t = Game.move Game.Right game in
    let assert_length = List.length game' = 4 in 
    assert_length;;

