open Term
(* TODO make .mli file, move this to a different folder from kernel *)

(* --- Exception types --- *)

type type_error_info = { env : environment; ctx : localcontext; trm : term; }

(* TODO revisit arguments later if all needed *)
exception TypeError of type_error_info

(* TODO any display of the error messages will happen in the elaborator, but maybe start here before that to separate the refactor into steps *)
