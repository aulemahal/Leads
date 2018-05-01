#!/bin/bash
#
#PBS -q four-twelve
#PBS -N ML_500m
#PBS -l nodes=5:ppn=12
#PBS -e ML_500m.stderr
#PBS -o ML_500m.stdout

#- batch parameters are specified above (lines starting with #PBS); note that after 1rst
#        blank line (above), anything folowing "#" character is treated as comments
#
# example of a PBS batch script to run MITgcm on new (x86_64) acesgrid cluster
#         using executable compiled with gfortran (and OpenMPI if using MPI)
#         and running on /data/ disk(/net/eaps-80-11/data/)

# $Header: /u/gcmpack/MITgcm_contrib/jmc_script/run_gnu.pbs,v 1.2 2012/10/26 19:29:08 jmc Exp $
# $Name:  $

sfx=1    # directory suffix
mpi=60   # number of MPI procs (=0 for non MPI run)
mth=1    # number of OMP threads (=0 for non Multi-thread run)

if test -f /etc/profile.d/modules.sh ; then
    . /etc/profile.d/modules.sh
fi

HERE=`pwd`
echo "start from HERE='$HERE' at: "`date`
echo " sfx=$sfx , mpi=$mpi , mth=$mth , host="`hostname`

#- dir where to run mitgcmuv (batch job starts in home dir; need to "cd" to run dir):
homeD="/mit/lpnadeau/mitgcm/runs/ML_500m"
runD="/data/lpnadeau/run-mitgcm/ML_500m"
echo -n " run in runD='$runD' on nodes: "
cat $PBS_NODEFILE | sort | uniq

# cp $homeD/input/* $runD
# cp $homeD/build/mitgcmuv $runD

cd $runD
echo " sfx=$sfx , mpi=$mpi , mth=$mth" > mf_run
cat $PBS_NODEFILE >> mf_run

umask 0022
#- to get case insensitive "ls" (and order of tested experiments)
export LC_ALL="en_US.UTF-8"

if [ $mth -ge 1 ] ; then
 export OMP_NUM_THREADS=$mth
 export GOMP_STACKSIZE=400m
fi

 module add gcc
if test $mpi = 0 ; then
 EXE="./mitgcmuv > std_outp"
else
 module add openmpi
 EXE="mpirun -v"
 if [ $mth -ge 1 ] ; then EXE="$EXE -x OMP_NUM_THREADS -x GOMP_STACKSIZE" ; fi
 #- select which MPI procs to use
 nn=`cat $PBS_NODEFILE | sort | uniq | wc -l`
 if [ $nn -gt 1 ] ; then dd=`expr $mpi % $nn` ; else dd=1 ; fi
 if [ $dd -eq 0 ] ; then
   npn=`expr $mpi / $nn`
   echo " Nb of nodes=$nn , nb of process per node=$npn"
   cat $PBS_NODEFILE | sort | uniq > mf
   EXE="$EXE -hostfile mf -npernode $npn ./mitgcmuv"
 else
   EXE="$EXE -np $mpi ./mitgcmuv"
 fi
fi

echo "list of loaded modules:"
module list 2>&1
echo " "
echo "run command: $EXE"
eval $EXE

echo "" ; echo " run ended at: "`date`

gfortran write-data.f90
./a.out
ssh login "cd /mit/lpnadeau/mitgcm/runs/ML_500m; qsub pbs-script.sh"