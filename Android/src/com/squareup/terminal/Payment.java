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

/**
 * Describes a payment that can be fulfilled using Square.
 *
 * @author Bob Lee (bob@squareup.com)
 */
public class Payment {

  /** Constructs a new payment. */
  public Payment() {}

  private Money amount;

  /**
   * Convenience method, equivalent to {@code amount(new Money(amount, currency))}.
   */
  public Payment amount(int amount, Currency currency) {
    return amount(new Money(amount, currency));
  }

  /**
   * Specifies the amount of this payment. Required.
   *
   * @throws NullPointerException if amount is null
   */
  public Payment amount(Money amount) {
    if (amount == null) throw new NullPointerException("amount");
    this.amount = amount;
    return this;
  }

  /** Returns the amount of this payment or null if none has been specified yet. */
  public Money amount() {
    return amount;
  }

  private String defaultEmail;

  /**
   * Specifies a default email address to send a receipt to. Optional. If
   * the user chooses to email themselves a receipt and Square doesn't
   * already have an email address on file, Square will pre-fill the email
   * field with this value.
   *
   * @param defaultEmail to send receipt to
   * @throws NullPointerException if email is null
   * @return this payment
   */
  public Payment defaultEmail(String defaultEmail) {
    if (defaultEmail == null) throw new NullPointerException("defaultEmail");
    this.defaultEmail = defaultEmail;
    return this;
  }

  /** Returns the default email address or null if none was specified. */
  public String defaultEmail() {
    return defaultEmail;
  }

  private String defaultPhone;

  /**
   * Specifies a default phone number to text message a receipt to. Optional. If
   * the user chooses to text message themselves a receipt and Square doesn't
   * already have a phone number on file, Square will pre-fill the phone number
   * field with this value.
   *
   * @param defaultPhone to text message receipt to
   * @throws NullPointerException if number is null
   * @return this builder
   */
  public Payment defaultPhone(String defaultPhone) {
    if (defaultPhone == null) throw new NullPointerException("defaultNumber");
    this.defaultPhone = defaultPhone;
    return this;
  }

  /** Returns the default phone number or null if none was specified. */
  public String defaultPhone() {
    return defaultPhone;
  }

  private String description;

  /**
   * Describes this payment in 140 characters or less. Optional.
   *
   * @param description of this payment, 140 characters max
   * @throws NullPointerException if description is null
   * @return this payment
   */
  public Payment description(String description) {
    if (description == null) throw new NullPointerException("description");
    if (description.length() > 140) throw new IllegalArgumentException("description length > 140");
    this.description = description;
    return this;
  }

  /** Returns the payment's description or null if none was specified. */
  public String description() {
    return description;
  }

  private String metadata;

  /**
   * Attaches metadata to this payment. Optional. Clients should encrypt sensitive
   * data. Clients can retrieve this data using Square's
   * <a href="https://github.com/square/api/wiki/History-API">History API</a>.
   *
   * @param metadata arbitrary string, 4096 characters or less
   * @throws NullPointerException if metadata is null
   * @return this payment
   */
  public Payment metadata(String metadata) {
    if (metadata == null) throw new NullPointerException("metadata");
    if (metadata.length() > 4096) throw new IllegalArgumentException("metadata length > 4096");
    this.metadata = metadata;
    return this;
  }

  /** Returns the metadata or null if none was specified. */
  public String metadata() {
    return metadata;
  }

  private Boolean offerReceipt;

  /**
   * Specifies whether or not the Square app should offer a receipt. Defaults to true. If false,
   * the caller should offer a receipt.
   *
   * @return this payment
   */
  public Payment offerReceipt(boolean offerReceipt) {
    this.offerReceipt = offerReceipt;
    return this;
  }

  /** Returns true if the app should offer a receipt. */
  public boolean offerReceipt() {
    return offerReceipt == null ? true : offerReceipt;
  }

  private String referenceId;

  /**
   * An ID that can be used by the caller to identify this payment.
   *
   * @param referenceId for this payment, 256 characters or less
   * @throws NullPointerException if referenceId is null
   * @return this payment
   */
  public Payment referenceId(String referenceId) {
    if (referenceId == null) throw new NullPointerException("referenceId");
    if (referenceId.length() > 256) throw new IllegalArgumentException("reference ID length > 256");
    this.referenceId = referenceId;
    return this;
  }

  /** Returns the reference ID or null if none was specified. */
  public String referenceId() {
    return referenceId;
  }

  private String accountId;

  /**
   * Specifies a recipient for this payment. Account IDs are available through Square's web site.
   * If no recipient is specified, the payment will go to whoever is logged into the Square app.
   *
   * @param accountId for the payment's recipient
   * @throws NullPointerException if accountId is null
   * @return this payment
   */
  public Payment recipient(String accountId) {
    if (accountId == null) throw new NullPointerException("accountId");
    this.accountId = accountId;
    return this;
  }

  /** Returns the payment recipient's account ID or null if none was specified. */
  public String recipient() {
    return accountId;
  }
}
