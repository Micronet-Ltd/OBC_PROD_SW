package com.micronet.obctestingapp;

import android.content.Context;
import android.location.GpsSatellite;
import android.location.GpsStatus;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

/**
 * Created by scott.krstyen on 11/6/2017.
 */

public class GPS implements GpsStatus.Listener {  //, LocationListener {

    private final String TAG = "OBCTestingApp";
    private LocationManager locationManager = null;
    private final Object lock = new Object();
    private static final long INTERVAL_ONE_SECOND = 1000; // minimum time interval between location updates, in milliseconds

    private int satellites;
    private int satellitesInFix;
    private int timeToFirstFix;
    private float averageSNROfTopThreeSatellites;
    private float averageSNRUsedInFix;
    private float totalSNRUsedInFix;
    private ArrayList<Float> averageSNRList;

    public GPS(Context context){
        satellites = 0;
        satellitesInFix = 0;
        timeToFirstFix = 0;
        totalSNRUsedInFix = 0;
        averageSNRUsedInFix = 0;
        averageSNROfTopThreeSatellites = 0;

        locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

        locationManager.addGpsStatusListener(this);
        //locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, INTERVAL_ONE_SECOND, 0, this);
    }

    @Override
    public void onGpsStatusChanged(int event) {
        switch (event) {
            case GpsStatus.GPS_EVENT_STARTED:
                Log.e(TAG, "onGpsStatusChanged started");
                break;

            case GpsStatus.GPS_EVENT_STOPPED:
                Log.e(TAG, "onGpsStatusChanged stopped");
                break;

            case GpsStatus.GPS_EVENT_FIRST_FIX:
                Log.e(TAG, "onGpsStatusChanged first fix");
                synchronized (lock) {
                    timeToFirstFix = locationManager.getGpsStatus(null).getTimeToFirstFix();
                    Log.d(TAG, String.format("Time To First Fix = %d", timeToFirstFix));
                }
                break;

            case GpsStatus.GPS_EVENT_SATELLITE_STATUS:
                Log.e(TAG, "onGpsStatusChanged status");
                synchronized (lock){
                    averageSNRList = new ArrayList<Float>();
                    satellites = 0;
                    satellitesInFix = 0;
                    averageSNRUsedInFix = 0;
                    totalSNRUsedInFix = 0;
                    averageSNROfTopThreeSatellites = 0;
                    timeToFirstFix = locationManager.getGpsStatus(null).getTimeToFirstFix();
                    Log.i(TAG, "Time to first fix = " + timeToFirstFix);
                    for (GpsSatellite sat : locationManager.getGpsStatus(null).getSatellites()) {
                        if(sat.usedInFix()) {
                            satellitesInFix++;
                            Log.i(TAG, "SNR: " + sat.getSnr());
                            averageSNRList.add(sat.getSnr());
                            totalSNRUsedInFix += sat.getSnr();
                            averageSNRUsedInFix = totalSNRUsedInFix/satellitesInFix;
                        }
                        satellites++;
                    }

                    Log.i(TAG, "Satellites: " + satellites + ", Used In Last Fix: " + satellitesInFix + ", Average SNR: " + averageSNRUsedInFix);
                }
                break;
        }
    }

    public int getSatellites(){
        int numOfSatellites = 0;

        synchronized (lock){
            numOfSatellites = satellites;
        }

        return numOfSatellites;
    }

    public int getSatellitesUsedInFix(){
        int numOfSatellitesUsedInFix = 0;

        synchronized (lock){
            numOfSatellitesUsedInFix = satellitesInFix;
        }

        return numOfSatellitesUsedInFix;
    }

    public int getTimeToFirstFix(){
        int tempTimeToFirstFix = 0;

        synchronized (lock){
            tempTimeToFirstFix = timeToFirstFix;
        }

        return tempTimeToFirstFix;
    }

    public float getAverageSNRUsedInFix(){
        float tempAverageSNRUsedInFix = 0;

        synchronized (lock){
            tempAverageSNRUsedInFix = averageSNRUsedInFix;
        }

        return tempAverageSNRUsedInFix;
    }

    public float getAverageSNROfTopSatellitesUsedInFix(int num){
        float tempAverageSNROfTopSatellites = 0;

        synchronized (lock){
            if(averageSNRList != null && num <= averageSNRList.size()){
                Collections.sort(averageSNRList);

                averageSNROfTopThreeSatellites = 0;

                for(int i = 0; i < num; i++){
                    averageSNROfTopThreeSatellites += averageSNRList.get(averageSNRList.size()-i-1);
                }
                averageSNROfTopThreeSatellites /= num;

                tempAverageSNROfTopSatellites = averageSNROfTopThreeSatellites;
            }else{
                tempAverageSNROfTopSatellites = -1;
            }

        }

        return tempAverageSNROfTopSatellites;
    }

//    @Override
//    public void onLocationChanged(Location location) {
//        Log.e(TAG, "Location Change -> Accuracy: " + location.getAccuracy());
//    }
//
//    @Override
//    public void onStatusChanged(String provider, int status, Bundle extras) {
//
//    }
//
//    @Override
//    public void onProviderEnabled(String provider) {
//
//    }
//
//    @Override
//    public void onProviderDisabled(String provider) {
//
//    }
}
