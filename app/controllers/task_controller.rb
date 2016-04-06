class TaskController < WebsocketRails::BaseController
  def create
    # The `message` method contains the data received
    task = Task.new message
    send_message :create_success, "hello", :namespace => :tasks
  end
end
