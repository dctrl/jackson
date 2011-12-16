BASE_NAME=square-terminal-api
VERSION=0.2

NAME=$BASE_NAME-$VERSION

# Clear and recreate build directory.
rm -rf build
mkdir -p build/classes
mkdir -p build/test-classes
mkdir -p build/dist

# Compile classes.
javac -g -classpath external/android.jar -d build/classes \
    -target 5 `find src -name *.java`

# Compile tests.
javac -g -classpath external/junit-4.10.jar:external/android.jar:build/classes -d build/test-classes \
    -target 5 `find tests -name *.java`

# Run tests.
java -classpath external/junit-4.10.jar:external/android.jar:build/classes:build/test-classes \
  org.junit.runner.JUnitCore \
  $(find tests -name \*Test.java | sed 's/tests\///' | sed 's/\.java//' | sed 's/\//./g')

# Generate Javadocs.
TITLE="Square's Terminal API for Android v${VERSION}"

FOOTER="<font size='-1'>Copyright (C) 2011 <a href='https://squareup.com/'>\
Square, Inc.</a> \
Licensed under the <a href='http://www.apache.org/licenses/LICENSE-2.0'>Apache \
License</a>, Version 2.0.</font>"

javadoc -protected -bottom "$FOOTER" \
	-header "$TITLE" \
    	-doctitle "$TITLE" \
	-classpath external/android.jar \
        -sourcepath src -d build/javadoc com.squareup.terminal

# Generate jars.

jar cfM build/dist/$NAME-src.zip -C src .

jar cfM build/dist/$NAME-javadoc.zip -C build/javadoc .
jar cfM build/dist/$NAME.jar -C build/classes .

jar cfM build/$NAME.zip -C build/dist .

rm examples/jackson/libs/${BASE_NAME}*.jar
cp build/dist/$NAME.jar examples/jackson/libs/

