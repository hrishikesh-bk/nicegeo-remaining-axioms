(** Handling of nice messages (the "nice" in "nicegeo"). *)

type tone =
  | Calm
  | Cheerful
  | Minimal
  | Funny

(** Contexts in which a message may be shown. *)
type context =
  | After_error

val default_tone : tone

(** Reads the [NICEGEO_TONE] environment variable to select a tone. Defaults to
    [default_tone] if absent or unrecognised. *)
val tone_from_env : unit -> tone

(** Return all available messages for the given tone and context. *)
val messages_for : tone -> context -> string list

(** Pick a random message for the given tone and context, or [None] if no messages exist. *)
val pick_message : tone -> context -> string option

