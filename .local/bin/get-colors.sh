#!/bin/sh

# for i in {0..255} ; do
#   printf "\x1b[38;5;${i}mcolour${i}\n"
# done


# 32 rows
for i in {0..31} ; do

  # 8 columns
  for j in {0..7} ; do

    code=$((((8 * $i) + $j) + 1))
    printf "\x1b[38;5;${code}m${code}\t"
  done

  printf "\n"

done

