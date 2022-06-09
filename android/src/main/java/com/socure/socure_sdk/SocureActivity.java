package com.socure.socure_sdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.socure.idplus.devicerisk.androidsdk.model.UploadResult;
import com.socure.idplus.devicerisk.androidsdk.sensors.DeviceRiskManager;
import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

public class SocureActivity extends AppCompatActivity implements DeviceRiskManager.DataUploadCallback {
    public static final String EXTRA_CONTEXT = "CONTEXT";
    public static final String EXTRA_RESULT_DEVICE_SESSION_ID = "DEVICE_SESSION_ID";
    public static final String EXTRA_RESULT_DEVICE_ERROR = "DEVICE_ERROR";

    private DeviceRiskManager deviceRiskManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

/*
        String apiKey = getIntent().getStringExtra(EXTRA_API_KEY);
*/
        loadDeviceRiskManager(/*apiKey*/);
        moveTaskToBack(true);
    }

    public static void startActivityForResult(Activity activity, DeviceRiskManager.Context deviceRiskContext, int requestCode) {
        Intent i = new Intent();
        i.putExtra(EXTRA_CONTEXT, deviceRiskContext.getContextName());
        activity.startActivityForResult(i, requestCode);
    }

    private void loadDeviceRiskManager() {
        deviceRiskManager = new DeviceRiskManager();
        List<DeviceRiskManager.DeviceRiskDataSourcesEnum> list = new ArrayList<>();

        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Device);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Network);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Locale);
        list.add(DeviceRiskManager.DeviceRiskDataSourcesEnum.Location);

        deviceRiskManager.setTracker(null, null, list, true, this, this);
        deviceRiskManager.sendData(DeviceRiskManager.Context.valueOf(getIntent().getStringExtra(EXTRA_CONTEXT)));
    }

    @Override
    public void dataUploadFinished(@NotNull UploadResult uploadResult) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_RESULT_DEVICE_SESSION_ID, uploadResult.getUuid());
        setResult(Activity.RESULT_OK, intent);
        finish();
    }

    @Override
    public void onError(@NotNull DeviceRiskManager.SocureSDKErrorType socureSDKErrorType, @org.jetbrains.annotations.Nullable String s) {
        Intent intent = new Intent();
        intent.putExtra(EXTRA_RESULT_DEVICE_ERROR, s);
        setResult(Activity.RESULT_CANCELED, intent);
        finish();
    }
}
