package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.Arrays;

/**
 * Runs an automated GPIO test.
 *
 * Created by scott.krstyen on 4/21/2017.
 */

public class GetGPIOResultReceiver extends MicronetBroadcastReceiver {
    private final String TAG = "OBCTestingApp";

    private StringBuilder returnString;
    private boolean finalResult = true;
    private MControl mControl;

    // GPIO numbers for the outputs
    private static final int GP_OUTPUT_0 = 267;
    private static final int GP_OUTPUT_1 = 272;
    private static final int GP_OUTPUT_2 = 273;
    private static final int GP_OUTPUT_3 = 261;

    // Default thresholds
    private int[] thresholds = new int[]{9000, 30000, 9000, 30000, 4000, 5500, 0, 500};

    private int ignitionLowerThreshold;
    private int ignitionUpperThreshold;
    private int highLowerThreshold;
    private int highUpperThreshold;
    private int resistedHighLowerThreshold;
    private int resistedHighUpperThreshold;
    private int lowLowerThreshold;
    private int lowUpperThreshold;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (MainActivity.testToolLock.isUnlocked()) {
            // Check for passed threshold values
            int[] tmpThresholds = intent.getIntArrayExtra("thresholds");
            if(tmpThresholds != null && tmpThresholds.length == 8) {
                thresholds = tmpThresholds;
                Log.d(TAG, "Using passed threshold values: " + Arrays.toString(thresholds));
            } else {
                Log.d(TAG, "Using default threshold values: " + Arrays.toString(thresholds));
            }

            ignitionLowerThreshold = thresholds[0];
            ignitionUpperThreshold = thresholds[1];

            highLowerThreshold = thresholds[2];
            highUpperThreshold = thresholds[3];

            resistedHighLowerThreshold = thresholds[4];
            resistedHighUpperThreshold = thresholds[5];

            lowLowerThreshold = thresholds[6];
            lowUpperThreshold = thresholds[7];

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
                setResultData(returnString.toString());
            }

        }else{
            setResultCode(3);
            setResultData("F app locked");
        }


    }

    /**
     * Automated test for testing GPIO on the OBC5.
     */
    private void automatedGPIOTest() {

        Log.i(TAG, "*** GPIO Test Started ***");

        // New return string
        returnString = new StringBuilder();

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
        if(checkInputValue(0, ignitionLowerThreshold, ignitionUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 1
        if(checkInputValue(1, highLowerThreshold, highUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 2
        if(checkInputValue(2, resistedHighLowerThreshold, resistedHighUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 3
        if(checkInputValue(3, highLowerThreshold, highUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 4
        if(checkInputValue(4, resistedHighLowerThreshold, resistedHighUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 5
        if(checkInputValue(5, highLowerThreshold, highUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 6
        if(checkInputValue(6, resistedHighLowerThreshold, resistedHighUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
        }

        // Check Input 7
        if(checkInputValue(7, highLowerThreshold, highUpperThreshold)){
            returnString.append("P");
        }else{
            returnString.append("F");
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

        if(!checkGPIOValue(1, lowLowerThreshold, lowUpperThreshold, 0, "high")){
            output0WorkingProperly = false;
        }

        if(!checkGPIOValue(5, lowLowerThreshold, lowUpperThreshold, 0, "high")){
            output0WorkingProperly = false;
        }

        // Set output 0 to low. Input 1 and 5 should go high.
        setGPIOValue(GP_OUTPUT_0, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(1, highLowerThreshold, highUpperThreshold, 0, "low")){
            output0WorkingProperly = false;
        }

        if(!checkGPIOValue(5, highLowerThreshold, highUpperThreshold, 0, "low")){
            output0WorkingProperly = false;
        }

        if(output0WorkingProperly){
            returnString.append("P");
        }else{
            returnString.append("F");
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

        if(!checkGPIOValue(2, lowLowerThreshold, lowUpperThreshold, 1, "high")){
            output1WorkingProperly = false;
        }

        if(!checkGPIOValue(6, lowLowerThreshold, lowUpperThreshold, 1, "high")){
            output1WorkingProperly = false;
        }

        // Set output 1 to low. Input 2 and 6 should go high.
        setGPIOValue(GP_OUTPUT_1, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(2, resistedHighLowerThreshold, resistedHighUpperThreshold, 1, "low")){
            output1WorkingProperly = false;
        }

        if(!checkGPIOValue(6, resistedHighLowerThreshold, resistedHighUpperThreshold, 1, "low")){
            output1WorkingProperly = false;
        }

        if(output1WorkingProperly){
            returnString.append("P");
        }else{
            returnString.append("F");
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

        if(!checkGPIOValue(3, lowLowerThreshold, lowUpperThreshold, 2, "high")){
            output2WorkingProperly = false;
        }

        if(!checkGPIOValue(7, lowLowerThreshold, lowUpperThreshold, 2, "high")){
            output2WorkingProperly = false;
        }

        // Set output 0 to low. Input 3 and 7 should go high.
        setGPIOValue(GP_OUTPUT_2, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(3, highLowerThreshold, highUpperThreshold, 2, "low")){
            output2WorkingProperly = false;
        }

        if(!checkGPIOValue(7, highLowerThreshold, highUpperThreshold, 2, "low")){
            output2WorkingProperly = false;
        }

        if(output2WorkingProperly){
            returnString.append("P");
        }else{
            returnString.append("F");
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

        if(!checkGPIOValue(4, lowLowerThreshold, lowUpperThreshold, 3, "high")){
            output3WorkingProperly = false;
        }

        // Set output 1 to low. Input 2 and 6 should go high.
        setGPIOValue(GP_OUTPUT_3, 0);

        try {
            Thread.sleep(750);
        } catch (InterruptedException e) {
            Log.e(TAG,e.toString());
        }

        if(!checkGPIOValue(4, resistedHighLowerThreshold, resistedHighUpperThreshold, 3, "low")){
            output3WorkingProperly = false;
        }

        if(output3WorkingProperly){
            returnString.append("P");
        }else{
            returnString.append("F");
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
                    e.printStackTrace(); // TODO: do something about this
                }
            }
        } while(value > 500000 && count < 50);

        if(count == 50) {
            Log.e(TAG, "Input " + gpiNum + " retried " + count + " times.");
        }

        if(lowerBound <= value && value <= upperBound){
            Log.i(TAG, "Input " + gpiNum + "'s voltage is " + value);
            return true;
        } else {
            Log.e(TAG, "Input " + gpiNum + " is " + value + " but should be between " + lowerBound + " and " + upperBound);
            finalResult = false;
            return false;
        }

    }

/*
    *//**
     * Sets the outputs to high or low depending on the outputArray and then checks that the input voltages
     * are what they should be.
     * @param outputArray - Holds whether the given output is high or low.
     * @return - A boolean that tells whether this individual test passed or not.
     *//*
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
    }*/


/*
    *//**
     * Used to get the expected input values (whether inputs should be high or low) depending on what
     * the outputs are set to (high or low).
     * @param outputArray - The array that holds which outputs are set to high and low.
     *//*
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

    *//**
     * Checks the input voltages to make sure they are in the correct range.
     * @return - A boolean on whether the whole check for all inputs passed or failed.
     *//*
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
    }*/









}