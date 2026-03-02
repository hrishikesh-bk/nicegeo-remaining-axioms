type term =
  | Name of string (* a name in the code (refers to a const or the nearest bound variable of the same name during parsing) *)
  | Bvar of int (* de Bruijn index *)
  (* Free variable (where int is a unique index for that specific free variable) introduced during internal processing of
   term *)
  | Fvar of int 
  (* Part of a term that we need to fill in for the user (where the user can use an underscore to specify that they want
  something to be inferred). The int is a unique index for that specific hole  
  *)
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

(** Find all occurrences of `pat` in `tm` and replace them with a reference to
bound variable `bvar_idx`*)
let rec bind_bvar (tm: term) (bvar_idx: int) (pat: term) : term =
  match tm with
  | Fun (x, ty_arg, body) ->
    let ty_arg_rebound = bind_bvar ty_arg bvar_idx pat in
    let body_rebound = bind_bvar body (bvar_idx + 1) pat in
    Fun (x, ty_arg_rebound, body_rebound)
  | Arrow (x, ty_arg, ty_ret) ->
    let ty_arg_rebound = bind_bvar ty_arg bvar_idx pat in
    let ty_ret_rebound = bind_bvar ty_ret (bvar_idx + 1) pat in
    Arrow (x, ty_arg_rebound, ty_ret_rebound)
  | App (t1, t2) ->
    let t1_rebound = bind_bvar t1 bvar_idx pat in
    let t2_rebound = bind_bvar t2 bvar_idx pat in
    App (t1_rebound, t2_rebound)
  | Name _ | Fvar _ -> if tm = pat then Bvar bvar_idx else tm
  | tm -> tm


(** Replace the bound variable corresponding to index `bvar_idx` (from the point of view
of the top level term) with the expression `replacement` *)
let rec replace_bvar (tm: term) (bvar_idx: int) (replacement: term) : term =
  match tm with
  | Fun (x, ty, body) ->
    let ty_replaced = replace_bvar ty bvar_idx replacement in
    let body_replaced = replace_bvar body (bvar_idx + 1) replacement in
    Fun (x, ty_replaced, body_replaced)
  | Arrow (x, ty, ret) ->
    let ty_replaced = replace_bvar ty bvar_idx replacement in
    let ret_replaced = replace_bvar ret (bvar_idx + 1) replacement in
    Arrow (x, ty_replaced, ret_replaced)
  | App (f, arg) ->
    let f_replaced = replace_bvar f bvar_idx replacement in
    let arg_replaced = replace_bvar arg bvar_idx replacement in
    App (f_replaced, arg_replaced)
  | Bvar idx -> if idx = bvar_idx then replacement else tm
  | tm -> tm

let is_sort (t: term) : bool =
  match t with
  | Sort _ -> true
  | _ -> false