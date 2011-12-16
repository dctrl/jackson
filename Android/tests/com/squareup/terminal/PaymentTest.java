package com.squareup.terminal;

import org.junit.Test;

import static junit.framework.Assert.assertFalse;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class PaymentTest {
  @Test
  public void buildForward() {
    Payment p = new Payment()
        .amount(50, Currency.USD)
        .defaultEmail("foo@bar.com")
        .defaultPhone("123 456 7890")
        .description("description")
        .metadata("metadata")
        .offerReceipt(true)
        .referenceId("reference")
        .recipient("account id");

    assertEquals(new Money(50, Currency.USD).fixedPoint(), p.amount().fixedPoint());
    assertEquals("foo@bar.com", p.defaultEmail());
    assertEquals("123 456 7890", p.defaultPhone());
    assertEquals("description", p.description());
    assertEquals("metadata", p.metadata());
    assertTrue(p.offerReceipt());
    assertEquals("reference", p.referenceId());
    assertEquals("account id", p.recipient());
  }

  /**
   * Because once it was broken
   */
  @Test
  public void buildBackward() {
    Payment p = new Payment()
        .recipient("account id dos")
        .referenceId("referenced")
        .offerReceipt(false)
        .metadata("more metadata")
        .description("another description")
        .defaultPhone("231 456 7890")
        .defaultEmail("bar@foo.com")
        .amount(500, Currency.USD);

    assertEquals(new Money(500, Currency.USD).fixedPoint(), p.amount().fixedPoint());
    assertEquals("bar@foo.com", p.defaultEmail());
    assertEquals("231 456 7890", p.defaultPhone());
    assertEquals("more metadata", p.metadata());
    assertEquals("another description", p.description());
    assertFalse(p.offerReceipt());
    assertEquals("referenced", p.referenceId());
    assertEquals("account id dos", p.recipient());
  }

  @Test
  public void otherAmount() {
    Payment p1 = new Payment().amount(1234, Currency.USD);
    Payment p2 = new Payment().amount(p1.amount());
    assertEquals(p1.amount(), p2.amount());
  }

  @Test(expected = IllegalArgumentException.class)
  public void tooLongDescription() {
    // Just fits
    new Payment().description("1234567890123456789012345678901234567890123456789012345678901234567890"
        + "1234567890123456789012345678901234567890123456789012345678901234567890");
    // Just over
    new Payment().description("1234567890123456789012345678901234567890123456789012345678901234567890"
        + "1234567890123456789012345678901234567890123456789012345678901234567890"
        + "1");
  }

  @Test(expected = IllegalArgumentException.class)
  public void tooLongMetaData() {
    String ten = "1234567890";
    StringBuilder justFits = new StringBuilder();
    StringBuilder justBig = new StringBuilder();

    for (int i = 0; i < 409; i++) {
      justFits.append(ten);
      justBig.append(ten);
    }

    justFits.append("123456");
    justBig.append("1234567");

    new Payment().metadata(justFits.toString());
    new Payment().metadata(justBig.toString());
  }
}
