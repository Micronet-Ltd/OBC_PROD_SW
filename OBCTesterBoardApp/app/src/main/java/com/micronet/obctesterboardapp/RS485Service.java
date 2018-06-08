package com.micronet.obctesterboardapp;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.support.v4.app.NotificationCompat;

public class RS485Service extends Service {

    private final String TAG = "OBCTesterBoardApp";
    public static boolean isServiceRunning = false;
    private static RS485Handler rs485Handler;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        startRS485HandlerWithNotification();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(intent != null){
            startRS485HandlerWithNotification();
        }

        return START_STICKY;
    }

    private void startRS485HandlerWithNotification() {
        // If service is already running then do nothing
        if(isServiceRunning){
            return;
        }

        isServiceRunning = true;

        rs485Handler = new RS485Handler();

        Notification notification = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_action_name)
                .setContentTitle(getResources().getString(R.string.app_name))
                .setContentText("RS485 Handler is running. Will receive one byte and return it.")
                .setOngoing(true)
                .build();

        notification.flags = notification.flags | Notification.FLAG_NO_CLEAR;
        startForeground(777, notification);
    }


    @Override
    public void onDestroy() {
        isServiceRunning = false;
        super.onDestroy();
    }

    public void stopService(){
        stopForeground(true);
        stopSelf();
        isServiceRunning = false;
    }
}
