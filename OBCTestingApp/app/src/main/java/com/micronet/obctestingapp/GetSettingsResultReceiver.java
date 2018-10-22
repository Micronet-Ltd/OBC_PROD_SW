package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.Telephony;
import android.telephony.ServiceState;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.util.Log;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Settings test
 */
public class GetSettingsResultReceiver extends MicronetBroadcastReceiver {

    private final String TAG = "OBCTestingApp";
    HashMap<String,String> defaults;
    HashMap<String,String> failures;

    StringBuilder returnString;

    Context receiverContext;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (MainActivity.testToolLock.isUnlocked()) {
            receiverContext = context;
            returnString = new StringBuilder();

            loadDefaults();
            loadFailures();

            // Run test and check if any values failed
            if (settingsTest()) {
                setResultCode(1);
            } else {
                setResultCode(2);
            }

            setResultData(returnString.toString());
        }else{
            setResultCode(3);
            setResultData("F app locked");
        }
    }

    private boolean settingsTest() {
        boolean noFailures = true;

        ArrayList<String[]> data = getSettingsData();

        // CSV file format
        // Parameter, default value, current value, comparison boolean, modified?
        File csvFile = new File(receiverContext.getFilesDir().getAbsolutePath()+ "/settings.csv");

        if(csvFile.exists()) {
            csvFile.delete();
        }

        try {
            csvFile.createNewFile();

            // If there were failures then change result code later on
            if(!writeToCsvFile(data, csvFile)){
                noFailures = false;
            }
        } catch (IOException e) {
            Log.e(TAG, e.toString());
        }

        return noFailures;
    }

    private boolean writeToCsvFile(ArrayList<String[]> data, File csvFile) throws IOException {
        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(csvFile, true));

        boolean noFailures = true;
        returnString.append("\r\n");

        for(int i = 0; i < data.size(); i++){
            String parameter = data.get(i)[0];

            String defaultValue = "";
            if(defaults.containsKey(parameter)){
                defaultValue = defaults.get(parameter);
            }

            String currentValue = data.get(i)[1];
            boolean testResult = defaultValue.equals(currentValue);

            // Handle failures
            if(failures.containsKey(parameter)){

                // If they aren't the same then add failure to return string
                if(!testResult){
                    noFailures = false;
                    String failureString = "Parameter " + parameter + " is set differently than default. Default: " + defaultValue + ", Actual: " + currentValue + "\r\n";
                    returnString.append(failureString);
                    Log.e(TAG, parameter + ":" + currentValue + " != default:" + defaultValue);
                }else{
                    Log.d(TAG, parameter + ":" + currentValue + " == default:" + defaultValue);
                }
            }

            // Write each line to file
            String line = parameter + "," + defaultValue + "," + currentValue + "," + testResult + "," + "false" + "\r\n";
            bufferedWriter.write(line);
        }

        bufferedWriter.flush();
        bufferedWriter.close();

        return noFailures;
    }

    // ------------------------------------------
    // Get settings data
    // ------------------------------------------

    // Accumulate data
    private ArrayList<String[]> getSettingsData(){
        ArrayList<String[]> data = getGetPropData();
        ArrayList<String[]> getDatabaseData = getDatabaseData();
        ArrayList<String[]> getTelephonyData = getTelephonyData();

        data.addAll(getDatabaseData);
        data.addAll(getTelephonyData);

        return data;
    }

    // Parse getprop data into usable form
    private ArrayList<String[]> getGetPropData() {

        ArrayList<String[]> strArr = new ArrayList<>();
        String line;
        try {
            Process process = new ProcessBuilder().command("/system/bin/getprop").redirectErrorStream(true).start();
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while ((line = bufferedReader.readLine()) != null) {
                String[] arr = line.split(":\\s");
                arr[0] = arr[0].replaceAll("[\\[\\]]", "").replace(",", " ");
                arr[1] = arr[1].replaceAll("[\\[\\]]", "").replace(",", " ");

                strArr.add(arr);
            }
            process.destroy();
        } catch (IOException e) {
            Log.e(this.toString(), e.getMessage());
        } catch (Exception e) {
            Log.e(this.toString(), e.getMessage());
        }


        return strArr;
    }

    // Parse telephony data into usable form
    private ArrayList<String[]> getTelephonyData() {

        ArrayList<String[]> strArr = new ArrayList<>();

        TelephonyManager telephonyManager = (TelephonyManager) receiverContext.getSystemService(Context.TELEPHONY_SERVICE);

        if (telephonyManager != null){
            strArr.add(new String[]{"data_connection_state", String.valueOf(telephonyManager.getDataState())});
            strArr.add(new String[]{"network_operator", telephonyManager.getNetworkOperator()});
            strArr.add(new String[]{"sim_state", String.valueOf(telephonyManager.getSimState())});
        }

        return strArr;
    }

    // Parse database data into usable form
    private ArrayList<String[]> getDatabaseData(){

        ArrayList<String[]> strArr = new ArrayList<>();
        String line;

        File file = new File("data/data/com.android.providers.settings/databases/settings.db");

        SQLiteDatabase sqLiteDatabase = SQLiteDatabase.openDatabase(file.getAbsolutePath(), null, SQLiteDatabase.OPEN_READONLY);
        Cursor cursor = sqLiteDatabase.rawQuery("select name, value from global;", null);

        try {
            while(cursor.moveToNext()){
                strArr.add(new String[] {cursor.getString(0), cursor.getString(1).replace(",", " ")});
            }
            cursor.close();
        }catch (Exception e) {
            Log.e(this.toString(), e.getMessage());
        }

        cursor = sqLiteDatabase.rawQuery("select name, value from secure;", null);

        try {
            while(cursor.moveToNext()){
                strArr.add(new String[] {cursor.getString(0), cursor.getString(1).replace(",", " ")});
            }
            cursor.close();
        }catch (Exception e) {
            Log.e(this.toString(), e.getMessage());
        }

        sqLiteDatabase.close();

        return strArr;
    }

    // ------------------------------------------
    // Loading default values and failures
    // ------------------------------------------

    private void loadFailures(){
        failures = new HashMap<>();

        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(receiverContext.getResources().openRawResource(R.raw.failures)));
        try {
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                failures.put(line, line);
            }
            bufferedReader.close();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
        }
    }

    private void loadDefaults(){
        defaults = new HashMap<>();

        // Read in getprop_defaults for getprop
        populateDefaults(R.raw.getprop_defaults);

        // Read in getprop_defaults for settings database
        populateDefaults(R.raw.settings_defaults);

        // Read in telephony_defaults for telephony
        populateDefaults(R.raw.telephony_defaults);
    }

    private void populateDefaults(int resource) {
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(receiverContext.getResources().openRawResource(resource)));
        try {
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                // Different parsing depending on file
                if(resource == R.raw.getprop_defaults){
                    String[] arr = line.split(":\\s");
                    arr[0] = arr[0].replaceAll("[\\[\\]]", "").replace(",", " ");
                    arr[1] = arr[1].replaceAll("[\\[\\]]", "").replace(",", " ");
                    defaults.put(arr[0], arr[1]);
                }else if(resource == R.raw.settings_defaults){
                    String[] arr = line.split(",", 2);
                    arr[1] = arr[1].replace(",", " ");
                    defaults.put(arr[0], arr[1]);
                }else{ // Telephony
                    String[] arr = line.split(",", 2);
                    defaults.put(arr[0], arr[1]);
                }
            }
            bufferedReader.close();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
        }
    }
}