package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.Arrays;

/**
 * Created by scott.krstyen on 5/11/2017.
 */

public class GetAccelerometerResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private float[] acceleration;

    private boolean finalResult;

    private StringBuilder returnString;


    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (MainActivity.testToolLock.isUnlocked()) {
            automatedAccelerometerTest();

            if (finalResult) {
                Log.i(TAG, "*** Acceleration Test Passed ***");
                setResultCode(1);
                setResultData(returnString.toString() + " " + Arrays.toString(acceleration));
            } else {
                Log.i(TAG, "*** Acceleration Test Failed ***");
                setResultCode(2);
                setResultData(returnString.toString() + " " + Arrays.toString(acceleration));
            }
        }else{
            setResultCode(3);
            setResultData("F app locked");
        }
    }

    private void automatedAccelerometerTest(){

        Log.i(TAG, "*** Acceleration Test Started ***");

        acceleration = new float[3];
        finalResult = true;
        returnString = new StringBuilder();

        try{
            Accelerometer accel = new Accelerometer();
            accel.getAccel();
            acceleration[0] = accel.accelData[0];
            acceleration[1] = accel.accelData[1];
            acceleration[2] = accel.accelData[2];
        }catch (Exception e) {
            Log.e(TAG, e.toString());
            finalResult = false;
            returnString.append("F");
            return;
        }

        boolean validValues = true;

        // Make sure acceleration[0] is between -.2 and 0.2
        if(!(-0.2f < acceleration[0] && acceleration[0] < 0.2f)){
            validValues = false;
        }

        // Make sure acceleration[1] is between -.2 and 0.2
        if(!(-0.2f < acceleration[1] && acceleration[1] < 0.2f)){
            validValues = false;
        }

        // Make sure acceleration[2] is between .8 and 1.2
        if(!(0.8f < acceleration[2] && acceleration[2] < 1.2f)){
            validValues = false;
        }


        if(validValues){
            Log.i(TAG, "Acceleration values: " + Arrays.toString(acceleration));
            returnString.append("P");
        }else{
            Log.e(TAG, "Invalid acceleration values: " + Arrays.toString(acceleration));
            finalResult = false;
            returnString.append("F");
        }
    }

}
