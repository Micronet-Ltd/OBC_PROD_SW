package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.security.NoSuchAlgorithmException;

public class CheckUnlockHashReceiver extends MicronetBroadcastReceiver {
    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent){
        super.onReceive(context, intent);
        String fileSize = intent.getStringExtra("fs");
        String hash = intent.getStringExtra("h");
        Log.i(TAG, "*** Hash onReceive *** fileSize=" + fileSize + ", hash=" + hash);

        try{
            if (MainActivity.testToolLock.verifyHash(fileSize, hash)){
                Log.i(TAG, "Test Tool unlocked");
                setResultCode(1);
            }
            else {
                setResultCode(2);
            }
        }catch (Exception e){
            Log.e(TAG, e.toString());
        }
    }
}
