package com.micronet.obctestingapp;

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
 * Runs an automated J1708 test and returns the result.
 *
 * Modified by scott.krstyen on 8/17/2017.
 */
public class GetJ1708ResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder sb;
    private StringBuilder returnString;
    // Use these instead of ttyACM4 because then there won't be conflicts with rild
    private File J1708_write = new File("/dev/ttyMICRONET_J1708");
    private File J1708_read = new File("/dev/j1708");

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
        if (MainActivity.testToolLock.isUnlocked()) {
            // Runs an automated J1708 test.
            automatedJ1708Test();

            // Depending on test result returns a result.
            if(finalResult){
                Log.i(TAG, "*** J1708 Test Passed ***");
                setResultCode(1);
                setResultData(returnString.toString());
            }else{
                Log.i(TAG, "*** J1708 Test Failed ***");
                setResultCode(2);
                setResultData(returnString.toString());
            }
        }else{
            setResultCode(3);
            setResultData("F app locked");
        }

    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Automated J1708 test.
     */
    public void automatedJ1708Test(){

        Log.i(TAG, "*** J1708 Test Started ***");

        finalResult = true;

        returnString = new StringBuilder();

        //mFd = open("/dev/ttyACM4", 115200);
        mFd = open("/dev/ttyMICRONET_J1708", 115200);
        close();

        try{
            writeReceiveTest(J1708_write, J1708_read);

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

    /**
     * Used to test sending and receiving a string with J1708 (/dev/ttyACM4). Will write to file with results for each step and also if there
     * are any errors.
     * @param fileToSendOutOf
     *      The file to send out of
     * @param fileToReceiveIn
     *      The file to receive in
     */
    public String writeReceiveTest(final File fileToSendOutOf, final File fileToReceiveIn) throws FileNotFoundException {

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

            // Sending "~1j1708(checksum)~"
            byte[] bytesToSend = {(byte)0x7e,(byte)0x31,(byte)0x6a,(byte)0x31,(byte)0x37,(byte)0x30,(byte)0x38,(byte)0x95,(byte)0x7e};

            // Write bytes to /dev/ttyMICRONET_J1708
            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of " + fileToSendOutOf.getName() + ". String sent - \"j1708\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            sentSB.append("j1708");

            outputStream.close();

        }catch (Exception e){
            Log.e(TAG, e.toString());
            finalResult = false;
            pass = false;
        }

        try{
            Thread.sleep(1000);
        }catch(Exception e){
            Log.e(TAG, e.toString());
        }

        // After the data has been sent now try to read the data.
        try{
            sb = new StringBuilder();

            readBuffer = new byte [128];
            char[] bufferChar = new char [128];

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

        // Check to make sure that sent string contains j1708 characters.
        if(readSB.toString().contains("j1708")){
            Log.i(TAG, "Data sent out of " + fileToSendOutOf.getName() + " was received in " + fileToReceiveIn.getName() + " successfully.");
            // (used to write to the file here, but don't need to anymore since the app uses a broadcast)
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
        return String.valueOf(pass);
    }
}
