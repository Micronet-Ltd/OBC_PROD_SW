package com.micronet.obctesterboardapp;

import android.media.AudioManager;
import android.media.ToneGenerator;
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
 * Reads RS485 messages and returns the message.
 */
public class RS485Handler {

    private final String TAG = "OBCTesterBoardApp";
    private StringBuilder sb;
    private File RS485 = new File("/dev/ttyUSB1");
    private static boolean handleRS485Boolean = false;
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

    public RS485Handler(){
        // Starting reading RS485 and returning RS485
        startRS485Handler();
    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Start the RS485 handler
     */
    private void startRS485Handler(){

        synchronized (lock){
            handleRS485Boolean = true;
        }

        mFd = open("/dev/ttyUSB1", 115200);
        close();

//        try {
//            String commands[] = {"system/bin/busybox", "stty", "-F", "/dev/ttyUSB1", "raw"};
//            Process process = Runtime.getRuntime().exec(commands);
//            String commands2[] = {"system/bin/busybox", "stty", "-F", "/dev/ttyUSB1", "115200"};
//            Process process2 = Runtime.getRuntime().exec(commands2);
//
//            Log.d(TAG, "Configured /dev/ttyUSB1.");
//        } catch (IOException e) {
//            Log.e(TAG, e.toString());
//            Log.e(TAG, "Couldn't configure /dev/ttyUSB1.");
//
//            synchronized (lock){
//                handleRS485Boolean = false;
//            }
//        }

        if(handleRS485Boolean){
            try{
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        handleRS485();
                    }
                }).start();
            }catch (Exception e){
                Log.e(TAG, e.toString());
            }
        }
    }

    public void stopRS485Handler(){
        synchronized (lock){
            handleRS485Boolean = false;
        }
    }

    private void handleRS485(){

        Log.i(TAG, "RS485 Handler Started");

        boolean continueLoop = true;

        while(continueLoop){

            dataToWrite = false;
            sentSB = new StringBuilder();
            readSB = new StringBuilder();

            // Open the input stream
            try {
                inputStream = new FileInputStream(RS485);
            } catch (FileNotFoundException e) {
                Log.e(TAG, e.toString());
                synchronized (lock){
                    handleRS485Boolean = false;
                }
                break;
            }

            // Try to read data
            dataToWrite = readRS485();

            // If data to write then write data out
            if(dataToWrite){
                try {
                    outputStream = new FileOutputStream(RS485);
                } catch (FileNotFoundException e) {
                    Log.e(TAG, e.toString());
                }
                // Write data out
                writeRS485();

                try {
                    outputStream.close();
                } catch (IOException e1) {
                    Log.e(TAG, e1.toString());
                }
            }else{
                try {
                    inputStream.close();
                } catch (IOException e1) {
                    Log.e(TAG, e1.toString());
                }
                Log.e(TAG, "No data read in, so no data to write out.");
            }

            // Sleep 1 second before reading again
            try {
                Thread.sleep(AppSettings.RS485_TIMEOUT);
            } catch (InterruptedException e) {
                Log.e(TAG, e.toString());
            }

            synchronized (lock){
                continueLoop = handleRS485Boolean;
            }
        }

        try {
            inputStream.close();
        } catch (IOException e) {
            Log.d(TAG, e.toString());
        }

        Log.i(TAG, "RS485 Handler Stopped");
    }

    private void writeRS485() {
        // Send the data
        try{

            // Get bytes to send
            byte[] bytesToSend = readBuffer;

            // Write bytes
            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of /dev/ttyUSB1. String sent - \""+(char)readBuffer[0]+"\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            outputStream.flush();
            outputStream.close();
        }catch (Exception e){
            Log.e(TAG, e.toString());
            synchronized (lock){
                handleRS485Boolean = false;
            }
        }
    }

    private boolean readRS485() {

        ExecutorService executor = Executors.newFixedThreadPool(1);

        // Read from the inputStream
        try{
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

            Future<Integer> future = executor.submit(readTask);
            // Give read two seconds to finish
            int bytesRead = future.get(AppSettings.RS485_READ_TIMEOUT, TimeUnit.MILLISECONDS);

            // Convert bytes to chars
            if(bytesRead > 0){

                ToneGenerator toneGen1 = new ToneGenerator(AudioManager.STREAM_MUSIC, 50);
                toneGen1.startTone(ToneGenerator.TONE_CDMA_PIP,150);
                toneGen1.release();

                dataToWrite = true;
                for(int i = 0; i < bytesRead; i++){
                    bufferChar[i] = (char) readBuffer[i];
                    sb.append(bufferChar[i]);
                }
            }

            // Display resulting information
            Log.i(TAG, "Bytes read : " + bytesRead + " in /dev/ttyUSB1. String received - \"" + sb.toString() + "\"");
            Log.i(TAG, Arrays.toString(readBuffer));

            readSB.append(sb.toString());

            executor.shutdownNow();

            inputStream.close();

        }catch (TimeoutException e){
            Log.e(TAG, "Error reading in /dev/ttyUSB1 | Read took longer than allowed time (2 seconds): Timeout" + e.toString());

            executor.shutdownNow();
            try {
                inputStream.close();
            } catch (IOException e1) {
                Log.e(TAG, e1.toString());
            }

            dataToWrite = false;
        }catch (Exception e){
            Log.e(TAG, "Error reading in /dev/ttyUSB1: " + e.toString());

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
