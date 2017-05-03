package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;
import android.util.Log;

/**
 * Created by scott.krstyen on 3/20/2017.
 */

/**
 * Returns the IMEI from the device.
 */
public class GetIMEIReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent) {

        TelephonyManager telephonyManager = ((TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE));
        String  imei;

        try {
            // Try to get IMEI
            imei = telephonyManager.getDeviceId();
            setResultCode(1);
            Log.i(TAG, "IMEI: " + imei);
        } catch (Exception e) {
            imei = "Error";
            setResultCode(2);
        }

        setResultData(imei);
    }
}
