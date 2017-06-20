package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

/**
 * Created by austin.oneil on 6/19/2017.
 */

public abstract class MicronetBroadcastReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent) {
        PackageInfo pInfo = null;
        try {
            pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        String version = pInfo.versionName;
        Log.i(TAG, "Version " + version);
    }
}
