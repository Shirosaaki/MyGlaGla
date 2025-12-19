#!/usr/bin/env bash

# Usage: ./run_examples.sh MAX
# Loops examples from 1..MAX and for each one runs:
#   ./glados -c out.o < examples/example[x].tslang && gcc out.o && echo "===== example[x] =====" >> out.txt && ./a.out >> out.txt && echo "============" >> out.txt
# By default this script *appends* to out.txt. Remove or truncate out.txt beforehand if you want a fresh file.

set -u -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 MAX" >&2
  exit 2
fi

max=$1
if ! [[ $max =~ ^[0-9]+$ && $max -ge 1 ]]; then
  echo "MAX must be a positive integer" >&2
  exit 2
fi

outfile="out.txt"

for i in $(seq 1 "$max"); do
  ex="examples/example${i}.tslang"
  if [[ ! -f $ex ]]; then
    echo "Skipping missing $ex" >&2
    continue
  fi

  echo "Processing example $i..."

  # Generate bytecode (glados)
  if ./glados -c out.o < "$ex"; then
    # Compile
    if gcc out.o -o a.out; then
      # Append header and program output to out.txt
      echo "===== example[$i] =====" >> "$outfile"
      if ./a.out >> "$outfile" 2>&1; then
        echo "============" >> "$outfile"
      else
        echo "Runtime error for example[$i] (see appended output)" >> "$outfile"
        echo "============" >> "$outfile"
      fi
    else
      echo "Compilation failed for example[$i]" >> "$outfile"
    fi
  else
    echo "Bytecode generation failed for example[$i]" >> "$outfile"
  fi

done

echo "Done. Results appended to $outfile"