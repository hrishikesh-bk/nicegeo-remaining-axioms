open Term
module KTerm = Kernel.Term

(* Converts an elaboration-level term to a kernel-level term. tm must not have any holes *)
let rec conv_to_kterm (tm : term) : KTerm.term =
  match tm.inner with
  | Name x -> KTerm.Const x
  | Hole _ -> failwith "hole in conv_to_kterm input"
  | Fun (_, ty, body) -> KTerm.Lam (conv_to_kterm ty, conv_to_kterm body)
  | Arrow (_, ty, ret) -> KTerm.Forall (conv_to_kterm ty, conv_to_kterm ret)
  | App (f, arg) -> KTerm.App (conv_to_kterm f, conv_to_kterm arg)
  | Sort n -> KTerm.Sort n
  | Bvar n -> KTerm.Bvar n
  | Fvar _ -> failwith "fvar in conv_to_kterm input"

  (* Converts a kernel-level term to an elaborator-level term. kt term must not have any holes*)
let rec kterm_to_term (kt : KTerm.term) : Term.term = 
  match kt with
  | KTerm.Const name -> { inner = Term.Name name; loc = Term.dummy_range }
  | KTerm.Lam (ty_arg, body) -> { inner = Term.Fun (None, kterm_to_term ty_arg, kterm_to_term body); loc = Term.dummy_range }
  | KTerm.Forall (ty_arg, ty_ret) -> { inner = Term.Arrow (None, kterm_to_term ty_arg, kterm_to_term ty_ret); loc = Term.dummy_range }
  | KTerm.App (f, arg) -> { inner = Term.App (kterm_to_term f, kterm_to_term arg); loc = Term.dummy_range }
  | KTerm.Sort i -> { inner = Term.Sort i; loc = Term.dummy_range }
  | KTerm.Fvar i -> { inner = Term.Name i; loc = Term.dummy_range }
  | KTerm.Bvar i -> { inner = Term.Bvar i; loc = Term.dummy_range }