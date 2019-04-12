package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.os.SystemClock;
import android.util.Log;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by austin.oneil on 6/21/2017.
 */

public class GetAudioResultReceiver extends MicronetBroadcastReceiver {

    AtomicBoolean finished = new AtomicBoolean(false);
    MediaPlayer mp;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        final PendingResult pendingResult = goAsync();

        if (MainActivity.testToolLock.isUnlocked()) {
//         1 for left speaker
//         2 for right speaker
            final int speaker = intent.getIntExtra("speaker", 0);

            Log.i("AudioTest", "Broadcast received for audio test.");

            AudioManager audioManager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, (int) (audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC) * 1.0f), 0);

            mp = MediaPlayer.create(context, R.raw.flutey_phone);

            mp.setOnPreparedListener(new OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mp) {
                    mp.start();

                    try {
                        Thread.sleep(20);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    if(speaker == 1){
                        // Turn off the left speaker
                        runShellCommand("mctl api 0213001C00");
                    }else if(speaker == 2){
                        // Turn off the right speaker
                        runShellCommand("mctl api 0213000600");
                    }

                    try {
                        Thread.sleep(20);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    if(speaker == 1){
                        // Turn off the left speaker
                        runShellCommand("mctl api 0213001C00");
                    }else if(speaker == 2){
                        // Turn off the right speaker
                        runShellCommand("mctl api 0213000600");
                    }

                    try {
                        Thread.sleep(20);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                    if(speaker == 1){
                        // Turn off the left speaker
                        runShellCommand("mctl api 0213001C00");
                    }else if(speaker == 2){
                        // Turn off the right speaker
                        runShellCommand("mctl api 0213000600");
                    }

                    Log.d("AudioTest", "OnPrepared finished");
                }
            });

            mp.setOnCompletionListener(new OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mp) {
                    pendingResult.setResultCode(1);
                    Log.d("AudioTest", "OnComplete finished");
                    mp.release();
                    finished.set(true);
                    pendingResult.finish();
                }
            });

            mp.setOnErrorListener(new OnErrorListener() {
                @Override
                public boolean onError(MediaPlayer mp, int what, int extra) {
                    Log.e("AudioTest", "There was an error playing the audio.");
                    return false;
                }
            });

            new Thread(new Runnable() {
                @Override
                public void run() {
                    long startTime = SystemClock.elapsedRealtime();
                    while(SystemClock.elapsedRealtime() - startTime < 8000){
                        try {
                            Thread.sleep(50);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }

                    if(!finished.get()){
                        Log.e("AudioTest", "Not finished yet, finishing with an error");
                        finished.set(true);
                        mp.stop();
                        mp.release();
                        pendingResult.setResultCode(0);
                        pendingResult.finish();
                    }else{
                        Log.d("AudioTest", "Already finished");
                    }
                }
            }).start();
        }else{
            setResultCode(3);
            setResultData("F app locked");
        }
    }

    private void runShellCommand(String command) {
        try{
            String[] commands = command.split(" ");
            StringBuilder sb = new StringBuilder();

            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(Runtime.getRuntime().exec(commands).getInputStream()));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                sb.append(line);
            }

            bufferedReader.close();

            Log.i("AudioTest", sb.toString());
        }catch (Exception e){
            Log.e("AudioTest", e.toString());
        }
    }
}
