#!/bin/bash

session="aio"
if tmux ls | awk '{print $1}' | grep "aio:"
then
  tmux a -t $session
else
  tmux new-session -d -s $session

  window=1
  tmux rename-window -t $session:$windown 'genhub'
  tmux send-keys -t $session:$windown 'genhub' C-m

  window=2
  tmux new-window -t $session:$windown -n 'genhub-infra'
  tmux send-keys -t $session:$windown 'genhub_infra' C-m

  window=3
  tmux new-window -t $session:$windown -n 'elm/sandbox'
  tmux send-keys -t $session:$windown 'cd ~/elm/sandbox/ && v' C-m

  window=4
  tmux new-window -t $session:$windown -n 'uni/not_spotify'
  tmux send-keys -t $session:$windown 'not_spotify' C-m

  tmux attach-session -t $session
fi
