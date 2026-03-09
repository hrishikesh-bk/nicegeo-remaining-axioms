open Term

type decl_type =
  | Theorem of term
  | Axiom
  | PrintAxioms of string
  | Infer of term
  | Check of term * term
  | Reduce of term

type declaration = {
  name : string;
  name_loc : range;
  ty : term;
  kind : decl_type;
}
