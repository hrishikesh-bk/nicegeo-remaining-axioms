open Term
(* TODO make .mli file, document this file, etc *)

(* --- Exception types --- *)

type type_error_kind =
  ForallSortError

type type_error_info =
  {
    env : environment;
    ctx : localcontext;
    trm : term;
    err_kind : type_error_kind
  }

(* TODO revisit arguments later if all needed *)
exception TypeError of type_error_info

(* --- Printing errors ---*)

(* TODO any display of the error messages will happen in the elaborator, but will start here to divide work into steps *)

let err_to_string (info : type_error_info) : string =
  let _ = info in
  "foo"
