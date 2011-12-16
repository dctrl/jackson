package com.squareup.jackson;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import au.com.bytecode.opencsv.CSVWriter;
import com.squareup.terminal.Currency;
import com.squareup.terminal.Money;
import com.squareup.terminal.Payment;
import com.squareup.terminal.Response;
import com.squareup.terminal.Square;

import java.io.IOException;
import java.io.StringWriter;

public class Main extends Activity {

  // Replace with your app and recipient IDs.
  private static final String APP_ID = "my-app-id";
  private static final String TO_ID = "my-to-id";

  private static final int VALIDATION_DIALOG = 0;
  private static final int CLEAR_DIALOG = 2;
  private static final int EXIT_DIALOG = 3;

  private TextView email;

  private int dollars;

  private TextView[] textViews;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    getWindow().setFormat(PixelFormat.RGBA_8888);

    setContentView(R.layout.main);

    TextView name = findTextViewById(R.id.name);
    email = findTextViewById(R.id.email);
    TextView street = findTextViewById(R.id.street);
    TextView city = findTextViewById(R.id.city);
    TextView state = findTextViewById(R.id.state);
    TextView zip = findTextViewById(R.id.zip);
    TextView employer = findTextViewById(R.id.employer);
    TextView occupation = findTextViewById(R.id.occupation);
    TextView amount = findTextViewById(R.id.amount);

    // Note: The order matches that in openCsv().
    textViews = new TextView[] {
        name, email, street, city, state, zip, employer, occupation, amount
    };

    // Set up focus navigation around the zip field.
    state.setNextFocusDownId(R.id.zip);
    employer.setNextFocusUpId(R.id.zip);
    zip.setNextFocusUpId(R.id.state);

    amount.setNextFocusDownId(R.id.pay);

    findViewById(R.id.pay).setOnClickListener(new View.OnClickListener() {
      public void onClick(View v) {
        pay();
      }
    });

    findViewById(R.id.clear).setOnClickListener(new View.OnClickListener() {
      public void onClick(View v) {
        showDialog(CLEAR_DIALOG);
      }
    });

    // Note: We originally implemented this using a KeyListener, however that does not work with the latest version
    // of the Swype keyboard. Instead, use TextWatcher.
    amount.addTextChangedListener(new AmountTextWatcher());
  }

  private static final String AMOUNT_KEY = "amount";

  @Override protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    outState.putInt(AMOUNT_KEY, dollars);
  }

  @Override protected void onRestoreInstanceState(Bundle savedInstanceState) {
    super.onRestoreInstanceState(savedInstanceState);
    dollars = savedInstanceState.getInt(AMOUNT_KEY);
  }

  /** Handles pay button. */
  private void pay() {
    if (validate() != null) {
      showDialog(VALIDATION_DIALOG);
      return;
    }

    Square square = new Square(this, APP_ID);
    if (square.installationStatus() != Square.InstallationStatus.AVAILABLE) {
      square.requestInstallation();
    } else {
      square.request(new Payment()
          .description(description())
          .defaultEmail(email.getText().toString())
          .recipient(TO_ID)
          .amount(new Money(dollars * 100, Currency.USD)));
    }
  }

  @Override protected void onActivityResult(int requestCode, int resultCode,
      Intent data) {

    if (resultCode != RESULT_OK) {
      Toast.makeText(this, getFailureMessage(data), Toast.LENGTH_LONG).show();
    }

    startOver();
  }

  private String getFailureMessage(Intent data) {
    String message = "Payment canceled.";
    if (data != null) {
      StringBuilder b = new StringBuilder("Payment failed");
      Response response = Response.from(data);
      if (response.errors().isEmpty()) {
        b.append(".");
      } else {
        b.append(":");
        for (String s : response.errors()) {
          b.append(" ").append(s);
        }
      }
      message = b.toString();
    }
    return message;
  }

  @Override protected void onPrepareDialog(int id, Dialog dialog) {
    super.onPrepareDialog(id, dialog);

    if (id == VALIDATION_DIALOG) {
      dialog.setTitle(validate());
    }
  }

  @Override protected Dialog onCreateDialog(int id) {
    switch (id) {
      case VALIDATION_DIALOG:
        return new AlertDialog.Builder(this)
          .setCancelable(true)
          .setTitle(validate())
          .setMessage("Please try again.")
          .setNegativeButton("OK", null)
          .create();
      case CLEAR_DIALOG:
        return new AlertDialog.Builder(this)
          .setCancelable(true)
          .setTitle("Clear input?")
          .setPositiveButton("Dismiss", null)
          .setNegativeButton("Clear", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
              startOver();
            }
          })
          .create();
      case EXIT_DIALOG:
        return new AlertDialog.Builder(this)
          .setCancelable(true)
          .setTitle("Confirm Exit")
          .setMessage("Existing input will be lost.")
          .setPositiveButton("Dismiss", null)
          .setNegativeButton("Exit", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
              finish();
            }
          })
          .create();
    }

    throw new AssertionError();
  }

  @Override public void onBackPressed() {
    boolean inputPresent = false;
    for (TextView textView : textViews) {
      if (textView.length() > 0) inputPresent = true;
    }
    if (inputPresent) {
      showDialog(EXIT_DIALOG);
    } else {
      super.onBackPressed();
    }
  }

  /**
   * Starts the activity over.
   */
  private void startOver() {
    Intent intent = new Intent(this, Main.class);
    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
    startActivity(intent);
  }

  private TextView findTextViewById(int id) {
    return (TextView) findViewById(id);
  }

  /**
   * Validates input.
   * @return null if all input is valid. Otherwise, switches focus to
   * first invalid field and returns an error message.
   */
  private String validate() {
    for (TextView textView : textViews) {
      if (textView.getText().toString().trim().length() == 0) {
        textView.requestFocus();
        return "Missing Input";
      }
    }

    if (!Email.isValidEmail(email.getText())) {
      email.requestFocus();
      return "Invalid Email Address";
    }

    return null;
  }

  private String description() {
    StringWriter sout = new StringWriter();
    CSVWriter cout = new CSVWriter(sout);
    String[] values = new String[textViews.length];
    for (int i = 0; i < textViews.length; i++) {
      values[i] = textViews[i].getText().toString();
    }
    cout.writeNext(values);
    try {
      cout.close();
    } catch (IOException e) {
      throw new AssertionError(e);
    }
    return sout.toString();
  }

  private class AmountTextWatcher implements TextWatcher {
    String previousText = "";

    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
    }

    public void onTextChanged(CharSequence s, int start, int before, int count) {
    }

    public void afterTextChanged(Editable s) {
      String enteredText = s.toString();

      // Remove all non-digits.
      String stripped = enteredText.replaceAll("\\D", "");
      // Limit the length so the max value is 999999.
      if (stripped.length() > 6) {
        stripped = previousText;
      }
      dollars = stripped.length() == 0 ? 0 : Integer.parseInt(stripped);

      if (!enteredText.equals(stripped)) {
        previousText = stripped;
        s.replace(0, s.length(), stripped);
      } else {
        previousText = enteredText;
      }
    }
  }
}
