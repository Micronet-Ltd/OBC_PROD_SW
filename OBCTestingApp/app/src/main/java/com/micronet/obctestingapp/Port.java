package com.micronet.obctestingapp;

import android.util.Log;

import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * Created by scott.krstyen on 5/3/2017.
 */

public class Port {

    private final String TAG = "OBCTestingApp";

    public FileOutputStream outputStream;

    private FileDescriptor mFd;

    static {
        System.loadLibrary("native-lib");
    }

    private native static FileDescriptor open(String path, int Baudrate);
    private native void close();

    public Port(String file){
        // Open the port and get the file descriptor
        mFd = open(file, 115200);

        // Make a new FileOutputStream to be used with the descriptor
        outputStream = new FileOutputStream(mFd);
    }

    public void closePort(){

        // First close output stream
        try {
            outputStream.close();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
        }

        // Then close file descriptor
        close();

    }

}
