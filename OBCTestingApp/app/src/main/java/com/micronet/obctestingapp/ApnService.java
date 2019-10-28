package com.micronet.obctestingapp;

import android.app.IntentService;
import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Intent;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.Telephony;
import android.text.TextUtils;
import android.util.Log;

import java.util.Arrays;

public class ApnService extends IntentService {
    private static final String TAG = "ApnService";
    private static final String ACTION_SET_APN = "com.micronet.obctestingapp.action.SET_APN";

    private static final String EXTRA_APN = "apn";
    private static final String EXTRA_MCC = "mcc";
    private static final String EXTRA_MNC = "mnc";
    private static final String EXTRA_NAME = "name";

    public ApnService() {
        super("ApnService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Log.d(TAG, "Received intent.");

        if (intent != null) {
            final String action = intent.getAction();
            if (ACTION_SET_APN.equals(action)) {
                final String apn = intent.getStringExtra(EXTRA_APN);
                final String mcc = intent.getStringExtra(EXTRA_MCC);
                final String mnc = intent.getStringExtra(EXTRA_MNC);
                final String name = intent.getStringExtra(EXTRA_NAME);

                Log.d(TAG, "Intent extras: " + apn + ", " + name + ", " + mcc + ", " + mnc);

                if (!TextUtils.isEmpty(apn) && !TextUtils.isEmpty(mcc) && !TextUtils.isEmpty(mnc) && !TextUtils.isEmpty(name)) {
                    setApn(apn, mcc, mnc, name);
                } else {
                    Log.e(TAG, "All extras are not valid to set new apn.");
                }
            }
        }
    }

    private void setApn(String apn, String mcc, String mnc, String name) {

        final ContentResolver contentResolver = this.getContentResolver();
        ContentValues contentValues = new ContentValues();
        contentValues.put(Telephony.Carriers.APN, apn);
        contentValues.put(Telephony.Carriers.NAME, name);
        contentValues.put(Telephony.Carriers.MNC, mnc);
        contentValues.put(Telephony.Carriers.MCC, mcc);
        contentValues.put(Telephony.Carriers.NUMERIC, mcc+mnc);
        contentValues.put(Telephony.Carriers.TYPE, "default,sulp");

        Cursor cursor = contentResolver.query(Telephony.Carriers.CONTENT_URI, null, "name='" + name + "'", null, null);
        if (cursor != null && cursor.getCount() > 0) {
            int count = cursor.getCount();
            Log.d(TAG, "Cursor count: " + count);

            if (count > 1) {
                Log.e(TAG, "More than one apn found: " + count);
            }

            cursor.moveToFirst();
            String id = cursor.getString(0);
            Log.d(TAG, "Id of apn: " + id);

            contentResolver.update(Telephony.Carriers.CONTENT_URI, contentValues, "name='" + name + "'", null);

            ContentValues preferredValues = new ContentValues();
            preferredValues.put("apn_id", id);
            contentResolver.insert(Uri.parse("content://telephony/carriers/preferapn"), preferredValues);
            cursor.close();
            Log.d(TAG, "Updated apn.");
        } else {
            contentResolver.insert(Telephony.Carriers.CONTENT_URI, contentValues);

            cursor = contentResolver.query(Telephony.Carriers.CONTENT_URI, null, "name='" + name + "'", null, null);
            cursor.moveToFirst();
            String id = cursor.getString(0);
            Log.d(TAG, "Id of apn: " + id);

            ContentValues preferredValues = new ContentValues();
            preferredValues.put("apn_id", id);
            contentResolver.insert(Uri.parse("content://telephony/carriers/preferapn"), preferredValues);
            cursor.close();
            Log.d(TAG, "Added a new apn.");
        }
    }

}
