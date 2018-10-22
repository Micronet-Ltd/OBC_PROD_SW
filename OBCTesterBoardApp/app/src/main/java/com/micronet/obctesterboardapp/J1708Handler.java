package com.micronet.obctesterboardapp;

import android.content.Context;
import android.content.Intent;
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
 * Reads J1708 messages and returns the message.
 */
public class J1708Handler {

    private final String TAG = "OBCTesterBoardApp";

    private StringBuilder sb;

    private File J1708_write = new File("/dev/ttyMICRONET_J1708");
    private File J1708_read = new File("/dev/ttyMICRONET_J1708");

    private static boolean handleJ1708Boolean = false;
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

    public J1708Handler(){
        // Starting reading j1708 and returning j1708
        startJ1708Handler();
    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    /**
     * Start the J1708 handler
     */
    private void startJ1708Handler(){

        synchronized (lock){
            handleJ1708Boolean = true;
        }

        mFd = open("/dev/ttyMICRONET_J1708", 115200);
        close();

        try{
            new Thread(new Runnable() {
                @Override
                public void run() {
                    handleJ1708();
                }
            }).start();


        }catch (Exception e){
            Log.e(TAG, e.toString());
        }
    }

    public void stopJ1708Handler(){
        synchronized (lock){
            handleJ1708Boolean = false;
        }
    }

    private void handleJ1708(){

        Log.i(TAG, "J1708 Handler Started");

        boolean continueLoop = true;

        while(continueLoop){

            dataToWrite = false;
            sentSB = new StringBuilder();
            readSB = new StringBuilder();

            // Open the input and output stream
            try {
                inputStream = new FileInputStream(J1708_read);
                outputStream = new FileOutputStream(J1708_write);
            } catch (FileNotFoundException e) {
                Log.e(TAG, e.toString());
                synchronized (lock){
                    handleJ1708Boolean = false;
                }
                break;
            }

            // Read data
            dataToWrite = readJ1708();

            // If data to write then write data out of J1708
            if(dataToWrite){
                // Write data out of j1708
                writeJ1708();
            }else{
                try {
                    inputStream.close();
                    outputStream.close();
                } catch (IOException e1) {
                    Log.e(TAG, e1.toString());
                }
                Log.e(TAG, "No data read in, so no data to write out.");
            }

            // Sleep 0.1 second before reading again
            try {
                Thread.sleep(AppSettings.J1708_TIMEOUT);
            } catch (InterruptedException e) {
                Log.e(TAG, e.toString());
            }

            synchronized (lock){
                continueLoop = handleJ1708Boolean;
            }
        }

        try {
            inputStream.close();
            outputStream.close();
        } catch (IOException e) {
            Log.d(TAG, e.toString());
        }

        Log.i(TAG, "J1708 Handler Stopped");
    }

    private void writeJ1708() {
        // Send the data
        try{
            // Sending "~1j1708(checksum)~"
            byte[] bytesToSend = {(byte)0x7e,(byte)0x31,(byte)0x6a,(byte)0x31,(byte)0x37,(byte)0x30,(byte)0x38,(byte)0x95,(byte)0x7e};

            // Write bytes to /dev/ttyMICRONET_J1708
            outputStream.write(bytesToSend);

            // Display information
            Log.i(TAG, "Bytes sent : " + bytesToSend.length + " out of /dev/ttyMICRONET_J1708. String sent - \"j1708\"");
            Log.i(TAG, Arrays.toString(bytesToSend));

            outputStream.close();
        }catch (Exception e){
            Log.e(TAG, e.toString());
            synchronized (lock){
                handleJ1708Boolean = false;
            }
        }
    }

    private boolean readJ1708() {

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
            int bytesRead = future.get(AppSettings.J1708_READ_TIMEOUT, TimeUnit.MILLISECONDS);

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
            Log.i(TAG, "Bytes read : " + bytesRead + " in /dev/j1708. String received - \"" + sb.toString() + "\"");
            Log.i(TAG, Arrays.toString(readBuffer));

            readSB.append(sb.toString());

            executor.shutdownNow();

            inputStream.close();

        }catch (TimeoutException e){
            Log.e(TAG, "Error reading in /dev/j1708 | Read took longer than allowed time (2 seconds): Timeout" + e.toString());

            executor.shutdownNow();
            try {
                inputStream.close();
            } catch (IOException e1) {
                Log.e(TAG, e1.toString());
            }

            dataToWrite = false;
        }catch (Exception e){
            Log.e(TAG, "Error reading in /dev/j1708: " + e.toString());

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
