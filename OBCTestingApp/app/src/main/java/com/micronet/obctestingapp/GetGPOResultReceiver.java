package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;

/**
 * Created by scott.krstyen on 4/21/2017.
 */

public class GetGPOResultReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder sb;
    private StringBuilder returnString;

    private File export = new File("/sys/class/gpio/export");

    private File GPInput1 = new File("/sys/class/gpio/gpio693/value");
    private File GPInput2 = new File("/sys/class/gpio/gpio694/value");
    private File GPInput3 = new File("/sys/class/gpio/gpio695/value");
    private File GPInput4 = new File("/sys/class/gpio/gpio696/value");

    private File GPOutput0 = new File("/sys/class/gpio/gpio700/value");
    private File GPOutput1 = new File("/sys/class/gpio/gpio701/value");
    private File GPOutput2 = new File("/sys/class/gpio/gpio702/value");
    private File GPOutput3 = new File("/sys/class/gpio/gpio703/value");

    private boolean finalResult = true;
    private boolean pass;

    private byte[] readBuffer;

    private FileInputStream inputStream;

    private BufferedWriter bw;
    private BufferedReader br;

    private String[] outputValues;

    @Override
    public void onReceive(Context context, Intent intent) {

        returnString = new StringBuilder();

        try {
            automatedGPOTest();
        } catch (Exception e) {
            Log.e(TAG, e.toString());
            finalResult = false;
            returnString.append("FFFF");
        }

        if(finalResult){
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            setResultCode(2);
            setResultData(returnString.toString());
        }
    }

    private void automatedGPOTest() throws Exception {

        outputValues = new String[4];

        bw = new BufferedWriter(new FileWriter(export));

        // Export GPInputs 1-4
        bw.write("693");
        bw.write("694");
        bw.write("695");
        bw.write("696");

        // Export GPOutputs 0-3
        bw.write("700");
        bw.write("701");
        bw.write("702");
        bw.write("703");

        bw.flush();
        bw.close();

        // Get default values
        outputValues[0] = readValueFromFile(GPOutput0);
        outputValues[1] = readValueFromFile(GPOutput1);
        outputValues[2] = readValueFromFile(GPOutput2);
        outputValues[3] = readValueFromFile(GPOutput3);

        // First set GPOutput 0 and 2 to high, then switch to GPOutput 1 and 4 high

        setGPIOValue(GPOutput0, "0");
        setGPIOValue(GPOutput0, "0");
        setGPIOValue(GPOutput0, "0");
        setGPIOValue(GPOutput0, "0");

    }

    private void setGPIOValue(File file, String s) throws Exception {

        bw = new BufferedWriter(new FileWriter(file));

        bw.write(s);

        bw.flush();
        bw.close();
    }

    private String readValueFromFile(File file) throws Exception {

        String value = "";
        br = new BufferedReader(new FileReader(file));

        value = br.readLine();

        br.close();
        return value;
    }


}
