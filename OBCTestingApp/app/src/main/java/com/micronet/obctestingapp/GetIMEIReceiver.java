package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;
import android.util.Log;

/**
 * Returns the IMEI from the device.
 *
 * Created by scott.krstyen on 3/20/2017.
 */
public class GetIMEIReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (MainActivity.testToolLock.isUnlocked()) {
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
        }else{
            setResultCode(3);
            setResultData("F app locked");
        }
    }
}
