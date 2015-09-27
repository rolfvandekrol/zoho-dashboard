
module Dashboard
  class Bucket
    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, (to.nil? ? DateTime.now : to)
    end

    def info
      @info ||= {}
    end

    def info_per_type(type)
      info[type] ||= {
        opened: 0,
        closed: 0,
        state_open: 0,
        state_closed: 0,
      }
    end

    def as_json(options = nil)
      {week: [from.cwyear, from.cweek]}.merge(super(options))
    end

    def add_bug(bug_info)
      # * Number of bugs & features openend per week
      # * Number of bugs & features closed per week
      # * Number of open & closed bugs & features at the end of each week

      # if the bug is opened ater the bucket period, it should be counted
      # in this bucket at all
      if bug_info[:opened_at] >= to
        return
      end

      # If the bug is openend between the from and to date
      if bug_info[:opened_at] >= from && bug_info[:opened_at] < to
        info_per_type(bug_info[:type])[:opened] += 1
      end

      # If we have a closed date and the closed date is between from and to
      if !bug_info[:closed_at].nil? && bug_info[:closed_at] >= from && bug_info[:closed_at] < to
        info_per_type(bug_info[:type])[:closed] += 1
      end

      # if the bug is currently closed, a missing closed at means that is was
      # closed before the first bucket
      if bug_info[:closed]
        # If closed is missing, it was closed before the first bucket, so it was
        # also closed in this bucket period
        if bug_info[:closed_at].nil?
          info_per_type(bug_info[:type])[:state_closed] += 1
        else
          # If the was closed before the to date, mark it as closed.
          if bug_info[:closed_at] < to
            info_per_type(bug_info[:type])[:state_closed] += 1
          else
            info_per_type(bug_info[:type])[:state_open] += 1
          end
        end

      # If the bug is currently open, it is also open in the current bucket, 
      # because we jumped out earlier if the bug was created after the bucket
      # period.
      else
        info_per_type(bug_info[:type])[:state_open] += 1
      end
    end
  end
end