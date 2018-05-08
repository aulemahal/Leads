#!/bin/bash
#
#PBS -l walltime=24:00:00
#PBS -N turbulence10e4
#PBS -r n
#PBS -l nodes=1:ppn=40
#PBS -e Run.stderr
#PBS -o Run.stdout

echo "start from HERE"`date`
echo "Host="`hostname`
cat $PBS_NODEFILE | sort | uniq

HOMEDIR=$PBS_O_WORKDIR

cd $HOMEDIR

cat $PBS_NODEFILE > hostname-run

RUNDIR=$(basename $PBS_O_WORKDIR) 

module add gcc/4.9.2
module add dot
module load openmpi/1.8.3_new-gcc-4.9.2


time mpirun --bind-to hwthread -np 40 --mca mpi_yield_when_idle 0  --mca btl tcp,sm,self  mitgcmuv


echo "" ; echo "run ended at: "`date`

cd $HOMEDIR
