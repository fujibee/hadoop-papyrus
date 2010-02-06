/*
 * The MIT License
 *
 * Copyright (c) 2004-2009, Sun Microsystems, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package hudson.plugins.hadoop.ruby;

import hudson.Extension;
import hudson.FilePath;
import hudson.model.Hudson;
import hudson.model.listeners.ItemListener;
import hudson.util.StreamTaskListener;

import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Install Hadoop Ruby DSL
 * 
 * @author Koichi Fujikawa
 */
@Extension
public class ItemListenerImpl extends ItemListener {

	@Override
	public void onLoaded() {
		try {
			LOGGER.log(Level.INFO, "install start for Hadoop Ruby");
			StreamTaskListener listener = new StreamTaskListener(System.out);
			File rootDir = Hudson.getInstance().getRootDir();
			rootDir = new File(rootDir, "hadoop-ruby");
			FilePath distDir = new FilePath(rootDir);
			distDir.installIfNecessaryFrom(ItemListenerImpl.class
					.getResource("hadoop-ruby.tgz"), listener, "Hadoop Ruby");
			LOGGER.log(Level.INFO, "install finished for Hadoop Ruby");

		} catch (Exception e) {
			LOGGER.log(Level.WARNING, "Failed to install Hadoop Ruby", e);
		}
	}

	private static final Logger LOGGER = Logger
			.getLogger(ItemListenerImpl.class.getName());
}
