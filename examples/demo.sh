#!/usr/bin/env bash
# Quick demo — run after setup.sh

echo "=== ask-worker: Bulk Reading ==="
echo "Reading this repo's own tools and summarizing..."
ask-worker \
  --paths tools/ask-worker tools/worker-write tools/extract-chat \
  --question "What does each tool do? List with one-sentence descriptions."

echo ""
echo "=== worker-write: Boilerplate Generation ==="
echo "Generating a test file based on ask-worker's style..."
worker-write \
  --spec "Write a simple pytest test that verifies ask-worker can be imported and has a main function" \
  --context tools/ask-worker \
  --target /tmp/test_ask_worker.py

echo ""
cat /tmp/test_ask_worker.py
