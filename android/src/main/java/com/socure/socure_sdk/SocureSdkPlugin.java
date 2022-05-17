package com.socure.socure_sdk;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import com.socure.idplus.SDKAppDataPublic;
import com.socure.idplus.model.BarcodeData;
import com.socure.idplus.model.MrzData;
import com.socure.idplus.model.ScanResult;
import com.socure.idplus.model.SelfieScanResult;
import com.socure.idplus.scanner.SelfieScanner;
import com.socure.idplus.scanner.license.LicenseScannerActivity;
import com.socure.idplus.scanner.passport.PassportScannerActivity;
import com.socure.idplus.scanner.selfie.SelfieActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.socure.idplus.devicerisk.androidsdk.sensors.DeviceRiskManager;

public class SocureSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private static final String LOG_TAG = "Socure_Flutter";

  private final int SCAN_PASSPORT_CODE = 70346738;
  private final int SCAN_LICENSE_CODE = 70346739;
  private final int SCAN_SELFIE_CODE = 70346740;

  private MethodChannel channel;
  private Activity activity;
  private Result flutterResult;
  private DeviceRiskManager deviceRiskManager = new DeviceRiskManager();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "socure_sdk");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    flutterResult = result;

    if (call.method.equals("initiatePassportScan")) {
      Intent intent = new Intent(activity, PassportScannerActivity.class);
      activity.startActivityForResult(intent, SCAN_PASSPORT_CODE);
    } else if (call.method.equals("initiateLicenseScan")) {
      Intent intent = new Intent(activity, LicenseScannerActivity.class);
      activity.startActivityForResult(intent, SCAN_LICENSE_CODE);
    } else if (call.method.equals("initiateSelfieScan")) {
      Intent intent = new Intent(activity, SelfieActivity.class);
      activity.startActivityForResult(intent, SCAN_SELFIE_CODE);
    } else if (call.method.equals("getDeviceSessionId")) {
      flutterResult.success(null);
      // TODO deviceRiskManager.sendData(DeviceRiskManager.Context.SignUp);
    } else if (call.method.equals("setTracker")) {
      // List<Object> argList = (List<Object>) call.arguments;
      flutterResult.success(null);
      // TODO it needs AppCompatActivity, but FlutterActivity doesn't extend it: deviceRiskManager.setTracker(argList.get(0).toString(), null, Arrays.asList(DeviceRiskManager.DeviceRiskDataSourcesEnum.Device, DeviceRiskManager.DeviceRiskDataSourcesEnum.Locale, DeviceRiskManager.DeviceRiskDataSourcesEnum.Location, DeviceRiskManager.DeviceRiskDataSourcesEnum.Network), true, null, null);
    } else {
      flutterResult = null;
      result.notImplemented();
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == SCAN_PASSPORT_CODE || requestCode == SCAN_LICENSE_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        try {
          ScanResult result = SDKAppDataPublic.INSTANCE.getSuccessfulScanningResult();
          HashMap<String, Object> obj = new HashMap<>();
          if (result == null) {
            flutterResult.error("-3", "result is null", null);
            return true;
          }

          obj.put("passportImage", result.passportImage);
          obj.put("licenseBackImage", result.licenseBackImage);
          obj.put("licenseFrontImage", result.licenseFrontImage);
          obj.put("selfieImage", result.selfieImage);
          obj.put("documentType", result.documentType.toString());


          if (result.mrzData != null) {
            Log.d(LOG_TAG, "mrzData not null");
            obj.put("mrzData", mrzToMap(result.mrzData));
          } else if (result.idmrzData != null) {
            Log.d(LOG_TAG, "idmrzData not null");
            obj.put("mrzData", mrzToMap(result.idmrzData));
          } else {
            Log.d(LOG_TAG, "mrzData null");
          }

          if (result.barcodeData != null) obj.put("barcodeData", barcodeDataToMap(result.barcodeData));

          flutterResult.success(obj);
        } catch (Exception e) {
          flutterResult.error("-2", e.getMessage(), null);
        }
      } else {
        boolean errorHandled = false;

        String err = data != null ? data.getStringExtra("error") : null;
        if (err != null) {
          Log.d(LOG_TAG, err);

          // To extract values you can utilize a JSON parser such as org.json.JSONObject
          // err is a json string. such as -> "{\"type\":\"com.socure.idplus.error.DocumentScanError\",\"message\":\"Scan cancelled by user\"}"
          try {
            JSONObject jObj = new JSONObject(err);
            if ("com.socure.idplus.error.DocumentScanError".equals(jObj.getString("type"))) {
              flutterResult.success(null);
              errorHandled = true;
            } else {
              flutterResult.error("-1", jObj.getString("message"), null);
              errorHandled = true;
            }
          } catch (JSONException e) {
            e.printStackTrace();
          }
        }

        if (!errorHandled) flutterResult.error("-1", "Scan failed", null);
      }

      flutterResult = null;
      return true;
    }

    if (requestCode == SCAN_SELFIE_CODE) {
      if (resultCode == Activity.RESULT_OK) {
        try {
          SelfieScanResult result = SDKAppDataPublic.INSTANCE.getSelfieScanResult();
          HashMap<String, Object> obj = new HashMap<>();

          obj.put("selfieImage", result.imageData);
          obj.put("autoCaptured", result.autoCaptured);
          obj.put("documentType", "SELFIE");

          flutterResult.success(obj);
        } catch (Exception e) {
          flutterResult.error("-2", e.getMessage(), null);
        }
      } else {
        flutterResult.error("-1", "Scan failed", null);
      }

      flutterResult = null;
      return true;
    }

    return false;
  }

  private Map<String, Object> mrzToMap(MrzData mrzData) {
    HashMap<String, Object> mrzDataMap = new HashMap<>();
    mrzDataMap.put("documentNumber", mrzData.documentNumber);
    mrzDataMap.put("fullName", mrzData.fullName);
    mrzDataMap.put("firstName", mrzData.firstName);
    mrzDataMap.put("surName", mrzData.surName);
    mrzDataMap.put("nationality", mrzData.nationality);
    mrzDataMap.put("issuingCountry", mrzData.issuingCountry);
    mrzDataMap.put("sex", mrzData.sex);
    mrzDataMap.put("city", mrzData.city);
    mrzDataMap.put("state", mrzData.state);
    mrzDataMap.put("address", mrzData.address);
    mrzDataMap.put("postalCode", mrzData.postalCode);
    mrzDataMap.put("phone", mrzData.phone);

    if (mrzData.expirationDate != null) mrzDataMap.put("expirationDate", mrzData.expirationDate.year + "-" + mrzData.expirationDate.month + "-" + mrzData.expirationDate.day);
    if (mrzData.dob != null) mrzDataMap.put("dob", mrzData.dob.year + "-" + mrzData.dob.month + "-" + mrzData.dob.day);
    return mrzDataMap;
  }

  private Map<String, Object> barcodeDataToMap(BarcodeData barcodeData) {
    HashMap<String, Object> map = new HashMap<>();
    map.put("documentNumber", barcodeData.documentNumber);
    map.put("fullName", barcodeData.fullName);
    map.put("firstName", barcodeData.firstName);
    map.put("surName", barcodeData.surName);
    map.put("city", barcodeData.city);
    map.put("state", barcodeData.state);
    map.put("address", barcodeData.address);
    map.put("postalCode", barcodeData.postalCode);
    map.put("phone", barcodeData.phone);

    if (barcodeData.DOB != null) map.put("dob", barcodeData.DOB.year + "-" + barcodeData.DOB.month + "-" + barcodeData.DOB.day);
    if (barcodeData.issueDate != null) map.put("issueDate", barcodeData.issueDate.year + "-" + barcodeData.issueDate.month + "-" + barcodeData.issueDate.day);
    if (barcodeData.expirationDate != null) map.put("expirationDate", barcodeData.expirationDate.year + "-" + barcodeData.expirationDate.month + "-" + barcodeData.expirationDate.day);

    return map;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    binding.addActivityResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    binding.addActivityResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
}
