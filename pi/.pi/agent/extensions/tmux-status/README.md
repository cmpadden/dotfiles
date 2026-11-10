# tmux-status

Inject pi status into tmux statuslines.

```text
     0 editor [pi:working]   1 backend   2 review [pi:waiting]
```

## States

- `idle`: Pi is open but has not completed a run in this session, or was aborted.
- `working`: a run (including tools, retries, queued continuations, or compaction) is in progress.
- `waiting`: a blocking extension UI prompt needs input.
- `done`: the full run settled.

Each window combines its panes with priority **waiting > working > done > idle**.

## Usage

```
set -g @pi_status_time '%s'
set -g @pi_status_live '#{?#{e|>:#{@pi_status_until},#{T:@pi_status_time}},#{@pi_status},}'
set -g @pi_status_badge '#{?#{m:*waiting*,#{P:#{E:@pi_status_live}}}, [pi:waiting],#{?#{m:*working*,#{P:#{E:@pi_status_live}}}, [pi:working],#{?#{m:*done*,#{P:#{E:@pi_status_live}}}, [pi:done],#{?#{m:*idle*,#{P:#{E:@pi_status_live}}}, [pi:idle],}}}}'

set -g window-status-format " #I #W#{E:@pi_status_badge} "
set -g window-status-current-format " #{?window_zoomed_flag,*,} #I #W#{E:@pi_status_badge} "
```
