package com.micronet.obctesterboardapp;

import android.content.Intent;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "OBCTesterBoardApp";

    private SWCHandler swcHandler;
    private RS485Handler rs485Handler;
    private J1708Handler j1708Handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i(TAG, "Application started.");

        // Enable RS485
        enableRS485();

        // Start all the handlers
        //swcHandler =  new SWCHandler();
        //rs485Handler =  new RS485Handler();
        //j1708Handler = new J1708Handler();

        Intent startIntent = new Intent(getApplicationContext(), RS485Service.class);
        startService(startIntent);

        ToneGenerator toneGen = new ToneGenerator(AudioManager.STREAM_MUSIC, 70);
        toneGen.startTone(ToneGenerator.TONE_PROP_ACK);
        toneGen.release();
    }

    private void enableRS485() {
        try {
            String commands[] = {"system/bin/mctl", "api", "0213041b01"};
            Process process = Runtime.getRuntime().exec(commands);
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                Log.d(TAG, line);
            }
            Log.d(TAG, "RS485 Power Enabled.");
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            Log.e(TAG, "RS485 Power Not Enabled.");
        }
    }

    private void enableJ1708() {
        try {
            String commands[] = {"system/bin/mctl", "api", "02fc01"};
            Process process = Runtime.getRuntime().exec(commands);
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                Log.d(TAG, line);
            }
            Log.d(TAG, "J1708 Power Enabled.");
        } catch (IOException e) {
            Log.e(TAG, e.toString());
            Log.e(TAG, "J1708 Power Not Enabled.");
        }
    }

    @Override
    protected void onStop() {
        super.onStop();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Stop Handlers
//        swcHandler.stopSWCHandler();
//        rs485Handler.stopRS485Handler();
//        j1708Handler.stopJ1708Handler();

        // Disable RS485 and J1708
//        try {
//            String commands[] = {"system/bin/mctl", "api", "0213041b00"};
//            Process process = Runtime.getRuntime().exec(commands);
//            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
//            String line;
//            while ((line = bufferedReader.readLine()) != null) {
//                Log.d(TAG, line);
//            }
//            Log.d(TAG, "RS485 Power Disabled.");
//        } catch (IOException e) {
//            Log.e(TAG, e.toString());
//            Log.e(TAG, "RS485 Power Not Disabled.");
//        }

//        try {
//            String commands[] = {"system/bin/mctl", "api", "02fc00"};
//            Process process = Runtime.getRuntime().exec(commands);
//            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
//            String line;
//            while ((line = bufferedReader.readLine()) != null) {
//                Log.d(TAG, line);
//            }
//            Log.d(TAG, "J1708 Power Disabled.");
//        } catch (IOException e) {
//            Log.e(TAG, e.toString());
//            Log.e(TAG, "J1708 Power Not Disabled.");
//        }
    }
}
