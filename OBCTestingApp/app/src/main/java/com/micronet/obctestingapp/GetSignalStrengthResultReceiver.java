package com.micronet.obctestingapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import android.telephony.CellInfo;
import android.telephony.CellInfoCdma;
import android.telephony.CellInfoGsm;
import android.telephony.CellInfoLte;
import android.telephony.CellInfoWcdma;
import android.telephony.TelephonyManager;
import android.util.Log;

import java.util.List;

import static android.content.Context.TELEPHONY_SERVICE;

/**
 * Created by scott.krstyen on 8/11/2017.
 */

public class GetSignalStrengthResultReceiver extends BroadcastReceiver {

    private final String TAG = "OBCTestingApp";

    TelephonyManager telephonyManager;

    // Default fail values
    int asuLevel = -200;
    int dbmLevel = -200;

    @Override
    public void onReceive(Context context, Intent intent) {
        telephonyManager = (TelephonyManager) context.getSystemService(TELEPHONY_SERVICE);

        int signalStrengthLowerBound = intent.getIntExtra("SigLower", 1000);
        int signalStrengthUpperBound = intent.getIntExtra("SigUpper", 1000);
        int rssiLowerBound = intent.getIntExtra("RSSILower", 1000);

        Log.d(TAG, "Signal Strength Lower: " + signalStrengthLowerBound + " Signal Strength Upper: " + signalStrengthUpperBound + " RSSI Lower Bound: " + rssiLowerBound);

        List<CellInfo> cellInfoList = telephonyManager.getAllCellInfo();
        for (CellInfo cellInfo : cellInfoList)
        {
            if (cellInfo.isRegistered()) {
                if (cellInfo instanceof  CellInfoCdma){
                    asuLevel = ((CellInfoCdma)cellInfo).getCellSignalStrength().getAsuLevel();
                    dbmLevel = ((CellInfoCdma)cellInfo).getCellSignalStrength().getDbm();
                } else if (cellInfo instanceof  CellInfoWcdma){
                    asuLevel = ((CellInfoWcdma)cellInfo).getCellSignalStrength().getAsuLevel();
                    dbmLevel = ((CellInfoWcdma)cellInfo).getCellSignalStrength().getDbm();
                } else if (cellInfo instanceof  CellInfoGsm){
                    asuLevel = ((CellInfoGsm)cellInfo).getCellSignalStrength().getAsuLevel();
                    dbmLevel = ((CellInfoGsm)cellInfo).getCellSignalStrength().getDbm();
                } else if (cellInfo instanceof  CellInfoLte){
                    asuLevel = ((CellInfoLte)cellInfo).getCellSignalStrength().getAsuLevel();
                    dbmLevel = ((CellInfoLte)cellInfo).getCellSignalStrength().getDbm();
                }

            }
        }

        if(signalStrengthUpperBound == 0){
            Log.d(TAG,"Signal Strength Input Value is 0. Only testing RSSI");
            if(dbmLevel == -200){
                Log.e(TAG, "Could not get dbm value. Default is -200. dBm value: " + dbmLevel);
                setResultCode(3);
                setResultData(asuLevel + "," + dbmLevel);
            }
        }else{
            if(asuLevel == -200 || dbmLevel == -200){
                Log.e(TAG, "Could not get asu or dbm value. Default is -200. asu value: " + asuLevel + " dBm value: " + dbmLevel);
                setResultCode(3);
                setResultData(asuLevel + "," + dbmLevel);
            }
        }


        Log.d(TAG, "Current ASU: " + asuLevel + " DBM: " + dbmLevel);

        if(signalStrengthUpperBound != 0){
            if(asuLevel > signalStrengthLowerBound && asuLevel < signalStrengthUpperBound && dbmLevel > rssiLowerBound){
                Log.i(TAG, "********* Signal Test Passed *********");
                setResultCode(1);
                setResultData(asuLevel + "," + dbmLevel);
            }else{
                Log.i(TAG, "********* Signal Test Failed *********");
                setResultCode(2);
                setResultData(asuLevel + "," + dbmLevel);
            }
        }else{

            if(dbmLevel > rssiLowerBound){

                Log.i(TAG, "********* Signal Test Passed *********");
                setResultCode(1);
                setResultData(asuLevel + "," + dbmLevel + ",");
            }else{
                Log.i(TAG, "********* Signal Test Failed *********");
                setResultCode(2);
                setResultData(asuLevel + "," + dbmLevel + ",");
            }
        }
    }
}
