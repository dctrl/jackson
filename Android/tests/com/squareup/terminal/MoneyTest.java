package com.squareup.terminal;

import org.junit.Test;

import java.text.ParseException;

import static junit.framework.Assert.assertEquals;

public class MoneyTest {
  @Test
  public void oneTest() {
    Money m = new Money(500, Currency.USD);
    assertEquals(500, m.amount());
    assertEquals(Currency.USD, m.currency());
    assertEquals("5.00", m.fixedPoint());
  }

  @Test
  public void parse() throws ParseException {
    assertEquals(new Money(5000, Currency.USD).fixedPoint(),
        Money.parse("50.00", Currency.USD).fixedPoint());
  }

  @Test
  public void reflexive() throws ParseException {
    Money m = new Money(87654321, Currency.USD);

    assertEquals(m.fixedPoint(), Money.parse(m.fixedPoint(), m.currency()).fixedPoint());
  }

  @Test(expected = ParseException.class)
  public void noDecimal() throws ParseException {
    Money.parse("12345", Currency.USD);
  }

  @Test(expected = ParseException.class)
  public void overPrecise() throws ParseException {
    Money.parse("123.4567", Currency.USD);
  }

  @Test(expected = ParseException.class)
  public void ridiculous() throws ParseException {
    Money.parse("boo", Currency.USD);
  }
}
