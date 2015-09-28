
require 'tzinfo'
require 'active_support/values/time_zone'
require 'active_support/core_ext/array/access'
require 'active_support/json'
require 'ruby-progressbar'

module Dashboard
  class Downloader
    def initialize(options)
      @options = options
    end

    def run
      pb = ProgressBar.create(:title => "Analyzing projects", :starting_at => 0, :total => nil, :format => '%t: |%B| %c/%C | %e')

      portal = connection.portals.find_by_id(@options[:portal_id])

      projects = portal.projects.find_all{ |project| project.group_id.to_s == @options[:group_id].to_s }
      pb.total = projects.length

      result = []
      projects.each do |project|
        result << analyse_project(project)
        pb.increment
      end

      pb.finish

      result.sort_by! do |project|
        project.name.downcase
      end

      filename = File.join(File.dirname(__FILE__), '../../build/projects.json')
      File.write(filename, result.to_json)


      # pp analyse_project(connection.portals.first.projects.find_by_id(411028000000208148))

      # .activities.first(20) # .bugs.find_by_id(411028000006270131)
      # p Hash[connection.portals.to_a.map{|portal| [portal.id, [portal.name, portal.company_name]] }]
    end

    def analyse_project(project)
      # Data to gather:
      # * Number of bugs & features openend per week
      # * Number of bugs & features closed per week
      # * Number of open & closed bugs & features at the end of each week
      # * Number of bugs that went over their SLA period per week (later)
      # 
      # We are not analysing everything. Let keep it to max x weeks of history
      # Let's, for now, assume issues are never reopened. So an issue that is
      # open now, was open from the created time till now. An issue that is
      # closed now, it closed at the last status update time.

      buglist = Hash[project.bugs.map do |bug|
        [bug.id, {
          id: bug.id,
          opened_at: bug.created_time,
          closed: bug.closed?,
          type: bug.data['module']['name'].downcase.split(/[^a-z]+/).join('_').to_sym
        }]
      end]

      project.activities.each do |activity|
        break unless buglist.values.any? { |bug_info| bug_info[:closed] && bug_info[:closed_at].nil? }
        break if activity.time < time_buckets.first

        next unless activity.is_a? Zoho::Data::Activity::BugStatus

        next if buglist[activity.action_id].nil? 
        next unless buglist[activity.action_id][:closed]
        next unless buglist[activity.action_id][:closed_at].nil?

        buglist[activity.action_id][:closed_at] = activity.time
      end

      result = Dashboard::Project.new project.id, project.name
      time_buckets.each_index.to_a.to(-2).each do |index|
        result.buckets << Dashboard::Bucket.new(time_buckets[index], time_buckets[index+1])
      end

      buglist.values.each do |bug_info|
        result.add_bug(bug_info)
      end

      result
    end

    protected

    def time_buckets
      @time_buckets ||= begin
        b = []

        today = Date.today
        b << Date.strptime("#{today.cwyear}-#{today.cweek}-1", '%G-%V-%u')
        @options[:weeks].times do
          b.unshift(b.first - 7)
        end

        b.map do |c|
          period = timezone.period_for_local(DateTime.new(c.year, c.month, c.day, 0, 0, 0))
          DateTime.new(c.year, c.month, c.day, 0, 0, 0, ActiveSupport::TimeZone.seconds_to_utc_offset(period.utc_total_offset))
        end
      end
    end

    def timezone
      @timezone ||= TZInfo::Timezone.get('Europe/Amsterdam')
    end

    def connection
      @connection ||= Zoho.connect(@options)
    end
  end
end