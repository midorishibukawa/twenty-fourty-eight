open Batteries
open Twenty_fourty_eight

module Params = struct
    let size = 4
    let seed = None
end

module Game = Game(Params);;
module IntMap = Map.Make(Int);;

let get_char () =
    let termio = Unix.tcgetattr Unix.stdin in
    let () =
        Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
            { termio with Unix.c_icanon = false } in
    let res = input_char stdin in
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
    res;;

let rec main ?(game_state = Game.new_game (), Game.Playing) () =
    let game, state = game_state in
    let state' =
        let open Game in
        match state with
        | GameWon -> "WIN"
        | GameOver -> "GAME OVER! Press \"r\" to restart"
        | Playing -> "PLAYING..." in
    let game_str =
        let enum = 0 -- (Params.size * Params.size - 1) in
        let build_map : int IntMap.t -> Game.cell -> int IntMap.t = fun acc { value ; position } -> IntMap.add position value acc in
        let map = List.fold build_map IntMap.empty game in
        let to_str str i =
            let s = IntMap.find_opt i map |> Option.map string_of_int |? " " in
            let br = if (i + 1) mod Params.size = 0 then "\n" else "" in 
            Printf.sprintf "%s%s\t%s" str s br in
        Enum.fold to_str (String.repeat "\n" 48) enum
        in
    IO.write_string stdout (game_str ^ state');
    IO.flush_all ();
    let open Game in
    match get_char () with
    | 'w' -> main ~game_state:(move Up game) () 
    | 'a' -> main ~game_state:(move Left game) ()
    | 's' -> main ~game_state:(move Down game) ()
    | 'd' -> main ~game_state:(move Right game) ()
    | ';' -> ()
    | 'r' -> 
            let game_state = 
                if state = GameOver 
                then new_game (), Playing 
                else game_state in
            main ~game_state ()
    | _ -> main ~game_state ();;

main ()
