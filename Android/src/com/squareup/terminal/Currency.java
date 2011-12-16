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
 * Currency types supported by this API.
 *
 * @author Bob Lee (bob@squareup.com)
 */
public enum Currency {

  /** United States dollar. The atomic unit is the cent. */
  USD(2);

  /** Number of digits in the fractional part. */
  final int scale;

  /** Divisor for this currency. The divisor for USD is 100. */
  final int divisor;

  Currency(int scale) {
    this.scale = scale;

    int divisor = 1;
    for (int i = 0; i < scale; i++) divisor *= 10;
    this.divisor = divisor;
  }
}
