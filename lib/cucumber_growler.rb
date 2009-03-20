require 'cucumber/formatter/console'

module CucumberGrowler
  IMAGE_ROOT = File.dirname(__FILE__) + '/../images'
  
  def self.included(base)    
    base.module_eval do
      alias original_print_counts print_counts

      def print_counts
        status_string, img, messages = '', '', []
        [:failed, :skipped, :undefined, :pending, :passed].reverse.each do |status|
          if step_mother.steps(status).any?
            status_string, img = status_img_for(status)
            messages << dump_count(step_mother.steps(status).length, "step", status.to_s)
          end
        end
        growl status_string, messages.reverse.join(' - '), "#{IMAGE_ROOT}/#{img}.png"
        original_print_counts
      end
      
      def status_img_for(status)
        case status
        when :passed
          ['Everything passed!','pass']
        when :pending
          ['Still pending features...','pending']
        when :undefined
          ['Something undefined happened...','pending']
        when :skipped
          ['Some steps skipped...','pending']
        when :failed
          ['Failures occurred!','fail']
        end
      end
      
      def growl(title, msg, img, pri=0, sticky="")
        system "growlnotify -n 'autotest' --image #{img} -p #{pri} -d '#{title}_#{Time.now.to_s}' -w -m '#{msg}' #{title}"
      end
      
    end    
  end

end

module Cucumber::Formatter::Console
  include CucumberGrowler
end