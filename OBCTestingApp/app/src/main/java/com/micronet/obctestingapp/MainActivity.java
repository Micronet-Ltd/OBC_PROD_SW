package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "OBCTestingApp";
    public static GPS gps = null;
    public static TestToolLock testToolLock = new TestToolLock();

    /**
     * Start the app and then the app will do nothing until there are broadcasts for certain tests. It's important to note that generally a result
     * code of 1 means pass for the test, a result code of 2 means fail for a test, and 0 means either the app was not installed or it was not
     * started.
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Start GPS listening
      //  gps = new GPS(this.getApplicationContext());

        BroadcastReceiver getIMEIReceiver = new GetIMEIReceiver();
        this.registerReceiver(getIMEIReceiver, new IntentFilter("com.micronet.obctestingapp.GET_IMEI"));

        BroadcastReceiver getSerialReceiver = new GetSerialReceiver();
        this.registerReceiver(getSerialReceiver, new IntentFilter("com.micronet.obctestingapp.GET_SERIAL"));

        BroadcastReceiver getComPortResultReceiver = new GetComPortResultReceiver();
        this.registerReceiver(getComPortResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_COM_RESULT"));

        BroadcastReceiver getCanBusResultReceiver = new GetCanBusResultReceiver();
        this.registerReceiver(getCanBusResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_CAN_RESULT"));

        BroadcastReceiver getSingleWireCanResultReceiver = new GetSingleWireCanResultReceiver();
        this.registerReceiver(getSingleWireCanResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_SWC_RESULT"));

        BroadcastReceiver getJ1708ResultReceiver = new GetJ1708ResultReceiver();
        this.registerReceiver(getJ1708ResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_J1708_RESULT"));

        BroadcastReceiver getGPIOResultReceiver = new GetGPIOResultReceiver();
        Handler handler; // Handler for the separate Thread
        HandlerThread handlerThread = new HandlerThread("GPIOThread");
        handlerThread.start();
        Looper looper = handlerThread.getLooper();
        handler = new Handler(looper);
        registerReceiver(getGPIOResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_GPIO_RESULT"), null, handler);

        BroadcastReceiver getAccelerometerResultReceiver = new GetAccelerometerResultReceiver();
        this.registerReceiver(getAccelerometerResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_ACCEL_RESULT"));

        BroadcastReceiver getAudioResultReceiver = new GetAudioResultReceiver();
        this.registerReceiver(getAudioResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_AUDIO_RESULT"));

        BroadcastReceiver getGPSResultReceiver = new GetGPSResultReceiver();
        this.registerReceiver(getGPSResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_GPS_RESULT"));

        BroadcastReceiver getRS485ResultReceiver = new GetRS485ResultReceiver();
        this.registerReceiver(getRS485ResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_RS485_RESULT"));

        BroadcastReceiver getSettingsResultReceiver = new GetSettingsResultReceiver();
        this.registerReceiver(getSettingsResultReceiver, new IntentFilter("com.micronet.obctestingapp.GET_SETTINGS_RESULT"));

        BroadcastReceiver checkUnlockHashReceiver = new CheckUnlockHashReceiver();
        this.registerReceiver(checkUnlockHashReceiver, new IntentFilter("com.micronet.obctestingapp.CHECK_UNLOCK_HASH"));

        BroadcastReceiver getUnlockHashReceiver = new GetUnlockHashReceiver();
        this.registerReceiver(getUnlockHashReceiver, new IntentFilter("com.micronet.obctestingapp.GET_UNLOCK_HASH"));

    }

}
