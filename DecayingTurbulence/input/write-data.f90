
program write

  implicit none

  integer n, init
  real dt
  character(23) file_name , FMT, scrap,scrap1,command

  print*, system('rm pickup.ckptA.*')
  print*, system('rm pickup.ckptB.*')
  print*, system('rm PH.*')
  print*, system('rm PHL.*')
  print*, system('ls pickup.* | tail -1 > filename')

  OPEN(UNIT=0,FILE='filename')
  read(0,*) file_name
  CLOSE(UNIT=0)
  file_name =  file_name(8:17) 

  print*, system('mkdir tmp')
  command = 'mv *' //  file_name(1:10) // '* tmp/'
  print*, system(command)
  print*, system('rm pickup*')
  print*, system('mv tmp/* .')

  OPEN(UNIT=0,FILE='filename')
  write(0,*) file_name
  CLOSE(UNIT=0)

  OPEN(UNIT=0,FILE='filename')
  read(0,*) init
  CLOSE(UNIT=0)

  OPEN(UNIT=0,FILE='data')
  do n=1,49,1
     read(0,*) 
  end do
  read(0,*) scrap, scrap, dt
  CLOSE(UNIT=0)

  OPEN(UNIT=0,FILE='data',POSITION='APPEND')
  Rewind(0)
  do n=1,47,1
     read(0,*) 
  end do
  write(0,*)  'nIter0 = ', init          ,','
  write(0,*)  'nTimeSteps   = 3000 ,'
  write(0,*)  'deltaT      =',  dt   ,','
  write(0,*)  'abEps=0.1,'
  write(0,*)  'pChkptFreq =',  1000.*dt   ,','  
  write(0,*)  'chkptFreq  =',  1000.*dt   ,','
  write(0,*)  'dumpFreq   =',  1000.*dt   ,','
  write(0,*)  'monitorFreq=8640000.,'
  write(0,*)  'monitorSelect=1,'
  write(0,*)  '&'
  write(0,*)  " "
  write(0,*)  ' '
  write(0,*)  '&PARM04'
  write(0,*)  'usingCartesianGrid=.TRUE.,'
  write(0,*)  'dXspacing=1.,'
  write(0,*)  'dYspacing=1.,'
  write(0,*)  'delZ=300*1.,'
  write(0,*)  '&'
  write(0,*)  " "
  write(0,*)  " "
  write(0,*)  '&PARM05'
  write(0,*)  "surfQfile='Qo',"
  write(0,*)  "hydrogThetaFile='Tini',"
  write(0,*)  '&'



  CLOSE(UNIT=0)


  !write(*,FMT) 1234567.123456

end program write
