package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Runs an automated ComPort test and returns the result.
 *
 * Created by scott.krstyen on 3/24/2017.
 */
public class GetComPortResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder sb;
    private StringBuilder resultStringBuilder;
    private StringBuilder returnString;

    private File Com1 = new File("/dev/ttyUSB0");
    private File Com2 = new File("/dev/ttyUSB1");
    private File Com3 = new File("/dev/ttyUSB2");
    private File Com4 = new File("/dev/ttyUSB3");

    private boolean finalResult = true;
    private boolean pass;

    private byte[] readBuffer;

    private FileInputStream inputStream;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

      //  if (MainActivity.testToolLock.isUnlocked()) {

            // Run the automated test
            automatedTest();

            // Returns the result depending on the result from the automated test
            if(finalResult){
                Log.i(TAG, "*** Com Port Test Passed ***");
                setResultCode(1);
                setResultData(returnString.toString()); // + resultStringBuilder.toString());
            }else{
                Log.i(TAG, "*** Com Port Test Failed ***");
                setResultCode(2);
                setResultData(returnString.toString()); // + resultStringBuilder.toString());
            }

//        }else{
//            setResultCode(3);
//            setResultData("F app locked");
//        }



    }

    /**
     * Automated ComPort test.
     */
    private void automatedTest()  {

        Log.i(TAG, "*** Com Port Test Started ***");

        // Reset final result to be used to test.
        finalResult = true;

        returnString = new StringBuilder();

        // Com 1 and 2 will be communicating to each other and Com 3 and 4 will be as well
        try{
            writeReceiveTest(Com1, Com2, "Com1Out");

            if(pass){
                returnString.append("P");
            }else{
                returnString.append("F");
            }

            writeReceiveTest(Com2, Com1, "Com2Out");

            if(pass){
                returnString.append("P");
            }else{
                returnString.append("F");
            }

            //this code added instead of code in comment below.
            //we don't have ttyUSB2 and ttyUSB3 anymore.
            // in batch file we don't use this FF values
            returnString.append("F");
            returnString.append("F");

//            writeReceiveTest(Com3, Com4, "Com3Out");
//
//            if(pass){
//                returnString.append("P");
//            }else{
//                returnString.append("F");
//            }
//            writeReceiveTest(Com4, Com3, "Com4Out");
//
//            if(pass){
//                returnString.append("P");
//            }else{
//                returnString.append("F");
//            }

        }catch (FileNotFoundException e){
            Log.e(TAG, e.toString());
            finalResult = false;
            // Clear what is in the returnStringCurrently and set all to fail
            returnString = new StringBuilder();
            returnString.append("FFFF");
        }
    }

    /**
     * Used to test sending and receiving a string from the given output com port to the
     * given input com port. Will write to file with results for each step and also if there
     * are any errors.
     * @param fileToSendOutOf
     *      The string for the file name for the com port which you are sending out of
     * @param fileToReceiveIn
     *      The string for the file name for the com port which you are receiving in
     * @param inputString
     *      If "" then will use the text for the edittext, else will use to inputted string to send.
     */
    public String writeReceiveTest(final File fileToSendOutOf, final File fileToReceiveIn, final String inputString) throws FileNotFoundException {

        StringBuilder sentSB = new StringBuilder();
        StringBuilder readSB = new StringBuilder();
        resultStringBuilder = new StringBuilder();
        pass = true;

        inputStream = new FileInputStream(fileToReceiveIn);

        // Make sure to clear any previous sends so if there are available bytes then skip them.
        // This needs to finish before we start reading and writing.
        try{
            int available = inputStream.available();
            long skipped = inputStream.skip(available);
            //Log.i(TAG, "Bytes available: " + available + " | Bytes skipped: " + skipped);
        }catch (Exception e){
            Log.e(TAG, e.toString());
        }

        // Send the data
        try{
            FileOutputStream outputStream;

            // Set to whatever is inputted by the user
            outputStream = new FileOutputStream(fileToSendOutOf);

            String temp = inputString;

            // Code below used to add new line byte to bytesToSend
            byte[] originalWords = temp.getBytes();
            byte[] bytesToSend = new byte[originalWords.length + 1];

            for(int i = 0; i < originalWords.length; i++){
                bytesToSend[i] = originalWords[i];
            }

            bytesToSend[originalWords.length] = (byte) 10;

            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of " + fileToSendOutOf.getName() + ". String sent - \"" + temp + "\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            // Add newline char so when comparison is done between string sent and received they will be the same
            sentSB.append(temp);
            sentSB.append('\n');

            outputStream.close();

        }catch (Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            resultStringBuilder.append("Error writing from " + fileToSendOutOf.getName() + "\n");
            pass = false;
        }

        // After the data has been sent now try to read the data.
        try{
            sb = new StringBuilder();

            readBuffer = new byte [32];
            char[] bufferChar = new char [32];

            Callable<Integer> readTask = new Callable<Integer>() {
                @Override
                public Integer call() throws Exception {
                    return inputStream.read(readBuffer);
                }
            };

            ExecutorService executor = Executors.newFixedThreadPool(1);

            Future<Integer> future = executor.submit(readTask);
            // Give read two seconds to finish
            int bytesRead = future.get(2000, TimeUnit.MILLISECONDS);

            // Convert bytes to chars
            if(bytesRead > 0){
                for(int i = 0; i < bytesRead; i++){
                    bufferChar[i] = (char) readBuffer[i];
                    sb.append(bufferChar[i]);
                }
            }

            // Display resulting information
            Log.i(TAG, "Bytes read : " + bytesRead + " in " + fileToReceiveIn.getName() + ". String received - \"" + sb.toString().substring(0, sb.toString().length()-1) + "\"");
            Log.i(TAG, Arrays.toString(readBuffer));

            readSB.append(sb.toString());

            inputStream.close();

        }catch (TimeoutException e){
            Log.e(TAG, "Error reading in " + fileToReceiveIn .getName() + " | Read took longer than allowed time (2 seconds): Timeout" + e.toString());
            finalResult = false;
            try {
                inputStream.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
            resultStringBuilder.append("Error reading in " + fileToSendOutOf.getName() + " | Read took longer than allowed time (2 seconds): " + e.toString() + "\n");
            pass = false;
        }catch (Exception e){
            Log.e(TAG, "Error reading in " + fileToReceiveIn .getName() + ": " + e.toString());
            finalResult = false;
            try {
                inputStream.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }

            resultStringBuilder.append("Error reading in " + fileToSendOutOf.getName() + ": " + e.toString() + "\n");
            pass = false;
        }

        // Check to make sure that sent string is the same as the read string.
        // Then write to the file to results.
        Log.d("AAAA", "before if");
        if(readSB.toString().contains(sentSB.toString())){
            Log.d("AAAA", " if true");
            resultStringBuilder.append("SUCCESS: Data sent out of " + fileToSendOutOf.getName() + " was received in " + fileToReceiveIn.getName() + " correctly.\n");
        }else {
            Log.d("AAAA", "if false");
            finalResult = false;

            // Get strings without newline chars
            StringBuilder sent = new StringBuilder(sentSB.toString().substring(0, (sentSB.toString()).length()-1));

            StringBuilder read = new StringBuilder("");
            // Make sure the length of the string is greater than zero before you try to erase last char
            if(readSB.toString().length() > 0){
                read.append(readSB.toString().substring(0, (readSB.toString()).length()-1));
            }

            resultStringBuilder.append("FAILED: Data sent out of " + fileToSendOutOf.getName() + " was not received in " + fileToReceiveIn.getName() + " correctly. Sent - \"" + sent.toString() + "\" | Read - \"" + read.toString() + "\"\n");
            Log.e(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was not received in " + fileToReceiveIn.getName() + " correctly. Sent - \"" + sent.toString() + "\" | Read - \"" + read.toString() + "\"");
            pass = false;
        }
        return String.valueOf(resultStringBuilder);// resultStringBuilder.toString()
    }
}
