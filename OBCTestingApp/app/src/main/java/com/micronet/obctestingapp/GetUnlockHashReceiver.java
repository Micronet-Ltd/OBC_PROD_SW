package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.security.NoSuchAlgorithmException;

public class GetUnlockHashReceiver extends MicronetBroadcastReceiver {
    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent){
        super.onReceive(context, intent);
        String fileSize = intent.getStringExtra("fileSize");
        TestToolLock testToolLock = new TestToolLock();
        setResultData(testToolLock.calculateHash(fileSize));
    }
}
