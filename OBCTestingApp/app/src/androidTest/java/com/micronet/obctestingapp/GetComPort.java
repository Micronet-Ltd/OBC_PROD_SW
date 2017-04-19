package com.micronet.obctestingapp;

import android.content.Context;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;

import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.*;

/**
 * Instrumentation test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class GetComPort extends GetComPortResultReceiver {
    @Test
    public void useAppContext() throws Exception {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getTargetContext();

        assertEquals("com.micronet.obctestingapp", appContext.getPackageName());
    }

    private File Com1 = new File("//dev//ttyUSB0");
    private File Com2 = new File("//dev//ttyUSB1");
    private File Com3 = new File("//dev//ttyUSB2");
    private File Com4 = new File("//dev//ttyUSB3");
    @Test
    public void testgetComPort1() throws Exception {
        assertThat(writeReceiveTest(Com1, Com2, "Com1Out"), containsString( "SUCCESS: Data sent out of"));
    }

    @Test
    public void testgetComPort2() throws Exception {
        assertThat(writeReceiveTest(Com2, Com1, "Com2Out"), containsString( "SUCCESS: Data sent out of"));
    }

    @Test
    public void testgetComPort3() throws Exception {
        assertThat(writeReceiveTest(Com3, Com4, "Com3Out"), containsString( "SUCCESS: Data sent out of"));
    }

    @Test
    public void testgetComPort4() throws Exception {
        assertThat(writeReceiveTest(Com4, Com3, "Com4Out"), containsString( "SUCCESS: Data sent out of"));
    }
}
