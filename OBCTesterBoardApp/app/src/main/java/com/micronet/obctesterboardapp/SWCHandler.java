package com.micronet.obctesterboardapp;

import android.media.AudioManager;
import android.media.ToneGenerator;
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
 * Reads SWC messages and returns the message.
 */
public class SWCHandler {

    private final String TAG = "OBCTesterBoardApp";

    private StringBuilder sb;

    private File Can1 = new File("/dev/ttyACM3");

    private static boolean handleSWCBoolean = false;
    private byte[] readBuffer;

    private FileInputStream inputStream;
    private FileOutputStream outputStream;

    private StringBuilder sentSB;
    private StringBuilder readSB;

    private boolean dataToWrite;

    private FileDescriptor mFd;

    private final static Object lock = new Object();

    static {
        System.loadLibrary("native-lib");
    }

    public SWCHandler(){
        // Starting reading SWC and returning SWC
        startSWCHandler();
    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Start the SWC handler
     */
    private void startSWCHandler(){

        synchronized (lock){
            handleSWCBoolean = true;
        }

        try{
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
        }catch(Exception e){
            Log.e(TAG, e.toString());
            synchronized (lock){
                handleSWCBoolean = false;
            }
        }

        if(handleSWCBoolean){
            try{
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        handleSWC();
                    }
                }).start();
            }catch (Exception e){
                Log.e(TAG, e.toString());
            }
        }
    }

    public void stopSWCHandler(){
        synchronized (lock){
            handleSWCBoolean = false;
        }
    }

    private void handleSWC(){

        Log.i(TAG, "SWC Handler Started");

        boolean continueLoop = true;

        while(continueLoop){

            dataToWrite = false;
            sentSB = new StringBuilder();
            readSB = new StringBuilder();

            // Open the input and output stream
            try {
                inputStream = new FileInputStream(Can1);
                outputStream = new FileOutputStream(Can1);
            } catch (FileNotFoundException e) {
                Log.e(TAG, e.toString());
                synchronized (lock){
                    handleSWCBoolean = false;
                }
                break;
            }

            // Read data
            dataToWrite = readSWC();

            // If data to write then write data out of J1708
            if(dataToWrite){
                // Write data out of j1708
                writeSWC();

                try {
                    inputStream.close();
                    outputStream.close();
                } catch (IOException e1) {
                    Log.e(TAG, e1.toString());
                }
            }else{
                try {
                    inputStream.close();
                    outputStream.close();
                } catch (IOException e1) {
                    Log.e(TAG, e1.toString());
                }
                Log.e(TAG, "No data read in, so no data to write out.");
            }

            // Sleep 1 second before reading again
            try {
                Thread.sleep(AppSettings.SWC_TIMEOUT);
            } catch (InterruptedException e) {
                Log.e(TAG, e.toString());
            }

            synchronized (lock){
                continueLoop = handleSWCBoolean;
            }
        }

        try {
            inputStream.close();
            outputStream.close();
        } catch (IOException e) {
            Log.d(TAG, e.toString());
        }

        Log.i(TAG, "SWC Handler Stopped");
    }

    private void writeSWC() {
        // Send the data
        try{
            String strToSend = "t7e880102030405060708\r";

            // Get bytes to send
            byte[] bytesToSend = strToSend.getBytes();

            // Write bytes
            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of /dev/ttyACM3. String sent - \"t7e880102030405060708\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            outputStream.close();
        }catch (Exception e){
            Log.e(TAG, e.toString());
            synchronized (lock){
                handleSWCBoolean = false;
            }
        }
    }

    private boolean readSWC() {

        ExecutorService executor = Executors.newFixedThreadPool(1);

        // Read from the inputStream
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



            Future<Integer> future = executor.submit(readTask);
            // Give read two seconds to finish
            int bytesRead = future.get(AppSettings.SWC_READ_TIMEOUT, TimeUnit.MILLISECONDS);

            // Convert bytes to chars
            if(bytesRead > 0){

                ToneGenerator toneGen1 = new ToneGenerator(AudioManager.STREAM_MUSIC, 100);
                toneGen1.startTone(ToneGenerator.TONE_CDMA_PIP,150);

                dataToWrite = true;
                for(int i = 0; i < bytesRead; i++){
                    bufferChar[i] = (char) readBuffer[i];
                    sb.append(bufferChar[i]);
                }
            }

            // Display resulting information
            Log.i(TAG, "Bytes read : " + bytesRead + " in /dev/ttyACM3. String received - \"" + sb.toString() + "\"");
            Log.i(TAG, Arrays.toString(readBuffer));

            readSB.append(sb.toString());

            executor.shutdownNow();

            inputStream.close();

        }catch (TimeoutException e){
            Log.e(TAG, "Error reading in /dev/ttyACM3 | Read took longer than allowed time (2 seconds): Timeout" + e.toString());

            executor.shutdownNow();
            try {
                inputStream.close();
            } catch (IOException e1) {
                Log.e(TAG, e1.toString());
            }

            dataToWrite = false;
        }catch (Exception e){
            Log.e(TAG, "Error reading in /dev/ttyACM3: " + e.toString());

            executor.shutdownNow();
            try {
                inputStream.close();
            } catch (IOException e1) {
                Log.e(TAG, e1.toString());
            }

            dataToWrite = false;
        }

        return dataToWrite;
    }
}
