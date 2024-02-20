class ExampleJob < ApplicationJob
  queue_as :default

  # Provide a record to args and below will return "title"
  def perform(*args)
  	args.each { |t| puts t.title }
    puts "Job working...#{args.class}"
  end
end
