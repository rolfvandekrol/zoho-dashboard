
module Dashboard
  class Project
    attr_reader :id, :name
    def initialize(id, name)
      @id, @name = id, name
    end

    def buckets
      @buckets ||= []
    end

    def add_bug(bug_info)
      buckets.each do |bucket|
        bucket.add_bug(bug_info)
      end
    end
  end
end