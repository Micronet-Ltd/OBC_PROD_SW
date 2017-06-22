package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.SoundPool;

import java.io.IOException;

/**
 * Created by austin.oneil on 6/21/2017.
 */

public class GetAudioResultReceiver extends MicronetBroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        AudioManager audioManager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC), 0);
        SoundPool sp = new SoundPool(5, AudioManager.STREAM_MUSIC, 0);
        sp.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId, int status) {
                soundPool.play(sampleId, 1f, 1f, 0, 0, 1);
            }
        });
        int track = R.raw.flutey_phone;
        sp.load(context, track, 1);
    }
}
