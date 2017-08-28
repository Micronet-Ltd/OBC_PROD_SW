package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Runs an automated GPIO test.
 *
 * Created by scott.krstyen on 4/21/2017.
 */

public class GetGPIOResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder returnString;
    private StringBuilder failureString;

    private boolean finalResult = true;

    private MControl mControl;

    // Holds whether the given input should be high or low
    private boolean[] inputsHighOrLowArray;

    // An array that holds the input voltages as they are read
    private int[] inputVoltages;

    // GPIO numbers for the outputs
    private static final int GP_OUTPUT_0 = 267;
    private static final int GP_OUTPUT_1 = 272;
    private static final int GP_OUTPUT_2 = 273;
    private static final int GP_OUTPUT_3 = 261;


    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        // Initialize MControl
        mControl = new MControl();

        // Start automated GPIO test
        automatedGPIOTest();

        // Return result depending on finalResult
        if(finalResult){
            Log.i(TAG, "*** GPIO Test Passed ***");
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            Log.i(TAG, "*** GPIO Test Failed ***");
            setResultCode(2);
            setResultData(returnString.toString() + failureString.toString());
        }
    }

    /**
     * Automated test for testing GPIO on the OBC5.
     */
    private void automatedGPIOTest() {

        Log.i(TAG, "*** GPIO Test Started ***");

        // New return string
        returnString = new StringBuilder();
        failureString = new StringBuilder();

        returnString.append("GPIO ");
        failureString.append("Failures:");

        // Set default result to true
        finalResult = true;

        // ************ INPUT CHECK ****************

        // Check all inputs initially with all outputs set to 0
        setGPIOValue(GP_OUTPUT_0, 0);
        setGPIOValue(GP_OUTPUT_1, 0);
        setGPIOValue(GP_OUTPUT_2, 0);
        setGPIOValue(GP_OUTPUT_3, 0);

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        // Check ignition
        if(!checkInputValue(0, 4000, 14000)){
            failureString.append(" 0");
        }

        // Check Input 1
        if(!checkInputValue(1, 9000, 14000)){
            failureString.append(" 1");
        }

        // Check Input 2
        if(!checkInputValue(2, 4000, 5500)){
            failureString.append(" 2");
        }

        // Check Input 3
        if(!checkInputValue(3, 9000, 14000)){
            failureString.append(" 3");
        }

        // Check Input 4
        if(!checkInputValue(4, 4000, 5500)){
            failureString.append(" 4");
        }

        // Check Input 5
        if(!checkInputValue(5, 9000, 14000)){
            failureString.append(" 5");
        }

        // Check Input 6
        if(!checkInputValue(6, 4000, 5500)){
            failureString.append(" 6");
        }

        // Check Input 7
        if(!checkInputValue(7, 9000, 14000)){
            failureString.append(" 7");
        }

        // *********** OUTPUT 0 CHECK ***********

        // Set output 0 to high. Input 1 and 5 should go low.
        setGPIOValue(GP_OUTPUT_0, 1);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        boolean output0WorkingProperly = true;

        if(!checkGPIOValue(1, 0, 500, 0, "high")){
            output0WorkingProperly = false;
        }

        if(!checkGPIOValue(5, 0, 500, 0, "high")){
            output0WorkingProperly = false;
        }

        // Set output 0 to low. Input 1 and 5 should go high.
        setGPIOValue(GP_OUTPUT_0, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(1, 9000, 13000, 0, "low")){
            output0WorkingProperly = false;
        }

        if(!checkGPIOValue(5, 9000, 13000, 0, "low")){
            output0WorkingProperly = false;
        }

        if(!output0WorkingProperly){
            failureString.append(" O0");
        }

        // *********** OUTPUT 1 CHECK ***********

        // Set output 0 to high. Input 2 and 6 should go low.
        setGPIOValue(GP_OUTPUT_1, 1);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        boolean output1WorkingProperly = true;

        if(!checkGPIOValue(2, 0, 500, 1, "high")){
            output1WorkingProperly = false;
        }

        if(!checkGPIOValue(6, 0, 500, 1, "high")){
            output1WorkingProperly = false;
        }

        // Set output 1 to low. Input 2 and 6 should go high.
        setGPIOValue(GP_OUTPUT_1, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(2, 4000, 5000, 1, "low")){
            output1WorkingProperly = false;
        }

        if(!checkGPIOValue(6, 4000, 5000, 1, "low")){
            output1WorkingProperly = false;
        }

        if(!output1WorkingProperly){
            failureString.append(" O1");
        }

        // *********** OUTPUT 2 CHECK ***********

        // Set output 2 to high. Input 3 and 7 should go low.
        setGPIOValue(GP_OUTPUT_2, 1);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        boolean output2WorkingProperly = true;

        if(!checkGPIOValue(3, 0, 500, 2, "high")){
            output2WorkingProperly = false;
        }

        if(!checkGPIOValue(7, 0, 500, 2, "high")){
            output2WorkingProperly = false;
        }

        // Set output 0 to low. Input 3 and 7 should go high.
        setGPIOValue(GP_OUTPUT_2, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(3, 9000, 13000, 2, "low")){
            output2WorkingProperly = false;
        }

        if(!checkGPIOValue(7, 9000, 13000, 2, "low")){
            output2WorkingProperly = false;
        }

        if(!output2WorkingProperly){
            failureString.append(" O2");
        }

        // *********** OUTPUT 3 CHECK ***********

        // Set output 3 to high. Input 4 should go low.
        setGPIOValue(GP_OUTPUT_3, 1);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        boolean output3WorkingProperly = true;

        if(!checkGPIOValue(4, 0, 500, 3, "high")){
            output3WorkingProperly = false;
        }

        // Set output 1 to low. Input 2 and 6 should go high.
        setGPIOValue(GP_OUTPUT_3, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(4, 4000, 5500, 3, "low")){
            output3WorkingProperly = false;
        }

        if(!output3WorkingProperly){
            failureString.append(" O3");
        }

    }

    /**
     * Used to set the inputted GPIO number to the inputted GPIO value.
     * @param gpioNumber - The desired GPIO number.
     * @param value - The value to set the GPIO to (should be either 1 or 0).
     */
    private void setGPIOValue(int gpioNumber, int value)  {

        // Set the GPIO number to the inputted GPIO value
        mControl.set_gpio_state_dbg(gpioNumber, value);

    }

    private boolean checkGPIOValue(int gpiNum, int lowerBound, int upperBound, int output, String state) {

        int value = mControl.get_adc_or_gpi_voltage(gpiNum);

        int count = 0;

        do {

            value = mControl.get_adc_or_gpi_voltage(gpiNum);
            count++;
            Log.d(TAG, "Input " + gpiNum + "'s voltage is " + value + " on read #" + count);
            if(value > 500000) {
                try {
                    Thread.sleep(50);
                } catch (InterruptedException e) {
                    e.printStackTrace(); // TODO: do something about this
                }
            }
        } while(value > 500000 && count < 50);

        if(count == 50) {
            Log.e(TAG, "Input " + gpiNum + " retried " + count + " times.");
        }

        if(lowerBound <= value && value <= upperBound){
            Log.i(TAG, "Output " + output + " is " + state + ": Input " + gpiNum + "'s voltage is " + value);
            return true;
        }else{
            Log.e(TAG, "Input " + gpiNum + " is " + value + " but should be between " + lowerBound + " and " + upperBound + " while Output " + output + " is " + state);
            finalResult = false;
            return false;
        }

    }

    private boolean checkInputValue(int gpiNum, int lowerBound, int upperBound) {

        int value;
        int count = 0;

        do {
            value = mControl.get_adc_or_gpi_voltage(gpiNum);
            count++;
            Log.d(TAG, "Input " + gpiNum + "'s voltage is " + value + " on read #" + count);
            if(value > 500000) {
                try {
                    Thread.sleep(50);
                } catch (InterruptedException e) {
                    Log.e(TAG, e.toString()); // TODO: do something about this
                }
            }
        } while(value > 500000 && count < 50);

        if(count == 50) {
            Log.e(TAG, "Input " + gpiNum + " retried " + count + " times.");
        }

        if(lowerBound <= value && value <= upperBound){
            String s = gpiNum + ": " + value + ", ";
            returnString.append(s);
            Log.i(TAG, "Input " + gpiNum + "'s voltage is " + value);
            return true;
        } else {
            String s = gpiNum + ": " + value + ", ";
            returnString.append(s);
            Log.e(TAG, "Input " + gpiNum + " is " + value + " but should be between " + lowerBound + " and " + upperBound);
            finalResult = false;
            return false;
        }

    }

}