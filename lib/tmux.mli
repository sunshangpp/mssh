val in_tmux_session : unit -> bool
val tmux_new_pane : unit -> unit
val tmux_new_window : unit -> unit
val tmux_sync_panes : unit -> unit
val tmux_send_command : pane_num:int -> string -> unit
val tmux_ssh_in_pane : pane_num:int -> string -> string -> unit

val setup_tmux_panes_and_send_ssh_commands
  :  string list
  -> user:string
  -> panes_per_window:int
  -> unit
