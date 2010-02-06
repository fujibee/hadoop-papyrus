package hudson.plugins.hadoop.ruby;

import hudson.Extension;
import hudson.FilePath;
import hudson.model.AbstractProject;
import hudson.model.Descriptor;
import hudson.model.Hudson;
import hudson.tasks.BuildStepDescriptor;
import hudson.tasks.Builder;
import hudson.tasks.CommandInterpreter;

import java.io.File;

import net.sf.json.JSONObject;

import org.kohsuke.stapler.StaplerRequest;

/**
 * Invokes the hadoop ruby interpreter and invokes the Hadoop Ruby script
 * entered on the hudson build configuration.
 * <p/>
 * It is expected that the hadoop ruby interpreter is available on the system
 * PATH.
 * 
 * @author Koichi Fujikawa
 */
public class HadoopRuby extends CommandInterpreter {

	private HadoopRuby(String command) {
		super(command);
	}

	protected String[] buildCommandLine(FilePath script) {
		File rootDir = Hudson.getInstance().getRootDir();
		String cmd = rootDir.toString()
				+ "/hadoop-ruby/bin/hadoop-ruby.sh";
		return new String[] { cmd, script.getRemote() };
	}

	protected String getContents() {
		return command;
	}

	protected String getFileExtension() {
		return ".rb";
	}

	@Override
	public Descriptor<Builder> getDescriptor() {
		return DESCRIPTOR;
	}

	@Extension
	public static final DescriptorImpl DESCRIPTOR = new DescriptorImpl();

	public static final class DescriptorImpl extends
			BuildStepDescriptor<Builder> {
		private DescriptorImpl() {
			super(HadoopRuby.class);
		}

		@Override
		public Builder newInstance(StaplerRequest req, JSONObject formData) {
			return new HadoopRuby(formData.getString("hadoop-ruby"));
		}

		public String getDisplayName() {
			return "Execute Hadoop Ruby script";
		}

		@Override
		public String getHelpFile() {
			return "/plugin/hadoop-ruby/help.html";
		}

		@Override
		public boolean isApplicable(Class<? extends AbstractProject> jobType) {
			return true;
		}
	}
}
