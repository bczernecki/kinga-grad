#/bin/bash

# obliczenia do gradu:

cd /media/tornado/Seagate_041/ERA5_EU_parameters


for i in `seq 1950 1951`
do

echo $i

  for plik in *$i*.nc
  do
    echo $plik
    # opcjonalnie tutaj zmienic koordynaty jesli bedzie frunal inny kraj
    #cdo -sellonlatbox,-5.5,10,41,51.5 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR $plik /home/bartosz/grad/$plik
    cdo -sellonlatbox,13.6,24.5,48.5,55 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR $plik /home/bartosz/grad_pl/$plik
  done

cdo mergetime /home/bartosz/grad_pl/*parameters_comp.nc /home/bartosz/grad_pl/$i.nc
rm /home/bartosz/grad_pl/*parameters_comp.nc

done

#cdo -sellonlatbox,-5.5,10,41,51.5 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR 1950-01-01_parameters_comp.nc /home/bartosz/grad/1950-01-01_parameters_comp.nc


