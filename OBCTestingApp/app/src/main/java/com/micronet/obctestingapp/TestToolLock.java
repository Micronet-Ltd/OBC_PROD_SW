package com.micronet.obctestingapp;

import static com.micronet.obctestingapp.BuildConfig.DEBUG;

import android.util.Log;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class TestToolLock {
    private final String TAG = "OBCTestingApp_Hash";

    private boolean unlocked = false;

    public boolean isUnlocked(){
        if (unlocked == false){
            Log.e(TAG, "App locked");
        }
        return unlocked;
    }

    public boolean verifyHash(String fileSize, String hash){
        if (hash.equals(calculateHash(fileSize))){
            Log.i(TAG, "app unlocked");
            unlocked = true;
            return true;
        }
        else {
            Log.i(TAG, "app locked");
            unlocked = false;
            return false;
        }
    }

    public String calculateHash(String fileSize){
        if (fileSize == null){
            return "";
        }
        String hash = String.valueOf(fileSize.hashCode());
        //Log.i(TAG, "fileSize = "+ fileSize + ", calculated = " + hash );
        return hash;
    }
}
