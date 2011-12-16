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

import android.net.Uri;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Map;

/**
 * Terminal API URL parameters.
 *
 * @author Bob Lee (bob@squareup.com)
 */
/*package*/ class TerminalParameters {

  // These field names match the parameter names in the URL.
  String amount;
  String currency;
  String callback;
  String app_id;
  String default_email;
  String default_phone;
  String description;
  String metadata;
  String reference_id;
  String offer_receipt;
  String to;

  static final Map<String, Field> FIELDS = new HashMap<String, Field>() {{
    for (Field field : TerminalParameters.class.getDeclaredFields()) {
      if (!Modifier.isStatic(field.getModifiers())) put(field.getName(), field);
    }
  }};

  /** Copies parameters from the given payment. */
  TerminalParameters copyFrom(Payment p) {
    amount = p.amount().fixedPoint();
    currency = p.amount().currency().name();
    default_email = p.defaultEmail();
    default_phone = p.defaultPhone();
    description = p.description();
    metadata = p.metadata();
    reference_id = p.referenceId();
    offer_receipt = String.valueOf(p.offerReceipt());
    to = p.recipient();
    
    return this;
  }

  void copyTo(Payment payment) throws ParseException {
    payment.amount(Money.parse(this.amount, Currency.valueOf(currency)));
    if (default_email != null) payment.defaultEmail(default_email);
    if (default_phone != null) payment.defaultPhone(default_phone);
    if (description != null) payment.description(description);
    if (metadata != null) payment.metadata(metadata);
    if (reference_id != null) payment.referenceId(reference_id);
    if (offer_receipt != null) payment.offerReceipt(Boolean.parseBoolean(offer_receipt));
    if (to != null) payment.recipient(to);
  }

  void appendTo(Uri.Builder uriBuilder) {
    for (Field field : FIELDS.values()) {
      String value;
      try {
        value = (String) field.get(this);
      } catch (IllegalAccessException e) {
        throw new AssertionError(e);
      }

      if (value != null) uriBuilder.appendQueryParameter(field.getName(), value);
    }
  }

  TerminalParameters copyFrom(Uri uri) throws ParseException {
    String query = uri.getEncodedQuery();
    int keyStart = 0;
    while (keyStart < query.length()) {
      // Parse key and value.
      int keyEnd = query.indexOf('=', keyStart);
      if (keyEnd == -1) throw new ParseException("Unexpected end of key", 0);
      String key = query.substring(keyStart, keyEnd);
      int valueEnd = query.indexOf('&', keyEnd + 1);
      if (valueEnd == -1) valueEnd = query.length();
      String value = Uri.decode(query.substring(keyEnd + 1, valueEnd));

      // Store value in field.
      Field field = FIELDS.get(key);
      if (field == null) throw new ParseException("Unexpected parameter: " + key, 0);
      try {
        field.set(this, value);
      } catch (IllegalAccessException e) {
        throw new AssertionError(e);
      }

      keyStart = valueEnd + 1;
    }
    return this;
  }
}
