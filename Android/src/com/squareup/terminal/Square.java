/*
 * Copyright (C) 2011 Square, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.squareup.terminal;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import java.util.List;

/**
 * Entry point for Square's Android Terminal API. Interacts with the Square
 * application installed on this device. The user of this API can:
 *
 * <ol>
 *   <li>{@linkplain #installationStatus Query the installation status} of
 *      Square.</li>
 *   <li>{@linkplain #requestInstallation Request installation} of Square by
 *      navigating to the Android Market.</li>
 *   <li>{@linkplain #request(Payment, int) Request a payment} through
 *      Square.</li>
 * </ol>
 *
 * For example:
 *
 * <pre>
 *  import android.app.Activity;
 *  import android.os.Bundle;
 *
 *  public class My2Cents extends Activity {
 *    &#64;Override public void onCreate(Bundle state) {
 *      super.onCreate(state);
 *
 *      Square square = new Square(this, "my-application-id");
 *      if (square.installationStatus()
 *          != Square.InstallationStatus.AVAILABLE) {
 *        square.requestInstallation();
 *      } else {
 *        square.request(new Payment()
 *            .amount(2, Currency.USD) // 2 cents
 *            .description("advice")
 *        );
 *      }
 *    }
 *  }
 * </pre>
 *
 * @author Bob Lee (bob@squareup.com)
 */
public final class Square {

  /** Minimum client version that supports this version of the API. */
  private static final int MINIMUM_VERSION = 28;
  
  /** Square package name. */
  private static final String PACKAGE = "com.squareup";

  private final Activity activity;
  private final String applicationId;

  /**
   * Constructs a new instance of this API.
   *
   * @param activity that requests the payment and receives the response
   * @param applicationId application ID assigned by Square Inc. for the current application
   * @throws NullPointerException if activity or application ID is null
   */
  public Square(Activity activity, String applicationId) {
    if (activity == null) throw new NullPointerException("activity");
    if (applicationId == null) throw new NullPointerException("applicationId");
    this.activity = activity;
    this.applicationId = applicationId;
  }

  /**
   * Checks the status of the Square installation, if any, on this device.
   */
  public InstallationStatus installationStatus() {
    try {
      PackageInfo info = activity.getPackageManager().getPackageInfo(
          PACKAGE, 0);
      return info.versionCode >= MINIMUM_VERSION ? InstallationStatus.AVAILABLE
          : InstallationStatus.OUTDATED;
    } catch (PackageManager.NameNotFoundException e) {
      return InstallationStatus.MISSING;
    }
  }

  /** Navigates to Square in the Android Market. */
  public void requestInstallation() {
    Intent marketIntent = getMarketIntent();
    if (marketIntent != null) {
      activity.startActivity(marketIntent);
    } else {
      throw new RuntimeException("This device does not support market: or https: urls.");
    }
  }

  /** Returns an intent to launch the Market or browser, or null. */
  private Intent getMarketIntent() {
    // Prefer the market: url.
    Intent intent = getViewIntent("market://search?q=pname:" + PACKAGE);
    if (intent == null) {
      // The Market app is generally unavailable when running on an emulator.
      intent = getViewIntent("https://market.android.com/details?id=" + PACKAGE);
    }
    return intent;
  }

  /**
   * Returns an intent to view the given URI, or null if this device does not
   * support the given URI.
   */
  private Intent getViewIntent(String uri) {
    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
    return (isIntentAvailable(intent)) ? intent : null;
  }

  /**
   * Returns true if the given intent is available on this device. Based on
   * Romain Guy's <a href="http://goo.gl/3nnA5">Android: Can I use this
   * Intent?</a> blog post.
   */
  private boolean isIntentAvailable(Intent intent) {
    List<ResolveInfo> infos = activity.getPackageManager().queryIntentActivities(
        intent, PackageManager.MATCH_DEFAULT_ONLY);
    return !infos.isEmpty();
  }


  /**
   * Convenience method, equivalent to {@code request(payment, 0)}. Useful
   * if this is the only usage of {@link android.app.Activity#startActivityForResult} in
   * the activity.
   */
  public void request(Payment payment) {
    request(payment, 0);
  }

  private static final Uri BASE_URL = Uri.parse("square://terminal/1.0/pay");

  /**
   * Requests a payment through Square. Starts Square and fills in the payment information.
   *
   * <p>After Square finishes, Android invokes {@link
   * android.app.Activity#onActivityResult Activity.onActivityResult()} on the activity
   * passed to the constructor. The request code passed to this method will be
   * passed to {@code onActivityResult()}. The result code is {@link
   * android.app.Activity#RESULT_CANCELED} if the payment was canceled or {@link
   * android.app.Activity#RESULT_OK} if the payment succeeded.
   *
   * <p>The Intent passed to {@code onActivityResult} can be parsed using
   * {@link Response#from(android.content.Intent)}</p>
   *
   * @param requestCode to pass to {@link android.app.Activity#onActivityResult}, >= 0
   * @throws IllegalArgumentException if requestCode < 0
   * @throws NullPointerException if payment is null
   * @throws android.content.ActivityNotFoundException if Square is not
   *  installed or doesn't support this version of the API
   */
  public void request(Payment payment, int requestCode) {
    if (requestCode < 0) throw new IllegalArgumentException("requestCode < 0");
    if (payment == null) throw new NullPointerException("payment");

    Intent intent = new Intent(Intent.ACTION_DEFAULT);

    // The calling app should show up in "recents", not Square.
    intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);

    // Construct URL.
    Uri.Builder builder = BASE_URL.buildUpon();
    TerminalParameters parameters = new TerminalParameters().copyFrom(payment);
    parameters.app_id = applicationId;
    parameters.appendTo(builder);
    Uri url = builder.build();
    intent.setData(url);

    activity.startActivityForResult(intent, requestCode);
  }

  /**
   * Status of the Square application on this device.
   */
  public enum InstallationStatus {

    /** Square is not installed. */
    MISSING,

    /** Square is installed, but it doesn't support this version of the API. */
    OUTDATED,

    /** Square is available, and it supports this API. */
    AVAILABLE
  }
}
