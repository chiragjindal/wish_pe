package com.crypticj.wish_pe;

import io.flutter.embedding.android.FlutterActivity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.crypticj.wish_pe/intent";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getSharedContent")) {
                        handleIntent(getIntent(), result);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleIntent(intent, null);
    }

    private void handleIntent(Intent intent, MethodChannel.Result result) {
        if (intent != null && intent.getAction() != null) {
            String action = intent.getAction();
            String type = intent.getType();

            if (Intent.ACTION_SEND.equals(action) && type != null) {
                if ("text/plain".equals(type)) {
                    String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
                    System.out.println(sharedText);
                    if (result != null) {
                        result.success(sharedText);
                    } else {
                        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                                .invokeMethod("getSharedContent", sharedText);
                    }
                } else if (type.startsWith("image/")) {
                    Uri imageUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
                    if (imageUri != null) {
                        String path = getPathFromUri(imageUri);
                        if (result != null) {
                            result.success(path);
                        } else {
                            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                                    .invokeMethod("getSharedContent", path);
                        }
                    }
                }
            } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
                if (type.startsWith("image/")) {
                    ArrayList<Uri> imageUris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
                    if (imageUris != null) {
                        ArrayList<String> paths = new ArrayList<>();
                        for (Uri uri : imageUris) {
                            paths.add(getPathFromUri(uri));
                        }
                        if (result != null) {
                            result.success(paths);
                        } else {
                            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                                    .invokeMethod("getSharedContent", paths);
                        }
                    }
                }
            }
        }
    }

    @Nullable
    private String getPathFromUri(Uri uri) {
        String filePath = null;
        Cursor cursor = null;
        try {
            String[] projection = { MediaStore.Images.Media.DATA };
            cursor = getContentResolver().query(uri, projection, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                int columnIndex = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                filePath = cursor.getString(columnIndex);
            }
        } catch (Exception e) {
            Log.e("MainActivity", "Error getting file path: " + e.getMessage());
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return filePath;
    }
}
