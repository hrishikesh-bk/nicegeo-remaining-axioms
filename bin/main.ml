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
  
  let decls : declaration list =
    try
      Parser.main Lexer.token lexbuf
    with
    | Failure msg ->
        Printf.eprintf "Parsing error: %s\n" msg;
        Printf.eprintf "At offset: %d-%d\n" (Lexing.lexeme_start lexbuf) (Lexing.lexeme_end lexbuf);
        close_in ic;
        exit 1
    | exn ->
        Printf.eprintf "Parsing exception: %s\n" (Printexc.to_string exn);
        Printf.eprintf "At offset: %d-%d\n" (Lexing.lexeme_start lexbuf) (Lexing.lexeme_end lexbuf);
        close_in ic;
        exit 1
  in

  let env = mk_axioms_env () in

  (* Process proof.txt *)
  let all_decls_good = List.fold_left (fun x decl -> try addDeclaration decl env; x with Failure msg -> print_endline ("Error adding declaration: " ^ msg); false) true decls in
  if not all_decls_good then begin
    print_endline "Error(s) encountered while processing proof file. Exiting.";
    exit 1
  end;
  print_endline "Valid proofs!"