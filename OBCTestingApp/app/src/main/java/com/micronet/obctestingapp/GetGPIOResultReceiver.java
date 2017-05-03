package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;

/**
 * Created by scott.krstyen on 4/21/2017.
 */

public class GetGPIOResultReceiver extends BroadcastReceiver {

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
    private String[] inputValues;

    @Override
    public void onReceive(Context context, Intent intent) {

        returnString = new StringBuilder();

        try {
            automatedGPIOTest();
        } catch (Exception e) {
            Log.e(TAG, e.toString());
            finalResult = false;
            returnString.append("FFFF");
        }

        if(finalResult){
            Log.i(TAG, "*** GPIO Test Passed ***");
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            Log.i(TAG, "*** CANBus Test Failed ***");
            setResultCode(2);
            setResultData(returnString.toString());
        }
    }

    private void automatedGPIOTest() throws Exception {

        Log.i(TAG, "*** GPIO Test Started ***");

        // Set initially to false. If it makes it through the whole test without returning then it is successful
        finalResult = false;

        // Arrays to hold values of outputs and inputs
        outputValues = new String[4];
        inputValues = new String[4];

        // Export all the gpio values
        exportGPIO();

        if(!setAndCheckGPIOValues(new String[]{"0","0","0","0"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"1","0","0","0"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"0","1","0","0"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"0","0","1","0"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"0","0","0","1"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"1","1","1","1"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"0","1","1","1"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"1","0","1","1"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"1","1","0","1"})){
            finalResult = false;
            return;
        }

        if(!setAndCheckGPIOValues(new String[]{"1","1","1","0"})){
            finalResult = false;
            return;
        }

        // Return outputs all to zero to end test
        if(!setAndCheckGPIOValues(new String[]{"0","0","0","0"})){
            finalResult = false;
            return;
        }

        finalResult = true;
        return;

    }

    private boolean setAndCheckGPIOValues(String[] testArray) throws Exception {

        // Set all output values array values passed in
        setGPIOValue(GPOutput0, testArray[0]);
        setGPIOValue(GPOutput1, testArray[1]);
        setGPIOValue(GPOutput2, testArray[2]);
        setGPIOValue(GPOutput3, testArray[3]);

        Thread.sleep(500);

        // Get all values to compare them with the array passed in
        getOutputValues();
        getInputValues();

        // If values aren't correct then set final result to false
        if(!(Arrays.equals(outputValues, testArray) && Arrays.equals(inputValues, testArray))){
            return false;
        }
        else{ // Values are all correct so return true
            return true;
        }
    }

    private void exportGPIO() throws IOException {
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
    }

    private void getInputValues() throws Exception {
        inputValues[0] = readValueFromFile(GPInput1);
        inputValues[1] = readValueFromFile(GPInput2);
        inputValues[2] = readValueFromFile(GPInput3);
        inputValues[3] = readValueFromFile(GPInput4);
    }

    private void getOutputValues() throws Exception {
        outputValues[0] = readValueFromFile(GPOutput0);
        outputValues[1] = readValueFromFile(GPOutput1);
        outputValues[2] = readValueFromFile(GPOutput2);
        outputValues[3] = readValueFromFile(GPOutput3);
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
