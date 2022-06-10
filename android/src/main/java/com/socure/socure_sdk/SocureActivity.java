package com.socure.socure_sdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.socure.idplus.devicerisk.androidsdk.BuildConfig;
import com.socure.idplus.devicerisk.androidsdk.model.UploadResult;
import com.socure.idplus.devicerisk.androidsdk.sensors.DeviceRiskManager;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

public class SocureActivity extends AppCompatActivity implements DeviceRiskManager.DataUploadCallback {
    //inputs
    public static final String EXTRA_CONTEXT = "CONTEXT";
    public static final String EXTRA_CALL_SET_TRACKER = "CALL_SET_TRACKER";

    //outputs
    public static final String EXTRA_RESULT_DEVICE_SESSION_ID = "DEVICE_SESSION_ID";
    public static final String EXTRA_RESULT_DEVICE_ERROR = "DEVICE_ERROR";
    public static final String EXTRA_RESULT_DEVICE_ERROR_TYPE = "DEVICE_ERROR_TYPE";

    private DeviceRiskManager deviceRiskManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        loadDeviceRiskManager();
        deviceRiskManager.sendData(DeviceRiskManager.Context.valueOf(getIntent().getStringExtra(EXTRA_CONTEXT)));
    }

    public static void startActivityForResult(Activity activity, DeviceRiskManager.Context deviceRiskContext, int requestCode) {
        Intent i = new Intent(activity, SocureActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        i.putExtra(EXTRA_CONTEXT, deviceRiskContext.name());
        activity.startActivityForResult(i, requestCode);
    }

    private void loadDeviceRiskManager() {
        deviceRiskManager = new DeviceRiskManager();
        List<DeviceRiskManager.DeviceRiskDataSourcesEnum> list = new ArrayList<>();

        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Device);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Network);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Locale);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Location);

        String publicApiKey = getString(R.string.socurePublicKey);
        Log.d("SocureActivity", "Using API key: " + (publicApiKey != null ? publicApiKey : "null"));

        if (getIntent().getBooleanExtra(EXTRA_CALL_SET_TRACKER, true)) {
            deviceRiskManager.setTracker(publicApiKey, null, list, true, this, this);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        overridePendingTransition(0, 0);
    }

    @Override
    public void dataUploadFinished(@NotNull UploadResult uploadResult) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                String uuid = uploadResult.getUuid();
                Log.d("SocureActivity", "Socure getSessionId success: " + (uuid != null ? uuid : ""));

                Intent intent = new Intent();
                intent.putExtra(EXTRA_RESULT_DEVICE_SESSION_ID, uuid);
                setResult(Activity.RESULT_OK, intent);
                finish();
            }
        });
    }

    @Override
    public void onError(@NotNull DeviceRiskManager.SocureSDKErrorType socureSDKErrorType, @org.jetbrains.annotations.Nullable String s) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Log.d("SocureActivity", "Socure getSessionId failed: " + socureSDKErrorType.name());

                Intent intent = new Intent();
                intent.putExtra(EXTRA_RESULT_DEVICE_ERROR_TYPE, socureSDKErrorType.name());
                intent.putExtra(EXTRA_RESULT_DEVICE_ERROR, s);
                setResult(Activity.RESULT_CANCELED, intent);
                finish();
            }
        });
    }
}
