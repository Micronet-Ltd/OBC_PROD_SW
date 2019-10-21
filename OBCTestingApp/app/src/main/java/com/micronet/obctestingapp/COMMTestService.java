package com.micronet.obctestingapp;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class COMMTestService extends Service {
    public COMMTestService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
