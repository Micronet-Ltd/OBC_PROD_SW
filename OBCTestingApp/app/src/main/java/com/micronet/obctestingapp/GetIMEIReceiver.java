package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;

/**
 * Created by scott.krstyen on 3/20/2017.
 */

public class GetIMEIReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {

        TelephonyManager telephonyManager = ((TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE));
        String  imei;
        try {
            imei = telephonyManager.getDeviceId();
        } catch (Exception e) {
            imei = "Error!!";
        }

        setResultData(imei);
    }
}
