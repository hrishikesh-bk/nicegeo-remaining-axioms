open System_e_kernel
open Decl
open Env
open Printexc

let () =
  record_backtrace true;

  if Array.length Sys.argv < 2 then begin
    Printf.eprintf "Usage: %s <filename>\n" Sys.argv.(0);
    exit 1
  end;
  
  let filename = Sys.argv.(1) in
  let ic = open_in filename in
  let lexbuf = Lexing.from_channel ic in
  
  let decls : declaration list = Parser.main Lexer.token lexbuf in
  close_in ic;

  let env = mk_axioms_env () in

  List.fold_left (fun _ decl -> addDeclaration decl env) () decls;
  print_endline "Valid proofs!"
