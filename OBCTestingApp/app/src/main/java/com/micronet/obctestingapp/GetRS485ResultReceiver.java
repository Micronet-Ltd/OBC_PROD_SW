package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Runs an automated RS485 test and returns the result.
 */
public class GetRS485ResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";
    private StringBuilder sb;
    private StringBuilder returnString;
    private File RS485 = new File("/dev/ttyUSB1");
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
        super.onReceive(context, intent);
        // Runs an automated RS485 test.
        automatedRS485Test();

        // Depending on test result returns a result.
        if(finalResult){
            Log.i(TAG, "*** RS485 Test Passed ***");
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            Log.i(TAG, "*** RS485 Test Failed ***");
            setResultCode(2);
            setResultData(returnString.toString());
        }

    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Automated RS485 test.
     */
    public void automatedRS485Test(){

        if (MainActivity.testToolLock.isUnlocked()) {

            Log.i(TAG, "*** RS485 Test Started ***");

            finalResult = true;
            returnString = new StringBuilder();

            mFd = open("/dev/ttyUSB1", 115200);
            close();

            try{

                String strToSend = "123456789#";

                for(int i = 0; i < strToSend.length(); i++){
                    if(!writeReceiveTest(RS485, RS485, strToSend.substring(i, i+1))){
                        returnString.append("F");
                        break;
                    }

                    Thread.sleep(100);
                }

                if(finalResult){
                    returnString.append("P");
                }

            }catch (Exception e){
                Log.e(TAG, e.toString());
                finalResult = false;
                // Clear what is in the set all to fail
                returnString = new StringBuilder();
                returnString.append("F");
            }

        }else{
            setResultCode(3);
            setResultData("F app locked");
        }

    }

    public boolean writeReceiveTest(final File fileToSendOutOf, final File fileToReceiveIn, String byteToSend) throws FileNotFoundException {

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
            inputStream.close();
        }catch (Exception e){
            Log.e(TAG, e.toString());
        }

        // Send the data
        try{
            FileOutputStream outputStream = new FileOutputStream(fileToSendOutOf);

            // Write bytes to /dev/ttyUSB1
            outputStream.write(byteToSend.getBytes());

            // Display information
            Log.i(TAG, "Bytes sent : " + byteToSend.length() + " out of " + fileToSendOutOf.getName() + ". String sent - \""+byteToSend+"\"");
            Log.i(TAG, byteToSend);

            sentSB.append(byteToSend);

            outputStream.flush();
            outputStream.close();
        }catch (Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            pass = false;
        }

        // After the data has been sent now try to read the data.
        try{
            inputStream = new FileInputStream(fileToReceiveIn);

            sb = new StringBuilder();

            readBuffer = new byte[1];
            char[] bufferChar = new char[1];

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
            int bytesRead = future.get(1000, TimeUnit.MILLISECONDS);

            // Convert bytes to chars
            if(bytesRead > 0){
                for(int i = 0; i < bytesRead; i++){
                    bufferChar[i] = (char) readBuffer[i];
                    sb.append(bufferChar[i]);
                }
            }

            // Display resulting information
            Log.i(TAG, "Bytes read : " + bytesRead + " in " + fileToReceiveIn.getName() + ". String received - \"" + sb.toString() + "\"");
            Log.i(TAG, Arrays.toString(readBuffer));

            readSB.append(sb.toString());

            executor.shutdownNow();

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

        // Check to make sure that sent string contains the correct byte.
        if(readSB.toString().equals(byteToSend)){
            Log.i(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was received in " + fileToReceiveIn.getName() + " successfully.");
        }else {
            finalResult = false;
            pass = false;

            StringBuilder sent = new StringBuilder(sentSB.toString());

            StringBuilder read = new StringBuilder("");
            if(readSB.toString().length() > 0){
                read.append(readSB.toString());
            }

            Log.e(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was not received in " + fileToReceiveIn.getName() + " correctly. Sent - \"" + sent.toString() + "\" | Read - \"" + read.toString() + "\"");
        }

        // Only return whether the test passed or failed.
        return pass;
    }
}
