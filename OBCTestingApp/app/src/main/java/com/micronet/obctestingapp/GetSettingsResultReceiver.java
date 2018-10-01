package com.micronet.obctestingapp;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
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

        for(int i = 0; i < data.size(); i++){
            String parameter = data.get(i)[0];

            String defaultValue = "";
            if(defaults.containsKey(parameter)){
                defaultValue = defaults.get(parameter);
            }

            String currentValue = data.get(i)[1];
            boolean testResult = defaultValue.equals(currentValue);

            // Handle failures
            if(failures.containsKey(parameter) && !testResult){
                noFailures = false;
                returnString.append(parameter);
                returnString.append("\r\n");
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

        data.addAll(getDatabaseData);

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

        // Read in defaults for getprop
        populateDefaults(R.raw.defaults);

        // Read in defaults for settings database
        populateDefaults(R.raw.settings_defaults);
    }

    private void populateDefaults(int resource) {
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(receiverContext.getResources().openRawResource(resource)));
        try {
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                // Different parsing depending on file
                if(resource == R.raw.defaults){
                    String[] arr = line.split(":\\s");
                    arr[0] = arr[0].replaceAll("[\\[\\]]", "").replace(",", " ");
                    arr[1] = arr[1].replaceAll("[\\[\\]]", "").replace(",", " ");
                    defaults.put(arr[0], arr[1]);
                }else{
                    String[] arr = line.split(",", 2);
                    arr[1] = arr[1].replace(",", " ");
                    defaults.put(arr[0], arr[1]);
                }
            }
            bufferedReader.close();
        } catch (IOException e) {
            Log.e(TAG, e.toString());
        }
    }
}
