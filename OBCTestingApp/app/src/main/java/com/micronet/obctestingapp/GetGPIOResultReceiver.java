package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.Arrays;

/**
 * Runs an automated GPIO test.
 *
 * Created by scott.krstyen on 4/21/2017.
 */

public class GetGPIOResultReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder returnString;

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

        // Initialize MControl
        mControl = new MControl();

        // Start automated GPIO test
        automatedGPIOTest();

        // Return result depending on finalResult
        if(finalResult){
            Log.i(TAG, "*** GPOutput Test Passed ***");
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            Log.i(TAG, "*** GPOutput Test Failed ***");
            setResultCode(2);
            setResultData(returnString.toString());
        }
    }

    /**
     * Automated test for testing GPIO on the OBC5.
     */
    private void automatedGPIOTest() {

        Log.i(TAG, "*** GPOutput Test Started ***");

        // New return string
        returnString = new StringBuilder();

        // Set default result to true
        finalResult = true;


        if(setAndCheckGPIOValues(new int[] {0, 0, 0, 0})){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        if(setAndCheckGPIOValues(new int[] {1, 0, 0, 0})){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        if(setAndCheckGPIOValues(new int[] {0, 1, 0, 0})){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        if(setAndCheckGPIOValues(new int[] {0, 0, 1, 0})){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        if(setAndCheckGPIOValues(new int[] {0, 0, 0, 1})){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

    }

    /**
     * Sets the outputs to high or low depending on the outputArray and then checks that the input voltages
     * are what they should be.
     * @param outputArray - Holds whether the given output is high or low.
     * @return - A boolean that tells whether this individual test passed or not.
     */
    private boolean setAndCheckGPIOValues(int[] outputArray){

        try{
            // Set outputs from outputArray
            setGPIOValue(GP_OUTPUT_0, outputArray[0]);
            setGPIOValue(GP_OUTPUT_1, outputArray[1]);
            setGPIOValue(GP_OUTPUT_2, outputArray[2]);
            setGPIOValue(GP_OUTPUT_3, outputArray[3]);

            // Show array for debugging purposes
            Log.i(TAG, "GPOutputs set to: " + Arrays.toString(outputArray));

            // Brief pause
            Thread.sleep(1000);

            // From the outputs decide what whether the inputs should be high or low
            getExpectedInputsFromOutputs(outputArray);

            // If all voltages were in the correct range then return true, else return false.
            if(checkInputValues()){
                return true;
            }else{
                return false;
            }



        }catch(Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            return false;
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

    /**
     * Used to get the expected input values (whether inputs should be high or low) depending on what
     * the outputs are set to (high or low).
     * @param outputArray - The array that holds which outputs are set to high and low.
     */
    private void getExpectedInputsFromOutputs(int[] outputArray) {

        // array values initialize to false
        inputsHighOrLowArray = new boolean[7];

        // If output 0 is low then input 1 and 5 should be high
        if(outputArray[0] == 0){
            inputsHighOrLowArray[0] = true;
            inputsHighOrLowArray[4] = true;
        }

        // If output 1 is low then input 2 and 6 should be high
        if(outputArray[1] == 0){
            inputsHighOrLowArray[1] = true;
            inputsHighOrLowArray[5] = true;
        }

        // If output 2 is low then input 3 and 7 should be high
        if(outputArray[2] == 0){
            inputsHighOrLowArray[2] = true;
            inputsHighOrLowArray[6] = true;
        }

        // If output 3 is low then input 4 should be high
        if(outputArray[3] == 0){
            inputsHighOrLowArray[3] = true;
        }

    }

    /**
     * Checks the input voltages to make sure they are in the correct range.
     * @return - A boolean on whether the whole check for all inputs passed or failed.
     */
    private boolean checkInputValues() {

        inputVoltages = new int[7];

        // Result default should be true
        boolean result = true;

        // Input 1
        // If output 0 is low then the voltage for input 1 should be between 9000 and 13000 mv, else the
        // voltage for input 1 should be between 0 and 500.
        if(inputsHighOrLowArray[0]){
            if(!checkGPIOValue(1, 9000, 13000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(1, 0, 500)){
                result = false;
            }

        }

        // Input 2
        // If output 1 is low then the voltage for input 2 should be between 4000 and 5000 mv, else the
        // voltage for input 2 should be between 0 and 500.
        if(inputsHighOrLowArray[1]){
            if(!checkGPIOValue(2, 4000, 5000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(2, 0, 500)){
                result = false;
            }
        }

        // Input 3
        // If output 2 is low then the voltage for input 3 should be between 9000 and 13000 mv, else the
        // voltage for input 3 should be between 0 and 500.
        if(inputsHighOrLowArray[2]){
            if(!checkGPIOValue(3, 9000, 13000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(3, 0, 500)){
                result = false;
            }
        }

        // Input 4
        // If output 3 is low then the voltage for input 4 should be between 4000 and 5000 mv, else the
        // voltage for input 4 should be between 0 and 500.
        if(inputsHighOrLowArray[3]){
            if(!checkGPIOValue(4, 4000, 5000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(4, 0, 500)){
                result = false;
            }
        }

        // Input 5
        // If output 0 is low then the voltage for input 5 should be between 9000 and 13000 mv, else the
        // voltage for input 5 should be between 0 and 500.
        if(inputsHighOrLowArray[4]){
            if(!checkGPIOValue(5, 9000, 13000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(5, 0, 500)){
                result = false;
            }
        }

        // Input 6
        // If output 1 is low then the voltage for input 6 should be between 4000 and 5000 mv, else the
        // voltage for input 6 should be between 0 and 500.
        if(inputsHighOrLowArray[5]){
            if(!checkGPIOValue(6, 4000, 5000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(6, 0, 500)){
                result = false;
            }
        }

        // Input 7
        // If output 2 is low then the voltage for input 7 should be between 9000 and 13000 mv, else the
        // voltage for input 7 should be between 0 and 500.
        if(inputsHighOrLowArray[6]){
            if(!checkGPIOValue(7, 9000, 13000)){
                result = false;
            }
        }else{
            if(!checkGPIOValue(7, 0, 500)){
                result = false;
            }
        }

        Log.i(TAG, "Input voltages are: " + Arrays.toString(inputVoltages));

        // If all passed then result will be true, else result will be false
        return result;
    }



    private boolean checkGPIOValue(int gpiNum, int lowerBound, int upperBound) {

        int value = mControl.get_adc_or_gpi_voltage(gpiNum);

        inputVoltages[gpiNum-1] = value;

        if(lowerBound <= value && value <= upperBound){
            return true;
        }else{
            Log.e(TAG, "GPI " + gpiNum + " is " + value + " but should be between " + lowerBound + " and " + upperBound);
            finalResult = false;
            return false;
        }

    }





}
