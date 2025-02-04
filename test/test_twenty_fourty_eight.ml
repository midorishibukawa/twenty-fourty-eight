open Twenty_fourty_eight
open Batteries

module IntSet = Set.Make(Int)

let size = 4

module GameParams : GameParams = struct
    let size = size
    let seed = None
end

module Game = Game(GameParams)

let top_row = Fun.id
let bottom_row i = size * (size - 1) + i
let right_col i = size * (i + 1) - 1
let left_col = ( * ) size 

let map2cell value position = Game.({ value ; position })

let test_move dir ?(cell_qty=size) ?(expected_state=Game.Playing) starting_f expected_f =
    let positions = List.init GameParams.size starting_f in
    let expected = List.init GameParams.size expected_f |> IntSet.of_list in
    let values = List.make GameParams.size 0 in
    let game = List.map2 map2cell values positions in
    let game', state, _ = Game.move dir game in
    let assert_length = List.length game' = cell_qty in
    let check_val Game.({ value ; _ }) = value = 0 || value = 1 in 
    let assert_values = List.for_all check_val game' in
    let assert_positions =
        let get_pos Game.({ position ; _ }) = position in
        let actual = game' |> List.map get_pos |> IntSet.of_list in
        IntSet.subset expected actual in
    let assert_state = expected_state = state in
    assert_length
    && assert_values
    && assert_positions
    && assert_state

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

let%test "move up" = test_move Game.Up ~cell_qty:(size + 1) bottom_row top_row
let%test "move up no move" = test_move Game.Up top_row top_row
let%test "move down" = test_move Game.Down ~cell_qty:(size + 1) top_row bottom_row
let%test "move down no move" = test_move Game.Down bottom_row bottom_row
let%test "move left" = test_move Game.Left ~cell_qty:(size + 1) right_col left_col
let%test "move left no move" = test_move Game.Left left_col left_col
let%test "move right" = test_move Game.Right ~cell_qty:(size + 1) left_col right_col
let%test "move right no move" = test_move Game.Right right_col right_col

let%test "merge simple" =
    let values = [0 ; 0] in
    let positions = [0 ; 1] in
    let game = List.map2 map2cell values positions in
    let game', _, _ = Game.move Game.Left game in
    let assert_length = List.length game' = 2 in
    assert_length

let%test "merge middle" =
    let values = [0 ; 1 ; 1 ; 0] in
    let positions = [0 ; 1 ; 2 ; 3] in
    let game = List.map2 map2cell values positions in
    let game', _, _ = Game.move Game.Right game in
    let assert_length = List.length game' = 4 in 
    assert_length

let%test "game win" =
    let values = [9 ; 9] in
    let positions = [0; 1] in
    let game = List.map2 map2cell values positions in
    let game', state, _ = Game.move Game.Left game in
    let assert_length = List.length game' = 2 in
    let assert_state = Game.Won = state in 
    assert_length
    && assert_state

let%test "game over" =
    let values = 0 --^ size * size |> List.of_enum in
    let positions = values in
    let game = List.map2 map2cell values positions in
    let game', state, _ = Game.move Game.Down game in
    let assert_length = List.length game' = size * size in
    let assert_state = Game.Over = state in
    assert_length
    && assert_state

let%test "playing board full" =
    let values = 0 --^ size * size |> Enum.map (fun i -> i / size) |> List.of_enum in
    let positions = 0 --^ size * size |> List.of_enum in
    let game = List.map2 map2cell values positions in
    let game', state, _ = Game.move Game.Up game in
    let assert_length = List.length game' = size * size in
    let assert_state = Game.Playing = state in
    assert_length
    && assert_state

let%test "won board full" =
    let values = 0 --^ size * size |> Enum.map (fun i -> (i / size) * 4) |> List.of_enum in
    let positions = 0 --^ size * size |> List.of_enum in
    let game = List.map2 map2cell values positions in
    let game', state, _ = Game.move Game.Up game in
    let assert_length = List.length game' = size * size in
    let assert_state = Game.Won = state in
    assert_length
    && assert_state

