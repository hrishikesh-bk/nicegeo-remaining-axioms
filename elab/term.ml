type range = { start: Lexing.position; end_: Lexing.position }

type term = term' * range
and term' =
  | Name of string (* a name in the code (refers to a const or the nearest bound variable of the same name during parsing) *)
  | Bvar of int (* de Bruijn index *)
  | Fvar of int (* unique index *)
  | Hole of int
  | Fun of string option * term * term  (* argument name, type, body *)
  | Arrow of string option * term * term  (* argument name, type, return type *)
  | App of term * term
  | Sort of int


let counter = ref 0

let gen_hole_id () =
  let id = !counter in
  counter := id + 1;
  id

let gen_fvar_id = gen_hole_id

let rec bind_bvar ((tm', loc): term) (bvar_idx: int) (pat: term) : term =
  match tm' with
  | Fun (x, (ty_arg, l1), (body, l2)) ->
    let ty_arg_rebound = bind_bvar (ty_arg, l1) bvar_idx pat in
    let body_rebound = bind_bvar (body, l2) (bvar_idx + 1) pat in
    (Fun (x, ty_arg_rebound, body_rebound), loc)
  | Arrow (x, (ty_arg, l1), (ty_ret, l2)) ->
    let ty_arg_rebound = bind_bvar (ty_arg, l1) bvar_idx pat in
    let ty_ret_rebound = bind_bvar (ty_ret, l2) (bvar_idx + 1) pat in
    (Arrow (x, ty_arg_rebound, ty_ret_rebound), loc)
  | App ((t1, l1), (t2, l2)) ->
    let t1_rebound = bind_bvar (t1, l1) bvar_idx pat in
    let t2_rebound = bind_bvar (t2, l2) bvar_idx pat in
    (App (t1_rebound, t2_rebound), loc)
  | Name _ | Fvar _ -> if tm' = (fst pat) then (Bvar bvar_idx, loc) else (tm', loc)
  | _ -> (tm', loc)


let rec replace_bvar ((tm', loc): term) (bvar_idx: int) (replacement: term) : term =
  match tm' with
  | Fun (x, (ty, l1), (body, l2)) ->
    let ty_replaced = replace_bvar (ty, l1) bvar_idx replacement in
    let body_replaced = replace_bvar (body, l2) (bvar_idx + 1) replacement in
    (Fun (x, ty_replaced, body_replaced), loc)
  | Arrow (x, (ty, l1), (ret, l2)) ->
    let ty_replaced = replace_bvar (ty, l1) bvar_idx replacement in
    let ret_replaced = replace_bvar (ret, l2) (bvar_idx + 1) replacement in
    (Arrow (x, ty_replaced, ret_replaced), loc)
  | App ((f, l1), (arg, l2)) ->
    let f_replaced = replace_bvar (f, l1) bvar_idx replacement in
    let arg_replaced = replace_bvar (arg, l2) bvar_idx replacement in
    (App (f_replaced, arg_replaced), loc)
  | Bvar idx -> if idx = bvar_idx then (fst replacement, loc) else (tm', loc)
  | _ -> (tm', loc)

let is_sort (t: term) : bool =
  match fst t with
  | Sort _ -> true
  | _ -> false