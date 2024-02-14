module TopicsHelper
    def foo
      Time.now()#{}"This text rendered from topics_helper.rb"
    end

    def edit
        link_to "Edit this topic", edit_topic_path(@topic)
    end

    def small_red
        "btn btn-sm btn-danger"
    end
end
