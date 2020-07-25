package com.randonautica.app.camrng;

import android.os.Bundle;
import android.widget.Toast;
import android.util.Log;
import android.content.Intent;
import android.app.Activity;
import android.os.AsyncTask;

import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import com.randonautica.app.R;

import java.util.Calendar;
import java.util.TimeZone;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import org.json.JSONObject;

public class CamRNGActivity extends FragmentActivity implements MyCamRngFragment.SendMessage {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_camrng);

        //Start the CameraRNG dialog
        String tag = "CameraRNG";
        FragmentManager fragmentManager = getSupportFragmentManager();
        MyCamRngFragment MyCamRngFragment = new MyCamRngFragment();
        Bundle arguments = new Bundle();
        arguments.putInt("bytesNeeded", getIntent().getIntExtra("bytesNeeded", 0));
        MyCamRngFragment.setArguments(arguments);
        fragmentManager.beginTransaction()
                .replace(R.id.fragment_container, MyCamRngFragment, tag)
                .addToBackStack(tag)
                .commit();
    }

    //Send Entropy from Camera RNG Fragment
    public void sendEntropyObj(int size, String entropy) {
        //Toast.makeText(getBaseContext(), "entropy size " + size, Toast.LENGTH_SHORT).show();

        // POST entropy to libwrapper for the bot to consume
        final String jsonString = "{" +
                    "\"size\": " + size + "," +
                    "\"raw\": true," +
                    "\"timestamp\": " + Calendar.getInstance(TimeZone.getTimeZone("UTC")).getTimeInMillis() + "," +
                    "\"entropy\": \"" + entropy + "\"" +
                "}";
        AsyncTask<String, Void, String> asyncTask = new AsyncTask<String, Void, String>() {
            @Override
            protected String doInBackground(String... params) {
                try {
                    String jsonString = params[0];
                    RequestBody requestBody = RequestBody.create(okhttp3.MediaType.parse("application/json"), jsonString);

                    OkHttpClient client = new OkHttpClient();

                    Request request = new Request.Builder()
                            .url("https://api.randonauts.com/setentropy")
                            .post(requestBody)
                            .build();

                    Response response = client.newCall(request).execute();
                    String resultStr = response.body().string();
                    return resultStr;
                } catch (Exception e) {
                    Log.e("CamRNG", "Failed to upload entropy", e);
                    return null;
                }
            }

            @Override
            protected void onPostExecute(String responseJson) {
                super.onPostExecute(responseJson);
                if (responseJson != null) {
                    JSONObject jsonObject;
                    String gid = "Cancel";
                    try {
                        jsonObject = new JSONObject(responseJson);
                        gid = jsonObject.getString("Gid");
                    } catch (Exception e) {
                        Log.e("CamRNG", "Failed to get entropy GID", e);
                        Intent resultIntent = new Intent();
                        resultIntent.putExtra("gid", "Cancel");
                        setResult(Activity.RESULT_CANCELED, resultIntent);
                        finish();
                    }
                    Intent resultIntent = new Intent();
                    resultIntent.putExtra("gid", gid);
                    setResult(Activity.RESULT_OK, resultIntent);
                    finish();
                }
                else
                {
                    Intent resultIntent = new Intent();
                    resultIntent.putExtra("gid", "Cancel");
                    setResult(Activity.RESULT_CANCELED, resultIntent);
                    finish();
                }
            }
        };

        asyncTask.execute(jsonString);
    }


    //Enable the on back press key to open previous fragment from the stack
    @Override
    public void onBackPressed() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        for (int i = 0; i < fragmentManager.getBackStackEntryCount(); i++) {
            fragmentManager.popBackStack();
        }

        super.onBackPressed();
    }
}
