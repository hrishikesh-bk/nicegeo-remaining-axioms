(* Tests for inferType with stack-based local context *)
open System_e_kernel
open Term
open Infer

let str_contains s sub =
  let n = String.length sub in
  n = 0
  || let rec loop i =
       i + n <= String.length s
       && (String.sub s i n = sub || loop (i + 1))
     in
     loop 0

let mk_env () =
  let env = Hashtbl.create 16 in
  Hashtbl.add env "Point" (Sort 0);
  Hashtbl.add env "Line" (Sort 0);
  Hashtbl.add env "p" (Const "Point");
  env

let test_const_lookup () =
  let env = mk_env () in
  let ty = inferType env [] (Const "Point") in
  assert (ty = Sort 0);
  let ty_line = inferType env [] (Const "Line") in
  assert (ty_line = Sort 0)

let test_fvar_lookup () =
  let env = mk_env () in
  let ty = inferType env [] (Fvar "p") in
  assert (ty = Const "Point")

let test_fvar_unknown_fails () =
  let env = mk_env () in
  try
    ignore (inferType env [] (Fvar "nonexistent"));
    assert false
  with Failure msg -> assert (str_contains msg "unknown free variable")

let test_bvar_stack () =
  let env = mk_env () in
  (* Bvar 0 with [Point] -> Point *)
  let t0 = inferType env [ Const "Point" ] (Bvar 0) in
  assert (t0 = Const "Point");
  (* Bvar 0 = head, Bvar 1 = second; [Line; Point] -> Bvar 0: Line, Bvar 1: Point *)
  let t0' = inferType env [ Const "Line"; Const "Point" ] (Bvar 0) in
  let t1' = inferType env [ Const "Line"; Const "Point" ] (Bvar 1) in
  assert (t0' = Const "Line");
  assert (t1' = Const "Point")

let test_bvar_out_of_scope_fails () =
  let env = mk_env () in
  try
    ignore (inferType env [] (Bvar 0));
    assert false
  with Failure msg -> assert (str_contains msg "out of scope");
  try
    ignore (inferType env [ Const "Point" ] (Bvar 1));
    assert false
  with Failure msg -> assert (str_contains msg "out of scope")

let test_const_unknown_fails () =
  let env = mk_env () in
  try
    ignore (inferType env [] (Const "Unknown"));
    assert false
  with Failure msg -> assert (str_contains msg "unknown constant")

let () =
  test_const_lookup ();
  test_fvar_lookup ();
  test_fvar_unknown_fails ();
  test_bvar_stack ();
  test_bvar_out_of_scope_fails ();
  test_const_unknown_fails ();
  print_endline "All inferType tests passed."
