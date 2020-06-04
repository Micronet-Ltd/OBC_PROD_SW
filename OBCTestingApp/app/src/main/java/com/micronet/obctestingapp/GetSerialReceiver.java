package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Returns the Serial Number from the device.
 *
 * Created by scott.krstyen on 3/20/2017.
 */
public class GetSerialReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

//        if (MainActivity.testToolLock.isUnlocked()) {

            setResultData(getSerialNumber());

//        }else{
//            setResultCode(3);
//            setResultData("F app locked");
//        }


    }

    private String getSerialNumber() {
        String line;
        String serialNumberLine;
        String serialNumber;
        try {
            // Try to get the serial number
            Process process = new ProcessBuilder().command("/system/bin/getprop").redirectErrorStream(true).start();
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            // Comes from this line [ro.serialno]: [5506a61a]
            while ((line = bufferedReader.readLine()) != null) {
                if (line.toLowerCase().contains("ro.boot.serialno")) {
                    serialNumberLine = line;

                    // Check for the last ']' because that is the char after the serial number
                    int lastIndex = serialNumberLine.lastIndexOf(']');

                    // Set serial number
                    serialNumber = serialNumberLine.substring(21,lastIndex).toUpperCase();

                    Log.i(TAG, "Serial Number: " + serialNumber);
                    setResultCode(1);
                    return serialNumber;
                }
            }
            process.destroy();
        } catch (IOException e) {
            Log.e(this.toString(), e.getMessage());
        } catch (Exception e) {
            Log.e(this.toString(), e.getMessage());
        }

        // If there is an error getting the serial number then return 2 as result code
        setResultCode(2);
        return "Error";
    }
}
