package com.randonautica.app.camrng;

import android.os.Bundle;
import android.widget.Toast;

import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import com.randonautica.app.R;

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
        arguments.putInt("bytesNeeded", getIntent().getIntExtra("bytesNeeded", 109816));
        MyCamRngFragment.setArguments(arguments);
        fragmentManager.beginTransaction()
                .replace(R.id.fragment_container, MyCamRngFragment, tag)
                .addToBackStack(tag)
                .commit();
    }

    //Send Entropy from Camera RNG Fragment
    public void sendEntropyObj(int size, String entropy) {
        Toast.makeText(getBaseContext(), "entropy size " + size, Toast.LENGTH_SHORT).show();
    }

//    //Enable the on back press key to open previous fragment from the stack
//    @Override
//    public void onBackPressed() {
//        FragmentManager fragmentManager = getSupportFragmentManager();
//        if (fragmentManager.getBackStackEntryCount() != 0) {
//            fragmentManager.popBackStack();
//        } else {
//            super.onBackPressed();
//        }
//    }
}
