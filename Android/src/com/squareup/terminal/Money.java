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

import java.text.ParseException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// TODO: Move Money and Currency to com.squareup (in a separate module?)

/**
 * A quantity of a specific {@linkplain Currency currency}.
 *
 * @author Bob Lee (bob@squareup.com)
 */
public final class Money {

  // TODO: Move the max into currency.

  /**
   * The maximum amount supported by Square. This is the absolute maximum
   * supported by the Square application; it's likely much greater than the
   * merchant-specific card payment limit.
   */
  private static final long MAX_AMOUNT = 999999999; // 9 digits or $9,999,999.99

  private final long amount;
  private final Currency currency;

  /**
   * Constructs a new Money. The amount is specified in
   * atomic units of the specified currency. For example, if the currency is the
   * {@linkplain Currency#USD U.S. dollar}, the amount is specified in
   * cents.
   *
   * @param amount atomic units of the specified currency, >= 0 && <=
   *  {@link #MAX_AMOUNT}
   * @param currency type
   * @throws IllegalArgumentException if amount is < 0 || >
   *  {@link #MAX_AMOUNT}
   * @throws NullPointerException if currency is null
   */
  public Money(long amount, Currency currency) {
    if (currency == null) throw new NullPointerException("currency");
    if (amount < 0) throw new IllegalArgumentException("amount < 0");
    if (amount > MAX_AMOUNT) {
      throw new IllegalArgumentException("amount > MAX_AMOUNT");
    }

    this.amount = amount;
    this.currency = currency;
  }

  /**
   * Returns the amount in atomic units of {@link #currency}.
   */
  public long amount() {
    return amount;
  }

  /**
   * Returns the currency type for this value.
   */
  public Currency currency() {
    return currency;
  }

  /**
   * Returns the amount as a fixed point string. The number of decimal places depends on the
   * currency.
   */
  /*package*/ String fixedPoint() {
    if (currency.scale == 0) return String.valueOf(amount);
    return String.format("%d.%0" + currency.scale + "d",
        amount / currency.divisor, amount() % currency.divisor);
  }

  /** Parses a fixed point currency string. */
  /*package*/ static Money parse(String fixedPoint, Currency currency) throws ParseException {
    String regex = "^(\\d+)\\.(\\d{" + currency.scale + "})$";
    Pattern pattern = Pattern.compile(regex);
    Matcher matcher = pattern.matcher(fixedPoint);
    if (!matcher.matches()) {
      throw new ParseException("\"" + fixedPoint + "\" doesn't match /" + regex + "/.", 0);
    }
    long whole = Long.parseLong(matcher.group(1));
    long fractional = Long.parseLong(matcher.group(2));
    return new Money(whole * currency.divisor + fractional, currency);
  }

  @Override public String toString() {
    return "Money{" +
        "amount=" + amount +
        ", currency=" + currency +
        '}';
  }
}