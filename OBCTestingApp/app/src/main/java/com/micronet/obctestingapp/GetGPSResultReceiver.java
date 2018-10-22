package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;

/**
 * Created by scott.krstyen on 11/3/2017.
 */

public class GetGPSResultReceiver extends MicronetBroadcastReceiver {

    private int satellites;
    private int satellitesInFix;
    private int timeToFirstFix;
    private float averageSNRUsedInFix;
    private float averageSNROfTopSatellites;

    @Override
    public void onReceive(Context context, Intent intent) {

        if (MainActivity.testToolLock.isUnlocked()) {

            int numOfSatellitesToTakeAverageOf = intent.getIntExtra("NumOfAverageSatellites", 3);

            // Use GPS from MainActivity so that we can start the GPS earlier.
            satellites = MainActivity.gps.getSatellites();
            satellitesInFix = MainActivity.gps.getSatellitesUsedInFix();
            timeToFirstFix = MainActivity.gps.getTimeToFirstFix();
            averageSNRUsedInFix = MainActivity.gps.getAverageSNRUsedInFix();
            averageSNROfTopSatellites = MainActivity.gps.getAverageSNROfTopSatellitesUsedInFix(numOfSatellitesToTakeAverageOf);

            if(satellites > 0){
                setResultCode(1);
                setResultData("Satellites:"+satellites+",Satellites in fix:"+satellitesInFix+",Time to first fix:"
                        +timeToFirstFix+",Average SNR in Fix:"+averageSNRUsedInFix+",Average SNR of top satellites:" + averageSNROfTopSatellites);
            }else{
                setResultCode(2);
                setResultData("Satellites:"+satellites+",Satellites in fix:"+satellitesInFix+",Time to first fix:"
                        +timeToFirstFix+",Average SNR in Fix:"+averageSNRUsedInFix+",Average SNR of top satellites:" + averageSNROfTopSatellites);
            }

        }else{
            setResultCode(3);
            setResultData("F app locked");
        }



    }


}
