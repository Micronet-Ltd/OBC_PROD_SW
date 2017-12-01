package com.micronet.obctestingapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "OBCTestingApp";
    public static GPS gps = null;

    /**
     * Start the app and then the app will do nothing until there are broadcasts for certain tests.
     * It's important to note that generally a result code of 1 means pass for the test, a result code of 2 means fail for a test,
     * and 0 means either the app was not installed or it was not started.
     * @param savedInstanceState
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Start GPS listening
        gps = new GPS(this.getApplicationContext());
    }

}
