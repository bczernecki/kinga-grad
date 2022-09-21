#/bin/bash

# obliczenia do gradu:

cd /media/tornado/Seagate_041/ERA5_EU_parameters


for i in `seq 1950 2021`
do

echo $i

  for plik in *$i*.nc
  do
    echo $plik
    # opcjonalnie tutaj zmienic koordynaty jesli bedzie frunal inny kraj
    cdo -sellonlatbox,-10,4.5,35.5,44 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR $plik /home/bartosz/grad/$plik
    #cdo -sellonlatbox,13.6,24.5,48.5,55 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR $plik /home/bartosz/grad/$plik
  done

cdo mergetime /home/bartosz/grad/*parameters_comp.nc /home/bartosz/grad/$i.nc
rm /home/bartosz/grad/*parameters_comp.nc

done

#cdo -sellonlatbox,-5.5,10,41,51.5 -selvar,HSI,SHIP,BS_EFF_MU,MU_LI,MU_WMAX,MU_LCL_TEMP,MU_MIXR 1950-01-01_parameters_comp.nc /home/bartosz/grad/1950-01-01_parameters_comp.nc
cdo mergetime [1-2]*.nc calosc.nc
cdo yearpctl,99 calosc.nc -yearmin calosc.nc -yearmax calosc.nc calosc_p99.nc
cdo -expr,'lghail=(1-(1/(1+(10*(1+BS_EFF_MU)*(-MU_LI))/MU_LCL_TEMP^2)))*MU_MIXR*0.5*(1+sqrt((1+BS_EFF_MU)*(-MU_LI)/10))' calosc.nc lghail.nc
cdo yearpctl,99 lghail.nc -yearmin lghail.nc -yearmax lghail.nc lghail_p99.nc
