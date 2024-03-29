#!/bin/bash

session="aio"
if tmux ls | awk '{print $1}' | grep "aio:"
then
  tmux a -t $session
else
  tmux new-session -d -s $session

  window=0
  tmux rename-window -t $session:$window 'nvim_config'
  tmux send-keys -t $session:$window 'nvim_config' C-m

  window=1
  tmux new-window -t $session:$window -n 'ae_mdw' \; \
  send-keys -t $session:$window 'ae_mdw' C-m \; \

  window=6
  tmux new-window -t $session:$window -n 'averato' \; \
  send-keys -t $session:$window 'averato' C-m \; \

  window=8
  tmux new-window -t $session:$window -n 'averato_frontend' \; \
  send-keys -t $session:$window 'averato_frontend' C-m \; \
  split-window -h \; \
  send-keys 'averato_frontend_dir && yarn dev' #C-m

  window=7
  tmux new-window -t $session:$window -n 'averato_infra' \; \
  send-keys -t $session:$window 'averato_infra' C-m \; \

  # window=3
  # tmux new-window -t $session:$window -n 'elm_shenanigans' \; \
  # send-keys -t $session:$window 'elm_shenanigans' C-m \; \
  # split-window -h \; \
  # send-keys 'elm_shenanigans_dir && elm reactor' #C-m

  # window=4
  # tmux new-window -t $session:$window -n 'uni/not_spotify' \; \
  # send-keys -t $session:$window 'not_spotify' C-m \; \
  # split-window -h \; \
  # send-keys 'not_spotify_dir && iex --sname not_spotify -S mix phx.server' #C-m

  window=7
  tmux new-window -t $session:$window -n 'genhub-infra' \; \
  send-keys -t $session:$window 'genhub_infra' C-m \; \
  split-window -h \; \
  send-keys 'genhub_terraform && kubectl --kubeconfig gh_kubeconfig.yaml get events -n main' C-m

  window=8
  tmux new-window -t $session:$window -n 'genhub' \; \
  send-keys -t $session:$window 'genhub' C-m \; \
  split-window -h \; \
  send-keys 'genhub_dir && iex --sname genhub -S mix phx.server' #C-m

  window=9
  tmux new-window -t $session:$window -n 'dotconfig'
  tmux send-keys -t $session:$window 'cd ~/.config && v' C-m

  tmux attach-session -t $session
fi
