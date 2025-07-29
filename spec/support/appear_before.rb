RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    @earlier_content = earlier_content
    earlier_index = page.body.index(earlier_content)
    later_index = page.body.index(later_content)

    if earlier_index.nil? && later_index.nil?
      @failure_message = "Neither '#{earlier_content}' nor '#{later_content}' were found in the page"
      false
    elsif earlier_index.nil?
      @failure_message = "Expected content '#{earlier_content}' was not found in the page"
      false
    elsif later_index.nil?
      @failure_message = "Expected content '#{later_content}' was not found in the page"
      false
    else
      earlier_index < later_index
    end
  end

  failure_message do
    @failure_message || "Expected '#{@earlier_content}' to appear before '#{later_content}' in the page"
  end
end
