open Core

let in_tmux_session () =
  match Sys.getenv "TERM_PROGRAM" with
  | None -> false
  | Some v -> String.equal v "tmux"
;;

let tmux_new_pane () = Sys.command_exn "tmux split-window; tmux select-layout tiled"
let tmux_new_window () = Sys.command_exn "tmux new-window"
let tmux_sync_panes () = Sys.command_exn "tmux set synchronize-panes"

let tmux_send_command ~pane_num command =
  Sys.command_exn (Printf.sprintf "tmux send-keys -t %d \"%s\n\"" pane_num command)
;;

let tmux_ssh_in_pane ~pane_num user host =
  tmux_send_command ~pane_num (Printf.sprintf "ssh %s@%s" user host)
;;

let setup_tmux_panes_and_send_ssh_commands hosts ~user ~panes_per_window =
  let rec loop ~pane_num = function
    | [] -> ()
    | [ host ] ->
      tmux_ssh_in_pane ~pane_num user host;
      tmux_sync_panes ()
    | host :: hosts_left ->
      tmux_ssh_in_pane ~pane_num user host;
      if pane_num + 1 >= panes_per_window
      then (
        tmux_sync_panes ();
        tmux_new_window ())
      else tmux_new_pane ();
      loop ~pane_num:((pane_num + 1) % panes_per_window) hosts_left
  in
  if not (List.is_empty hosts)
  then (
    tmux_new_window ();
    loop ~pane_num:0 hosts)
;;