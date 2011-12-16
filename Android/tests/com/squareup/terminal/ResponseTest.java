package com.squareup.terminal;

import org.junit.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * Unit test for {@link Response}. Note that Intent methods are not covered due to
 * reliance on Android runtime.
 */
public class ResponseTest {
  @Test
  public void testSuccessful() {
    Response r = new Response("paymentId", "referenceId");
    assertTrue(r.errors().isEmpty());
    assertEquals("paymentId", r.paymentId());
    assertEquals("referenceId", r.referenceId());
    assertEquals("http://callback.url.com?square_status=successful&square_reference_id=referenceId&square_payment_id=paymentId",
        r.toCallbackUrl("http://callback.url.com", false));
    assertEquals("http://callback.url.com?square_status=cancelled&square_reference_id=referenceId", r.toCallbackUrl("http://callback.url.com", true));
  }

  @Test
  public void testError() {
    List<String> errors = Arrays.asList("able", "baker", "charlie");
    Response r = new Response("referenceId", errors);
    assertEquals("referenceId", r.referenceId());
    assertEquals(errors, r.errors());
    assertEquals("http://callback.url.com?square_status=error&square_reference_id=referenceId&square_errors=able, " +
        "baker, charlie", r.toCallbackUrl("http://callback.url.com", false));
    assertEquals("http://callback.url.com?square_status=cancelled&square_reference_id=referenceId",
        r.toCallbackUrl("http://callback.url.com", true));
  }
}
