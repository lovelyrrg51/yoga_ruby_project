class Task < ApplicationRecord
  include AASM

  attr_accessor :result

  validates :taskable_id, :taskable_type, :t_config, presence: true
  validates :email, presence: true, if: Proc.new { |t| t.t_config.present? && t.t_config.has_key?(:sync) && !t.t_config[:sync] }

  def t_config
    task_config = read_attribute(:t_config)
    return JSON.parse(task_config).with_indifferent_access if task_config.is_a?(String)
    return task_config.with_indifferent_access if task_config.is_a?(Hash)
    task_config
  end

  belongs_to :taskable, polymorphic: true
  has_many :parent_task_associations, class_name: 'TaskAssociation', foreign_key: 'child_task_id'
  has_many :parent_tasks, through: :parent_task_associations, source: :parent_task
  has_one :parent_task
  has_many :child_task_associations, class_name: 'TaskAssociation', foreign_key: 'parent_task_id'
  has_many :sub_tasks, through: :child_task_associations, source: :child_task
  has_one :attachment, as: :attachable

  enum status: [ :initiated, :processing, :completed, :failed ]

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :processing
    state :completed
    state :failed
  end

  serialize :opts, JSON
  serialize :t_config, JSON

  after_update :abort_sub_tasks, if: Proc.new { |t| status_changed? and t.status == 'failed' and not t.parent_task.present? }

  after_update :is_all_sub_task_processed, if: Proc.new { |t| status_changed? and t.parent_task.present? }

  def parent_task
    self.parent_tasks.last
  end

  def create_subtasks(opts = {})
    begin
      block = eval(self.start_block.to_s)

      raise 'Start block is missing. Create subtasks' if (block.nil? and not block.kind_of?(Proc))

      raise 'Final block is not given.' unless self.final_block.present?

      raise 'Options is not given.' unless self.opts.present?

      raise 'Task configuration is not given.' unless self.t_config.present?

      t_config = ActiveSupport::HashWithIndifferentAccess.new(self.t_config)

      sync = t_config[:sync]

      params = ActiveSupport::HashWithIndifferentAccess.new(self.opts)

      # Parent task is processing
      self.update(status: 1)

      # Call block that will hold all results
      block.call(self, params)

      # Assign batch size
      batch_size = opts[:batch_size] || params[:batch_size] || 10000

      # Process result in chunks -> creating sub tasks here
      self.result.in_groups_of(batch_size, false) do |group|

        # Create a subtask
        sub_task = Task.new(taskable_id: self.taskable_id, taskable_type: self.taskable_type, email: self.email, t_config: t_config)

        # Save subtask
        raise SyException, sub_task.errors.full_messages.first unless sub_task.save

        # Create a parent child task association
        task_association = TaskAssociation.new(parent_task_id: self.id, child_task_id: sub_task.id)

        raise SyException, task_association.errors.full_messages.first unless task_association.save

        if sync
          blob = sub_task.process_subtask(group)
          return blob
        else
          sub_task.delay.process_subtask(group)
        end
      end

      self.update(status: 2)

    rescue Exception => e
      # Aborting all tasks if parent task failed
      self.update(status: 3, message: e.message)

      raise e.message if sync
    end
  end

  def add_start_block(&block)
    raise 'Start block is missing.' unless block_given?
    self.update_columns(start_block: block.to_raw_source)
  end

  def add_start_block=(block)
    raise 'Start block is missing.' unless block.present?
    self.update_columns(start_block: block.to_raw_source)
  end

  def add_final_block(&block)
    raise 'Final block is missing.' unless block_given?
    self.update_columns(final_block: block.to_raw_source)
  end

  def add_final_block=(block)
    raise 'Final block is missing.' unless block.present?
    self.update_columns(final_block: block.to_raw_source)
  end

  def process_subtask(group)


    begin
      raise "Parent task ##{parent_task.id} is failed. So cannot proceed further." if parent_task.failed?

      raise "Sub task cannot be processed as its status is: #{self.status}" unless self.initiated?

      # Sub task processing
      raise self.errors.full_messages.first unless self.update(status: 1)

      block = eval(parent_task.final_block.to_s)

      raise 'Final block is missing. Process Async' if (block.nil? and not block.kind_of?(Proc))

      t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)
      sync = t_config[:sync]

      opts = ActiveSupport::HashWithIndifferentAccess.new(parent_task.opts)

      details = block.call(self, group, opts.merge({sync: sync}))

      file = details[:file]

      if sync
        # Mark Sub Task completed
        self.update(status: 2)

        return file
      end

      mime_type = Rack::Mime.mime_type(".#{details[:format]}")

      attachment = Attachment.upload_file({file_name: "#{t_config[:file_name]}_#{Time.now.strftime('%d-%m-%Y:%H:%M:%S')}.#{details[:format]}", file_path: file.path, content: file.path, is_secure: true, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: self.id, attachable_type: 'Task', file_type: mime_type, prefix: t_config[:prefix]})

      raise "Error in creating attachment for sub task: #{self.id}" unless attachment.present?

      # Sub Task completed
      self.update(status: 2)

    rescue Exception => e
      # Sub task failed
      self.update(status: 3, message: e.message)

      raise e.message if sync
    end
  end

  private
  def abort_sub_tasks
    self.sub_tasks.each{ |st| st.update(status: 3, message: "Main task failed with error: #{self.message}") }
  end

  def is_all_sub_task_processed

    # Get task configuration
    t_config = ActiveSupport::HashWithIndifferentAccess.new(parent_task.t_config)
    return true if t_config[:sync]

    sub_tasks = parent_task.sub_tasks
    sub_task_statuses = sub_tasks.collect{ |t| t.status }.uniq

    user = self.taskable

    cc = []
    recipients = parent_task.email.split(',')
    cc = ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'development'
    cc = ENV['TESTING_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'testing'

    # Mailer options
    subject = t_config[:file_name].humanize.titleize
    template = t_config[:template]

    # Email: Fwd: Sadhak Search Result - 28022017225119121517446 - Vipull - Speical check so that sadhak profile report.
    opts = ActiveSupport::HashWithIndifferentAccess.new(parent_task.opts)
    if opts[:country_id].to_i == 113
      from = 'registration@shivyogindia.com'
    else
      from = 'support@absclp.com'
    end

    if sub_task_statuses.size == 1 and (sub_task_statuses.last == 'completed' or sub_task_statuses.last == 2)
      # generate links
      links = {}

      sub_tasks.each do |st|
        attachment = st.attachment
        if attachment.present?
          links["#{attachment.name}"] = attachment.s3_downloadable_url(expires: 24*60*60)
        end
      end
      ApplicationMailer.send_email(from: from, recipients: recipients, cc: cc, subject: "#{subject} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", sadhak_profile: user.try(:sadhak_profile), template: template, links: links).deliver_now

    elsif (sub_task_statuses.include?('failed') or sub_task_statuses.include?(3)) and not (sub_task_statuses.include?('initiated') or sub_task_statuses.include?(0) or sub_task_statuses.include?('processing') or sub_task_statuses.include?(1))

      # One task has been failed and all processed
      ApplicationMailer.send_email(from: from, recipients: recipients, cc: cc, subject: "#{subject} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", sadhak_profile: user.try(:sadhak_profile), template: template, links: links, sub_tasks: sub_tasks).deliver
    end
  end
end
