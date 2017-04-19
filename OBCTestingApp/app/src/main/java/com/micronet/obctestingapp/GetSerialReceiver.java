package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by scott.krstyen on 3/20/2017.
 */

public class GetSerialReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        setResultData(getSerialNumber());
    }

    private String getSerialNumber() {
        String line;
        String serialNumber;
        try {
            Process process = new ProcessBuilder().command("/system/bin/getprop").redirectErrorStream(true).start();
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while ((line = bufferedReader.readLine()) != null) {
                if (line.toLowerCase().contains("serialno")) {
                    serialNumber = line;
                    return serialNumber.toUpperCase();
                }
            }
            process.destroy();
        } catch (IOException e) {
            Log.e(this.toString(), e.getMessage());
        } catch (Exception e) {
            Log.e(this.toString(), e.getMessage());
        }

        return "Error!!";
    }
}
