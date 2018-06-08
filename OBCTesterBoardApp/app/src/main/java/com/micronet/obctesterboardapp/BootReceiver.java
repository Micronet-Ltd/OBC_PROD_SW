package com.micronet.obctesterboardapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Created by scott.krstyen on 3/15/2018.
 */

public class BootReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTesterBoardApp";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Intent mainIntent = new Intent(context, MainActivity.class);
            mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(mainIntent);
            Log.d(TAG, "Boot broadcast received. Starting application.");
        }
    }
}
