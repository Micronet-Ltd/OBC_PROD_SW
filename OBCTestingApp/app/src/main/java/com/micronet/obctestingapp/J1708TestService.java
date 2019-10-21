package com.micronet.obctestingapp;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class J1708TestService extends Service {
    public J1708TestService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
