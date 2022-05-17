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
      flutterResult = null;
      // TODO deviceRiskManager.sendData(DeviceRiskManager.Context.SignUp);
    } else if (call.method.equals("setTracker")) {
      // List<Object> argList = (List<Object>) call.arguments;
      flutterResult.success(null);
      // TODO it needs AppCompatActivity, but FlutterActivity doesn't extend it: deviceRiskManager.setTracker(argList.get(0).toString(), null, Arrays.asList(DeviceRiskManager.DeviceRiskDataSourcesEnum.Device, DeviceRiskManager.DeviceRiskDataSourcesEnum.Locale, DeviceRiskManager.DeviceRiskDataSourcesEnum.Location, DeviceRiskManager.DeviceRiskDataSourcesEnum.Network), true, null, null);
      flutterResult = null;
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

          obj.put("passportImage", result.getPassportImage());
          obj.put("licenseBackImage", result.getLicenseBackImage());
          obj.put("licenseFrontImage", result.getLicenseFrontImage());
          obj.put("selfieImage", result.getSelfieImage());
          obj.put("documentType", result.getDocumentType().toString());


          if (result.getMrzData() != null) {
            Log.d(LOG_TAG, "mrzData not null");
            obj.put("mrzData", mrzToMap(result.getMrzData()));
          } else if (result.getIdmrzData() != null) {
            Log.d(LOG_TAG, "idmrzData not null");
            obj.put("mrzData", mrzToMap(result.getIdmrzData()));
          } else {
            Log.d(LOG_TAG, "mrzData null");
          }

          if (result.getBarcodeData() != null) obj.put("barcodeData", barcodeDataToMap(result.getBarcodeData()));

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

          obj.put("selfieImage", result.getImageData());
          obj.put("autoCaptured", result.getAutoCaptured());
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
    mrzDataMap.put("documentNumber", mrzData.getDocumentNumber());
    mrzDataMap.put("fullName", mrzData.getFullName());
    mrzDataMap.put("firstName", mrzData.getFirstName());
    mrzDataMap.put("surName", mrzData.getSurName());
    mrzDataMap.put("nationality", mrzData.getNationality());
    mrzDataMap.put("issuingCountry", mrzData.getIssuingCountry());
    mrzDataMap.put("sex", mrzData.getSex());
    mrzDataMap.put("city", mrzData.getCity());
    mrzDataMap.put("state", mrzData.getState());
    mrzDataMap.put("address", mrzData.getAddress());
    mrzDataMap.put("postalCode", mrzData.getPostalCode());
    mrzDataMap.put("phone", mrzData.getPhone());

    if (mrzData.getExpirationDate() != null) mrzDataMap.put("expirationDate", mrzData.getExpirationDate().getYear() + "-" + mrzData.getExpirationDate().getMonth() + "-" + mrzData.getExpirationDate().getDay());
    if (mrzData.getDob() != null) mrzDataMap.put("dob", mrzData.getDob().getYear() + "-" + mrzData.getDob().getMonth() + "-" + mrzData.getDob().getDay());
    return mrzDataMap;
  }

  private Map<String, Object> barcodeDataToMap(BarcodeData barcodeData) {
    HashMap<String, Object> map = new HashMap<>();
    map.put("documentNumber", barcodeData.getDocumentNumber());
    map.put("fullName", barcodeData.getFullName());
    map.put("firstName", barcodeData.getFirstName());
    map.put("surName", barcodeData.getSurName());
    map.put("city", barcodeData.getCity());
    map.put("state", barcodeData.getState());
    map.put("address", barcodeData.getAddress());
    map.put("postalCode", barcodeData.getPostalCode());
    map.put("phone", barcodeData.getPhone());

    if (barcodeData.getDOB() != null) map.put("dob", barcodeData.getDOB().getYear() + "-" + barcodeData.getDOB().getMonth() + "-" + barcodeData.getDOB().getDay());
    if (barcodeData.getIssueDate() != null) map.put("issueDate", barcodeData.getIssueDate().getYear() + "-" + barcodeData.getIssueDate().getMonth() + "-" + barcodeData.getIssueDate().getDay());
    if (barcodeData.getExpirationDate() != null) map.put("expirationDate", barcodeData.getExpirationDate().getYear() + "-" + barcodeData.getExpirationDate().getMonth() + "-" + barcodeData.getExpirationDate().getDay());

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
