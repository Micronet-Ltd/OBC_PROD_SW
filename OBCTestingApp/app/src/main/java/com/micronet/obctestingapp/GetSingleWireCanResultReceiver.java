package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.File;
import java.io.FileDescriptor;
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
 * Created by scott.krstyen on 4/19/2017.
 */

/**
 * Runs an automated SWC test and returns the result.
 */
public class GetSingleWireCanResultReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder sb;
    private StringBuilder returnString;
    private File Can1 = new File("/dev/ttyACM3");

    private boolean finalResult = true;
    private boolean pass;

    private byte[] readBuffer;

    private FileInputStream inputStream;

    private FileDescriptor mFd;

    static {
        System.loadLibrary("native-lib");
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        // Run automated test
        automatedSingleWireCanTest();

        // Depending on test result return result
        if(finalResult){
            Log.i(TAG, "*** SWC Test Passed ***");
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            Log.i(TAG, "*** SWC Test Failed ***");
            setResultCode(2);
            setResultData(returnString.toString());
        }

    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Automated SWC test.
     */
    public void automatedSingleWireCanTest(){

        Log.i(TAG, "*** SWC Test Started ***");

        // Set initial value to true
        finalResult = true;

        returnString = new StringBuilder();

        try{
            setUpSWC();
        }catch (Exception e){
            Log.e(TAG, e.toString());
        }

        try{
            writeReceiveTest(Can1, Can1, "t7E08103456789abcdef0\r");

            if(pass){
                returnString.append("P");
            }else{
                returnString.append("F");
            }

        }catch (Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            // Clear what is in the returnStringCurrently and set all to fail
            returnString = new StringBuilder();
            returnString.append("F");
        }
    }

    private void setUpSWC() throws Exception {

        // **** Set Up SWC ****

        mFd = open("/dev/ttyACM3", 115200);

        FileOutputStream output = new FileOutputStream(mFd);

        output.write("C\r".getBytes());
        output.write("mt00000100\r".getBytes());
        output.write("Mt00000700\r".getBytes());
        output.write("S2\r".getBytes()); // Sets the baud rate to 33.3 (this is what makes it single wire can)
        output.write("O1\r".getBytes());

        Thread.sleep(1000);

        output.flush();
        output.close();

        Log.d(TAG,"SWC Configured (/dev/ttyACM3)");

        close();
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

        // The string that is sent
        StringBuilder sentSB = new StringBuilder();
        // The string that is received
        StringBuilder readSB = new StringBuilder();

        // Result of individual writeReceiveTest
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


            String stringToSend = inputString;

            // Get bytes from string to send
            byte[] bytesToSend = stringToSend.getBytes();

            // Send bytes
            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of " + fileToSendOutOf.getName() + ". String sent - \"" + stringToSend + "\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            // Remove \r from stringToSend.
            sentSB.append(stringToSend);
            sentSB.deleteCharAt(sentSB.length()-1);
            outputStream.close();

        }catch (Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            pass = false;
        }



        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Log.e(TAG, e.toString());
        }



        // After the data has been sent now try to read the data.
        try{
            sb = new StringBuilder();

            readBuffer = new byte [32];
            char[] bufferChar = new char [32];

            // Using a callable and a future allows the app to read, but not block indefinitely if there is nothing to read,
            // (for example if canbus wires don't send or receive the data properly).
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
            Log.e(TAG, "Error reading in " + fileToReceiveIn.getName() + " | Read took longer than allowed time (2 seconds): Timeout" + e.toString());
            finalResult = false;
            pass = false;

            try {
                inputStream.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }catch (Exception e){
            Log.e(TAG, "Error reading in " + fileToReceiveIn.getName() + ": " + e.toString());
            finalResult = false;
            pass = false;

            try {
                inputStream.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }

        // Check to make sure that sent string contains t7e880102030405060708.
        // The test board will return a bytes that include that string above so that is how you know you have received a successful result.
        // Example:
        //      Sent: t7E08103456789abcdef0\r
        //      Read: t7e88010203040506070879EF\r
        if(readSB.toString().toLowerCase().contains("t7e880102030405060708")){
            Log.i(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was received in " + fileToReceiveIn.getName() + " successfully.");
            // (used to write to the file here, but don't need to anymore since the app uses a broadcast)
        }else {
            finalResult = false;
            pass = false;

            // Get strings without newline chars
            StringBuilder sent = new StringBuilder(sentSB.toString().substring(0, (sentSB.toString()).length()-1));

            StringBuilder read = new StringBuilder("");
            // Make sure the length of the string is greater than zero before you try to erase last char
            if(readSB.toString().length() > 0){
                read.append(readSB.toString().substring(0, (readSB.toString()).length()-1));
            }

            Log.e(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was not received in " + fileToReceiveIn.getName() + " correctly. Sent - \"" + sent.toString() + "\" | Read - \"" + read.toString() + "\"");

        }

        // Only return whether the test passed or failed.
        return String.valueOf(pass);
    }


}
