module Banacle
  module Slack
    Response = Struct.new(:response_type, :replace_original, :text, :attachments, keyword_init: true) do
      class ValidationError < StandardError; end

      def initialize(*args)
        super
        self.set_default!
        self.validate!
        self
      end

      def set_default!
        self.response_type ||= "in_channel"
        self.replace_original = true if self.replace_original.nil?
        self.text ||= ""
        self.attachments ||= []
      end

      def validate!
        unless self.replace_original.is_a?(TrueClass) || self.replace_original.is_a?(FalseClass)
          raise ValidationError.new("replace_original must be TrueClass or FalseClass")
        end

        %i(response_type text).each do |label|
          unless self.send(label).is_a?(String)
            raise ValidationError.new("#{attr} must be String")
          end
        end

        attachments.each do |a|
          unless a.is_a?(Slack::Attachment)
            raise ValidationError.new("One of attachments #{a.inspect} must be Slack::Attachment")
          end
        end
      end

      def as_json
        self.to_h.tap { |h| h[:attachments] = h[:attachments].map(&:as_json) }
      end

      def to_json
        as_json.to_json
      end
    end

    Attachment = Struct.new(:text, :fallback, :callback_id, :color, \
                            :attachment_type, :actions, keyword_init: true) do
      class ValidationError < StandardError; end

      def initialize(*args)
        super
        self.set_default!
        self.validate!
        self
      end

      def set_default!
        self.text ||= ''
        self.fallback ||= ''
        self.callback_id ||= ''
        self.color ||= ''
        self.attachment_type ||= ''
        self.actions ||= []
      end

      def validate!
        %i(text fallback callback_id color attachment_type).each do |label|
          unless self.send(label).is_a?(String)
            raise ValidationError.new("#{attr} must be String")
          end
        end

        self.actions.each do |a|
          unless a.is_a?(Slack::Action)
            raise ValidationError.new("One of actions #{a.inspect} must be Slack::Action")
          end
        end
      end

      def as_json
        self.to_h.tap { |h| h[:actions] = h[:actions].map(&:as_json) }
      end
    end

    Action = Struct.new(:name, :text, :style, :type, :value, :confirm, keyword_init: true) do
      class ValidationError < StandardError; end

      def self.approve_button
        self.build_button('approve', style: 'primary', confirm: Confirm.approve)
      end

      def self.reject_button
        self.build_button('reject', style: 'danger')
      end

      def self.cancel_button
        self.build_button('cancel')
      end

      def self.build_button(value, style: 'default', confirm: nil)
        self.build(value, style, 'button', confirm)
      end

      def self.build(value, style, type, confirm)
        self.new(name: value, text: value.capitalize, style: style, type: type, value: value, confirm: confirm)
      end

      def initialize(*args)
        super
        self.set_default!
        self.validate!
        self
      end

      def set_default!
        self.name ||= ''
        self.text ||= ''
        self.style ||= ''
        self.type ||= ''
        self.value ||= ''
      end

      def validate!
        %i(name text style type value).each do |label|
          unless self.send(label).is_a?(String)
            raise ValidationError.new("#{attr} must be String")
          end
        end

        if self.confirm && !self.confirm.is_a?(Confirm)
          raise ValidationError.new("confirm must be Slack::Confirm")
        end
      end

      def approved?
        self.value == 'approve'
      end

      def rejected?
        self.value == 'reject'
      end

      def cancelled?
        self.value == 'cancel'
      end

      def as_json
        self.to_h.tap do |h|
          if h[:confirm]
            h[:confirm] = h[:confirm].as_json
          else
            h.delete(:confirm)
          end
        end
      end
    end

    Confirm = Struct.new(:title, :text, :ok_text, :dismiss_text, keyword_init: true) do
      def self.approve
        self.new(text: 'The operation will be performed immediately.')
      end

      def initialize(*args)
        super
        self.set_default!
        self.validate!
        self
      end

      def set_default!
        self.title ||= 'Are you sure?'
        self.text ||= ''
        self.ok_text ||= 'Yes'
        self.dismiss_text ||= 'No'
      end

      def validate!
        %i(title text ok_text dismiss_text).each do |label|
          unless self.send(label).is_a?(String)
            raise ValidationError.new("#{attr} must be String")
          end
        end
      end

      def as_json
        self.to_h
      end
    end
  end
end
