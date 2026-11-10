#!/usr/bin/env bash
# run.sh <arm> <task> <model> <seed> [timeout_s]
# One candidate run: fresh oyvoice copy + pack mounted at .pack/ + opencode run.
set -u
EVAL=/tmp/opencode/lam-eval
WORK=/tmp/oc-work
ARM=$1; TASK=$2; MODEL=$3; SEED=$4; TIMEOUT=${5:-900}
RUN_ID="${ARM}-${TASK}-s${SEED}-$(date +%H%M%S)"
DST="$WORK/$RUN_ID"
META="$EVAL/runs/$RUN_ID.meta.json"

git clone -q --shared "$EVAL/oyvoice-base" "$DST" || exit 1
cd "$DST" || exit 1
git checkout -q f79dff4d
if [ -f "$EVAL/tasks/$TASK/seed.patch" ]; then
  git apply "$EVAL/tasks/$TASK/seed.patch"
  git -c user.email=duel@local -c user.name=duel commit -qam "task fixture"
fi
FIXTURE=$(git rev-parse HEAD)

cp -r "$EVAL/packs/$ARM" "$DST/.pack"
cp "$EVAL/packs/$ARM.opencode.json" "$DST/opencode.json"

START=$(date +%s)
XDG_CONFIG_HOME=/tmp/oc-work/.xdg timeout "$TIMEOUT" \
  opencode run -m "$MODEL" --auto --format json \
  "$(cat "$EVAL/tasks/$TASK/prompt.md")" \
  > "$EVAL/runs/$RUN_ID.transcript.jsonl" \
  2> "$EVAL/runs/$RUN_ID.stderr.log"
RC=$?
END=$(date +%s)
TIMED_OUT=false; [ $RC -eq 124 ] && TIMED_OUT=true

cat > "$META" <<EOF
{"run_id":"$RUN_ID","arm":"$ARM","task":"$TASK","model":"$MODEL","seed":$SEED,
"workdir":"$DST","fixture":"$FIXTURE","start":$START,"end":$END,
"duration_s":$((END-START)),"timed_out":$TIMED_OUT,"run_rc":$RC}
EOF
python3 "$EVAL/harness/grade.py" "$DST" "$EVAL/tasks/$TASK" "$META" "$EVAL/runs/$RUN_ID.grade.json" || true
echo "[run.sh] $RUN_ID rc=$RC timeout=$TIMED_OUT dur=$((END-START))s"
