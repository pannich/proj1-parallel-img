#!/bin/bash
#
#SBATCH --mail-user=nichada@cs.uchicago.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name=proj1_benchmark
#SBATCH --output=./slurm/out/%j.%N.stdout
#SBATCH --error=./slurm/out/%j.%N.stderr
#SBATCH --chdir=/home/nichada/MPCSParallelpgm/project-1-pannich/proj1/benchmark
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=900
#SBATCH --exclusive
#SBATCH --time=200:00


module load golang/1.19
mkdir -p ./slurm/out

# Array of thread numbers to test
sizes=("small" "mixture" "big")
# sizes=("mixture" "small")
threads=(1 2 4 6 8 12)
partypes=("parfiles" "parslices")
# partypes=("parslices")

# Directory where you want to save the output times
output_dir="./times"
mkdir -p "$output_dir/mintimes"

# Compile editor
go build -o ../editor/editor ../editor/editor.go

# Function to run the editor and record the minimum time out of five attempts
run_and_record_min_time() {
    local par=$1
    local size=$2
    local thread_count=$3
    local times_file="$output_dir/mintimes/times_${par}_${size}_${thread_count}.txt"
    > "$times_file"  # Clear or create the file to store times

    echo "Running $par with size $size and $thread_count threads..." >>"./times/log.txt"

    # Repeat the timing five times and save each real time
    for i in {1..5}; do
        # Redirect stdout to null, and stderr to a temp file to capture 'time' output
        { time ../editor/editor "$size" "$par" "$thread_count" 1>>"./times/log.txt" 2>&1; } 2>&1 | grep 'real' | awk '{print $2}' >> "$times_file"
    done

    # Sort times numerically and pick the smallest one
    min_time=$(sort -h "$times_file" | head -n1)

    # Write the minimum time to a summary file
    echo "Par: $par, Size: $size, Threads: $thread_count, Min Time: $min_time" >> "$output_dir/times_summary.txt"
}

# Loop over the thread numbers and record the time for each
echo " Begin Test " > "$output_dir/times_summary.txt"
for par in "${partypes[@]}"; do
  echo " ------------- $par -------------" >>"./times/log.txt"
  for size in "${sizes[@]}"; do
      for t in "${threads[@]}"; do
          run_and_record_min_time "$par" "$size" "$t"
        done
  done
done

rm -rf "$output_dir/mintimes"
