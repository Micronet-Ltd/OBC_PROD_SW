package com.micronet.obctestingapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.io.FileDescriptor;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "OBCTestingApp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        GetSingleWireCanResultReceiver temp = new GetSingleWireCanResultReceiver();
        temp.automatedSingleWireCanTest();
    }

}
