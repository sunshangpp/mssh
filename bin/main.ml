open Core
open Tmux

let read_hosts_from_stdin () =
  In_channel.input_all In_channel.stdin
  |> String.split_on_chars ~on:[ '\n'; ' '; '\t'; ',' ]
  |> List.filter ~f:(fun str -> not (String.is_empty str))
;;

let hosts_param () =
  Command.Let_syntax.(
    let%map_open hosts = anon (sequence ("hosts" %: string)) in
    (match hosts with
    | [] -> read_hosts_from_stdin ()
    | v -> v)
    |> List.dedup_and_sort ~compare:String.compare)
;;

let command =
  Command.basic
    ~summary:
      "SSH into multiple hosts simultaneously in different tmux panes.\n\n\
       This command must be executed in a tmux session."
    Command.Let_syntax.(
      let%map_open hosts = hosts_param ()
      and max_hosts =
        flag
          "-m"
          ~doc:
            "max_hosts max number of hosts that can be ssh'd into at the same time \
             (default=100)"
          (optional_with_default 100 int)
      and panes_per_window =
        flag
          "-p"
          ~doc:
            "panes_per_window max number of panes per tmux window, new windows are \
             created as needed (default=20)"
          (optional_with_default 20 int)
      and user =
        flag
          "-u"
          ~doc:"username name of the user to ssh with, default to current user"
          (optional_with_default (Unix.getlogin ()) string)
      in
      fun () ->
        if not (in_tmux_session ()) then failwith "must be in a tmux session";
        if List.length hosts > max_hosts then failwith "too many hosts!";
        setup_tmux_panes_and_send_ssh_commands hosts ~user ~panes_per_window)
;;

let () = Command.run ~version:"1.0" ~build_info:"RWO" command
