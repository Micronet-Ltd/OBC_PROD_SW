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

public class GetJ1708ResultReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    private StringBuilder sb;
    private StringBuilder returnString;
    private File J1708 = new File("/dev/ttyACM4");

    private boolean finalResult = true;
    private boolean pass;

    private byte[] readBuffer;

    private FileInputStream inputStream;

    private File Dir;

    private FileDescriptor mFd;

    static {
        System.loadLibrary("native-lib");
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        automatedJ1708Test();

        if(finalResult){
            setResultCode(1);
            setResultData(returnString.toString());
        }else{
            setResultCode(2);
            setResultData(returnString.toString());
        }

    }


    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    public void automatedJ1708Test(){

        finalResult = true;

        returnString = new StringBuilder();

        // Enable j1708 power
        // adb shell "mctl api 02fc01"
        // adb shell mctl api 0213020001

        mFd = open("/dev/ttyACM4", 115200);
        close();

        try{
            writeReceiveTest(J1708, J1708);

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
     * Used to test sending and receiving a string from the given output com port to the
     * given input com port. Will write to file with results for each step and also if there
     * are any errors.
     * @param fileToSendOutOf
     *      The string for the file name for the com port which you are sending out of
     * @param fileToReceiveIn
     *      The string for the file name for the com port which you are receiving in
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
            Log.i(TAG, "Bytes available: " + available + " | Bytes skipped: " + skipped);
        }catch (Exception e){
            Log.e(TAG, e.toString());
        }

        // Send the data
        try{
            FileOutputStream outputStream;

            // Set to whatever is inputted by the user
            outputStream = new FileOutputStream(fileToSendOutOf);

            // Get bytes from string to send
            byte[] bytesToSend = {(byte)0x7e,(byte)0x31,(byte)0x6a,(byte)0x31,(byte)0x37,(byte)0x30,(byte)0x38,(byte)0x95,(byte)0x7e};

            // Write bytes to /dev/ttyACM4
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

        // Don't add in a wait because when I did, it stopped receiving the data.
        // When I got rid of the wait it received the data.

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
            int bytesRead = future.get(3000, TimeUnit.MILLISECONDS);

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

            inputStream.close();

        }catch (TimeoutException e){
            Log.e(TAG, "Error reading in " + fileToReceiveIn.getName() + " | Read took longer than allowed time (3 seconds): Timeout" + e.toString());
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
        // I am sure there is an easier way to do this but this works for now.
        if(readSB.toString().contains("j") && readSB.toString().contains("1") && readSB.toString().contains("7") && readSB.toString().contains("0") && readSB.toString().contains("8")){
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
